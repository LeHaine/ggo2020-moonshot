package entity.boss;

enum BossPhase {
	INTRO;
	PHASE_1;
	PHASE_1_END;
	PHASE_2_INIT;
	PHASE_2;
	PHASE_3_TARGET_WALK;
	PHASE_3_WALK;
	PHASE_3_TARGET_FLY_UP;
	PHASE_3_FLY_UP;
	PHASE_3;
}

class Boss extends Character {
	var data:World.Entity_Boss;

	var phase:BossPhase;

	var floating:Bool;
	var firingMoonBlast:Bool;
	var usingHammer:Bool;
	var usingGun:Bool;

	var gunDamage = 10;
	var gunRange = 20;
	var minGunCd = 2;
	var maxGunCd = 4;
	var gunSpeed = 0.02;

	var meleeSpeed = 0.029;
	var meleeDamage = 20;
	var meleeRange = 2.25;
	var minMeleeCd = 0.5;
	var maxMeleeCd = 3;

	var floatSpeed = 0.03;
	var moonBlastCdMin = 0.15;
	var moonBlastCdMax = 0.75;
	var moonBlastDamge = 50;

	var playingIntro = false;

	#if debug
	var debugUi:UIEntity;
	var phaseDebugTf:h2d.Text;
	#end

	public function new(data:World.Entity_Boss) {
		super(data.cx, data.cy);
		this.data = data;

		dir = -1;
		initLife(1000 + (hero.traits.length * 100));
		renderHealthBar();
		healthBar.setSize(25, 2, 1);
		registerAnims();

		phase = INTRO;

		#if debug
		debugUi = new UIEntity(0, -5);
		debugUi.follow(this);
		phaseDebugTf = new h2d.Text(Assets.fontPixelSmall, debugUi.spr);
		#end
	}

	function registerAnims() {
		spr.anim.registerStateAnim("bossIdle", 0);
		spr.anim.registerStateAnim("bossIdleGunDown", 1,
			() -> phase == PHASE_1 && usingGun && cd.getRatio("attackCooldown") > 0.25 && !cd.has("gunDownDelay"));
		spr.anim.registerStateAnim("bossIdleGunUp", 2,
			() -> phase == PHASE_1 && usingGun && (cd.getRatio("attackCooldown") <= 0.25 || cd.has("gunDownDelay")));
		spr.anim.registerStateAnim("bossRunGun", 5, 2.5, () -> phase == PHASE_1 && usingGun && M.fabs(dx) >= 0.04 * tmod);
		spr.anim.registerStateAnim("bossIdleHammer", 1, () -> (phase == PHASE_1 || phase == PHASE_2) && usingHammer);
		spr.anim.registerStateAnim("bossRunHammer", 5, 2.5, () -> (phase == PHASE_1 || phase == PHASE_2)
			&& usingHammer
			&& M.fabs(dx) >= 0.04 * tmod);
		spr.anim.registerStateAnim("bossFloatUp", 5, 2.5, () -> (phase == PHASE_3_FLY_UP || phase == PHASE_3) && floating);
		spr.anim.registerStateAnim("bossMoonBlast", 5, 2.5, () -> (phase == PHASE_3_FLY_UP || phase == PHASE_3)
			&& floating
			&& firingMoonBlast);

		spr.anim.onEnterFrame = (frame) -> {
			if (!spr.anim.isPlaying("bossHammerSwing")) {
				return;
			}
			if (frame != 2) {
				return;
			}
			Assets.SLIB.groundHit0().playOnGroup(Const.MOB_ATTACK, 0.7);
			camera.bump(0, rnd(0.1, 0.15));
			camera.shakeS(0.2, 0.5);
			if (distCase(hero) <= meleeRange) {
				var dmgVariance = M.ceil(meleeDamage * 0.15);
				hero.hit(irnd(meleeDamage - dmgVariance, meleeDamage + dmgVariance), this);
				hero.bump(0, -rnd(0.15, 0.25));
			}
		};
	}

