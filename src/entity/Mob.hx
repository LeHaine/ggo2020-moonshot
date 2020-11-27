package entity;

import dn.RandList;
import ui.Bar;

enum Body {
	Head;
	Torso;
	Legs;
}

enum Drop {
	None;
	Syringe;
	Coin;
	CrystalShard;
}

class Mob extends Character {
	public static var ALL:Array<Mob> = [];

	public var patrolTarget:Null<CPoint>;

	var lastBodyPartShot:Null<Body>;
	var data:World.Entity_Mob;

	var origin:CPoint;
	var aggroTarget:Null<Entity>;

	var initialAttackCooldown = rnd(0.25, 0.5);
	var attackCdVariance = 0.25;
	var attackCd:Float;
	var baseAttackCooldown(default, set):Float;

	inline function set_baseAttackCooldown(v:Float) {
		attackCd = rnd(-attackCdVariance, attackCdVariance) * v + v;
		return baseAttackCooldown = v;
	}

	var shouldSpawnDeadBody = true;
	var baseAggroRange(default, set):Float;
	var aggroRangeVariance = 0.15;
	var baseSpd = 0.01;

	inline function set_baseAggroRange(v:Float) {
		aggroRange = rnd(-aggroRangeVariance, aggroRangeVariance) * v + v;
		return baseAggroRange = v;
	}

	var aggroRange:Float;
	var attackRange = 8.;
	var targetAggroed:Bool;

	public var defense = 0;
	public var damage = 1;

	public function new(data:World.Entity_Mob) {
		super(data.cx, data.cy);
		ALL.push(this);
		this.data = data;
		initLife(data.f_health);

		dir = data.f_initialDir;
		lockControlS(1);

		origin = makePoint();
		patrolTarget = data.f_patrol == null ? null : new CPoint(data.f_patrol.cx, data.f_patrol.cy);

		bumpFrict = 0.8;

		baseAttackCooldown = 1.2;
		baseAggroRange = 15;
	}

	override function hit(dmg:Int, from:Null<Entity>) {
		super.hit(dmg, from);
		if (!isAlive()) {
			return;
		}
		blink(0xFF0000);
		if (from != null) {
			if (M.dist(from.centerX, from.centerY, headX, headY) < 1) {
				lastBodyPartShot = Head;
				dmg *= 2;
			} else if (M.dist(from.centerX, from.centerY, centerX, centerY) < 1) {
				lastBodyPartShot = Torso;
			} else if (M.dist(from.centerX, from.centerY, footX, footY) < 1) {
				lastBodyPartShot = Legs;
				dmg = M.ceil(dmg * 0.85);
			}
		}

		if (from != null) {
			if (from.is(Bullet)) {
				var bullet = cast(from, Bullet);
				fx.gibs(centerX, centerY, -dirTo(bullet.owner));
				if (!cd.hasSetS("bumped", 1)) {
					bump(-dirTo(bullet.owner) * rnd(0.005, 0.01), -rnd(0.02, 0.04));
				}
				aggro(hero);
			} else {
				if (!cd.hasSetS("bumped", 1)) {
					bump(-dirTo(from) * rnd(0.005, 0.01), -rnd(0.02, 0.04));
				}
			}
		}
	}

	override function onDie() {
		super.onDie();

		calculateDrop();
		calculateCollectibles();
	}

	function calculateDrop() {
		var dropList = new dn.RandList();
		dropList.add(None, 95);
		dropList.add(Syringe, 5);

		var result = dropList.draw();
		if (result != null) {
			var drop = switch (result) {
				case Syringe:
					new entity.item.Syringe(cx, cy);
				case _: null;
			}
			if (drop != null) {
				drop.dx = -lastHitDirToSource * rnd(0.2, 0.4);
				drop.dy = rnd(-0.4, -0.2);
			}
		}
	}

	function calculateCollectibles() {
		var dropList = new dn.RandList();
		dropList.add(None, 35);
		dropList.add(Coin, 35);
		dropList.add(CrystalShard, 30);

		var result = dropList.draw();
		if (result != null) {
			switch (result) {
				case CrystalShard:
					var bonus = game.permaUpgrades.bonusShardsLvl * 0.01;
					var max = irnd(entity.collectible.CrystalShard.MIN_DROP, entity.collectible.CrystalShard.MAX_DROP);
					max += M.ceil(max * bonus);
					for (i in 0...max) {
						var drop = new entity.collectible.CrystalShard(cx, cy);
						drop.dx = rnd(-0.5, 0.5);
						drop.dy = rnd(-0.5, 0.3);
					}
				case Coin:
					var bonus = game.permaUpgrades.bonusCoinsLvl * 0.01;
					var max = irnd(entity.collectible.CoinShard.MIN_DROP, entity.collectible.CoinShard.MAX_DROP);
					max += M.ceil(max * bonus);
					for (i in 0...max) {
						var drop = new entity.collectible.CoinShard(cx, cy);
						drop.dx = rnd(-0.75, 0.75);
						drop.dy = rnd(-0.75, 0.75);
					}
				case _:
					null;
			}
		}
	}

