package entity;

enum Body {
	Head;
	Torso;
	Legs;
}

class Mob extends Character {
	public static var ALL:Array<Mob> = [];

	var lastBodyPartShot:Null<Body>;
	var data:World.Entity_Mob;

	var origin:CPoint;
	var patrolTarget:Null<CPoint>;
	var aggroTarget:Null<Entity>;

	var initialAttackCooldown = rnd(1, 2);
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

	inline function set_baseAggroRange(v:Float) {
		aggroRange = rnd(-aggroRangeVariance, aggroRangeVariance) * v + v;
		return baseAggroRange = v;
	}

	var aggroRange:Float;
	var attackRange = 8;

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

		baseAttackCooldown = 1.2;
		baseAggroRange = 15;
	}

	override function hit(dmg:Int, from:Null<Entity>) {
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
				if (bullet.owner.is(Mob)) {
					return;
				}
				fx.gibs(centerX, centerY, -dirTo(bullet.owner));
				bump(-dirTo(bullet.owner) * rnd(0.06, 0.12), -rnd(0.04, 0.08));
				aggro(hero);
			} else {
				bump(-dirTo(from) * rnd(0.06, 0.12), -rnd(0.04, 0.08));
			}
		}
		super.hit(dmg, from);
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

		checkIfAggroLost();
		checkToAggroHero();

		if (!controlsLocked()) {
			var spd = 0.01 * (0.2 + 0.8 * cd.getRatio("airControl"));

			if (aggroTarget != null) {
				handleAggroTarget(spd);
			} else if (data.f_patrol == null && data.f_patrolType == AutoPatrol) {
				autoPatrol(spd);
			} else if (data.f_patrolType == FixedPatrol) {
				fixedPatrol(spd);
			} else { // Busy work
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

	private function onTargetAggroed() {}

	private function handleAggroTarget(spd:Float) {
		if (sightCheck(aggroTarget) && distCase(hero) <= aggroRange && distCase(hero) > attackRange) {
			// Track aggro target
			dir = dirTo(aggroTarget);
			dx += spd * 1.2 * dir * tmod;
		} else if (sightCheck(aggroTarget) && distCase(hero) <= aggroRange && distCase(hero) <= attackRange) {
			dir = dirTo(aggroTarget);
			if (!cd.hasSetS("attackCooldown", attackCd) && !cd.has("initialAttackCooldown")) {
				attack();
			}
		} else {
			// Wander aggressively
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
		xr = dir == 1 ? 0.7 : 0.3;
	}

	private function attack() {}

	override function onTouchGround(fallHeight:Float) {
		super.onTouchGround(fallHeight);

		var impact = M.fmin(1, fallHeight / 6);
		dx *= (1 - impact) * 0.5;
		setSquashY(1 - impact * 0.7);

		if (fallHeight >= 9) {
			fallDamage(Std.int(fallHeight));
			lockControlS(0.3);
			cd.setS("heavyLand", 0.3);
		} else if (fallHeight >= 3) {
			lockControlS(0.03 * impact);
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
		spr.anim.setGlobalSpeed(rnd(0.1, 0.3));
	}
}