	override function hit(dmg:Int, from:Null<Entity>) {
		super.hit(dmg, from);

		if (isAlive()) {
			if (usingHammer) {
				spr.anim.playOverlap("bossHammerHit", 0.66);
			}

			if (usingGun) {
				spr.anim.playOverlap("bossGunHit", 0.66);
			}
		}
	}

	override function update() {
		super.update();

		#if debug
		phaseDebugTf.text = Std.string(phase);
		#end

		switch phase {
			case INTRO:
				if (!playingIntro) {
					playingIntro = true;
					var id = game.settings.visitedBoss ? BossRoomEnter : FirstBossRoomEnter;
					new CinematicControl(id, new CPoint(cx, cy, xr, yr), () -> {
						phase = PHASE_1;
					});
				}
			case PHASE_1:
				var lifePercent = life / maxLife;
				if (lifePercent <= 0.75) {
					hero.setAffectS(Stun, 3);
					cd.setS("scream", 3);
					camera.shakeS(3, 0.05);
					spr.anim.playAndLoop("bossScream");
					Assets.SLIB.bossYell0().playOnGroup(Const.MOB_EXTRA, 0.7);
					isCollidable = false;
					phase = PHASE_1_END;
				} else if (!controlsLocked()) {
					if (!cd.hasSetS("chooseAttack", 10)) {
						var rnd = irnd(0, 1);
						usingGun = rnd == 0;
						usingHammer = rnd != 0;
					}
					var speed = usingGun ? gunSpeed : meleeSpeed;
					moveToHero(speed);
					attackIfInRange();
				}
			case PHASE_1_END:
				if (!cd.has("scream")) {
					phase = PHASE_2_INIT;
					spr.anim.stopWithStateAnims();
				}
			case PHASE_2_INIT:
				isCollidable = true;
				usingGun = false;
				usingHammer = true;

				sprScaleX = 1.5;
				sprScaleY = 1.5;

				meleeSpeed *= 1.25;
				phase = PHASE_2;
			case PHASE_2:
				var lifePercent = life / maxLife;
				if (lifePercent <= 0.40) {
					phase = PHASE_3_TARGET_WALK;
				} else if (!controlsLocked()) {
					moveToHero(meleeSpeed);
					attackIfInRange();
				}
			case PHASE_3_TARGET_WALK:
				isCollidable = false;
				var target = new CPoint(data.f_phase_3_point.cx, data.f_phase_3_point.cy);
				moveTo(target.cx, target.cy);
				phase = PHASE_3_WALK;
			case PHASE_3_WALK:
				moveToTarget(gunSpeed);
				if (tx == -1 && ty == -1) {
					phase = PHASE_3_TARGET_FLY_UP;
				}
			case PHASE_3_TARGET_FLY_UP:
				hasGravity = false;
				var target = new CPoint(data.f_phase_3_fly_point.cx, data.f_phase_3_fly_point.cy);
				moveTo(target.cx, target.cy);
				phase = PHASE_3_FLY_UP;
			case PHASE_3_FLY_UP:
				floating = true;
				moveToTarget(floatSpeed);
				if (tx == -1 && ty == -1) {
					isCollidable = true;
					phase = PHASE_3;
				}
			case PHASE_3:
				if (!cd.hasSetS("dirChange", 2) && irnd(0, 1) == 0) {
					var dirToHero = dirTo(hero);
					if (dir != dirToHero) {
						dir = dir == 1 ? -1 : 1;
					}
				}
				dx += dir * floatSpeed * tmod;
				if (!cd.hasSetS("attackCooldown", rnd(moonBlastCdMin, moonBlastCdMax))) {
					attack();
				}
		}
	}

	override function postUpdate() {
		super.postUpdate();
		spr.anim.setGlobalSpeed(0.2);
	}

	override function dispose() {
		super.dispose();
		#if debug
		debugUi.destroy();
		#end
	}

	override function onTouchWall(wallDir:Int) {
		super.onTouchWall(wallDir);
		if (phase == PHASE_3) {
			dir = wallDir == 1 ? -1 : 1;
			setSquashX(0.95);
		}
	}