	public function canBePushed() {
		return true;
	}

	public function aggro(e:Entity) {
		cd.setS("keepAggro", 5);

		if (aggroTarget == e)
			return false;

		aggroTarget = e;
		return true;
	}

	override function update() {
		super.update();

		if (onGround) {
			cd.setS("airControl", 0.5);
		}

		if (!isConscious()) {
			return;
		}
		if (data.f_canAttack) {
			checkIfAggroLost();
			checkToAggroHero();
		}

		var spd = baseSpd * (0.2 + 0.8 * cd.getRatio("airControl"));
		if (!targetAggroed) {
			spd *= 0.5;
		}
		if (tx > 0) {
			moveToTarget(spd);
		}
		if (!controlsLocked() && !hasAffect(Stun)) {
			if (aggroTarget != null && data.f_canAttack) {
				handleAggroTarget(spd);
			} else if (data.f_patrol == null && data.f_patrolType == AutoPatrol) {
				autoPatrol(spd);
			} else if (patrolTarget != null && data.f_patrolType == FixedPatrol) {
				fixedPatrol(spd);
			} else {
				performBusyWork();
			}

			if (level.hasMark(SmallStep, cx, cy, dir)) {
				if ((dir == 1 && xr >= 0.7) || (dir == -1 && xr <= 0.3)) {
					hopSmallStep(dir);
				}
			}
		}
	}

	private function checkIfAggroLost() {
		if (aggroTarget != null && (!cd.has("keepAggro") || aggroTarget.destroyed)) {
			lockControlS(1);
			aggroTarget = null;
			setSquashX(0.8);
		}
	}

	private function checkToAggroHero() {
		if (hero.isAlive() && distCase(hero) <= aggroRange && onGround && M.fabs(cy - hero.cy) <= 2 && sightCheck(hero)) {
			if (aggro(hero)) {
				cd.setS("initialAttackCooldown", initialAttackCooldown);
				dir = dirTo(aggroTarget);
				lockControlS(0.5);
				setSquashX(0.6);
				bump(0, -0.1);
				onTargetAggroed();
			}
		}
	}

	private function onTargetAggroed() {
		targetAggroed = true;
	}

	private function handleAggroTarget(spd:Float) {
		if (sightCheck(aggroTarget) && distCase(hero) <= aggroRange && distCase(hero) > attackRange) {
			dir = dirTo(aggroTarget);
			dx += spd * 1.2 * dir * tmod;
		} else if (sightCheck(aggroTarget) && distCase(hero) <= aggroRange && distCase(hero) <= attackRange) {
			dir = dirTo(aggroTarget);
			if (!cd.hasSetS("attackCooldown", attackCd) && !cd.has("initialAttackCooldown")) {
				attack();
			}
		} else {
			if (!cd.hasSetS("aggroSearch", rnd(0.5, 0.9))) {
				dir *= -1;
				cd.setS("aggroWander", rnd(0.1, 0.4));
			}
			if (cd.has("aggroWander")) {
				dx += spd * 2 * dir * tmod;
			}
		}
	}

	private function autoPatrol(spd:Float) {
		dx += spd * dir * tmod;

		if ((level.hasMark(PlatformEndLeft, cx, cy)
			&& dir == -1
			&& xr < 0.5
			|| level.hasMark(PlatformEndRight, cx, cy)
			&& dir == 1
			&& xr > 0.5)
			&& !level.hasMark(SmallStep, cx, cy, dir)) {
			lockControlS(0.5);
			setSquashX(0.85);
			dir *= -1;
		}
	}

	private function fixedPatrol(spd:Float) {
		dir = patrolTarget.centerX > centerX ? 1 : -1;
		dx += spd * dir * tmod;
		if (cx == patrolTarget.cx && cy == patrolTarget.cy && onGround && M.fabs(xr - 0.5) <= 0.3) {
			patrolTarget.cx = patrolTarget.cx == origin.cx ? data.f_patrol.cx : origin.cx;
			patrolTarget.cy = patrolTarget.cy == origin.cy ? data.f_patrol.cy : origin.cy;
			setSquashX(0.85);
			lockControlS(0.5);
		}
	}

	private function performBusyWork() {}

	private function hopSmallStep(dir:Int) {
		bdy = 0;
		dy = -0.25;
		dx = dir * 0.1;
		xr = dir == 1 ? 0.7 : 0.3;
	}

	private function attack() {}

	override function onTouchGround(fallHeight:Float) {
		super.onTouchGround(fallHeight);

		if (fallHeight >= 5) {
			fallDamage(Std.int(fallHeight * 10));
		}
	}

	override function onFallDamage(dmg:Int) {
		super.onFallDamage(dmg);
		if (life <= 0) {
			shouldSpawnDeadBody = false;
			//	fx.fallBloodSplatter(centerX, centerY);
		}
	}

	override function postUpdate() {
		super.postUpdate();
		spr.anim.setGlobalSpeed(rnd(0.15, 0.25));
	}
}