	override function onDie() {
		super.onDie();
		game.bossKilled = true;
		dropCollectibles();
		new DeadBody(this, "boss", false, false);
	}

	function dropCollectibles() {
		var bonus = game.permaUpgrades.bonusShardsLvl * 0.01;
		var max = irnd(entity.collectible.CrystalShard.MIN_DROP, entity.collectible.CrystalShard.MAX_DROP);
		max += M.ceil(max * bonus);
		for (i in 0...max) {
			var drop = new entity.collectible.CrystalShard(cx, cy, 2);
			drop.dx = rnd(-0.5, 0.5);
			drop.dy = rnd(-0.5, 0.3);
		}

		var bonus = game.permaUpgrades.bonusCoinsLvl * 0.01;
		var max = irnd(entity.collectible.CoinShard.MIN_DROP, entity.collectible.CoinShard.MAX_DROP);
		max += M.ceil(max * bonus);
		for (i in 0...max) {
			var drop = new entity.collectible.CoinShard(cx, cy);
			drop.dx = rnd(-0.75, 0.75);
			drop.dy = rnd(-0.75, 0.75);
		}
	}

	function moveToHero(speed:Float) {
		var attackRange = usingGun ? gunRange : meleeRange;
		if (sightCheck(hero) && distCase(hero) > attackRange) {
			dir = dirTo(hero);
			dx += speed * 1.2 * dir * tmod;
		}
	}

	function attackIfInRange() {
		var attackRange = usingGun ? gunRange : meleeRange;
		var minCd = usingGun ? minGunCd : minMeleeCd;
		var maxCd = usingGun ? minGunCd : minMeleeCd;
		var attackCd = rnd(minCd, maxCd);
		if (sightCheck(hero) && distCase(hero) <= attackRange) {
			dir = dirTo(hero);
			if (!cd.hasSetS("attackCooldown", attackCd)) {
				attack();
			}
		}
	}

	function attack() {
		if (phase == PHASE_1 || phase == PHASE_2) {
			if (usingHammer) {
				lockControlS(rnd(1, 1.5));
				spr.anim.play("bossHammerSwing");
			} else if (usingGun) {
				lockControlS(1);
				spawnPrimaryBullet();
				Assets.SLIB.shot0().playOnGroup(Const.MOB_ATTACK, 0.8);
				cd.setS("gunDownDelay", 0.5);
			}
		} else if (phase == PHASE_3) {
			performMoonBlast();
			camera.shakeS(0.3, 0.1);
			spr.anim.play("bossMoonBlast");
		}
	}

	function spawnPrimaryBullet() {
		setSquashX(0.85);
		var bulletX = centerX + (dir * 3);
		var bulletY = centerY - 6;
		var angToTarget = dirToAng();
		var dmgVariance = M.ceil(gunDamage * 0.15);
		fx.normalShot(bulletX, bulletY, angToTarget, 0x292929, 10);
		var bullet = new Bullet(M.round(bulletX), M.round(bulletY), this, angToTarget, irnd(gunDamage - dmgVariance, gunDamage + dmgVariance));
		bullet.damageRadiusMul = 0.15;
		return bullet;
	}

	function performMoonBlast() {
		Assets.SLIB.shot1().playOnGroup(Const.MOB_ATTACK, 0.7);
		setSquashX(0.85);
		var bulletX = centerX + (dir * 4);
		var bulletY = centerY + 4;
		var angToTarget = M.PIHALF;
		var dmgVariance = M.ceil(moonBlastDamge * 0.15);
		fx.normalShot(bulletX, bulletY, angToTarget, 0x292929, 10);
		var bullet = new Bullet(M.round(bulletX), M.round(bulletY), this, angToTarget, irnd(moonBlastDamge - dmgVariance, moonBlastDamge + dmgVariance));
		bullet.damageRadiusMul = 0.45;
		bullet.damageRadius = 3;
		bullet.setSize(10);
		bullet.doesAoeDamage = true;
		bullet.shouldBump = true;
		return bullet;
	}
}
