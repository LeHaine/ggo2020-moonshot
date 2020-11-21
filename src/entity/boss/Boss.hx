package entity.boss;

enum BossPhase {
	INTRO;
	PHASE_1;
	PHASE_2;
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
	var gunRange = 15;
	var gunCd = 5;
	var gunSpeed = 0.02;

	var meleeSpeed = 0.027;
	var meleeDamage = 20;
	var meleeRange = 2;
	var meleeCd = 3;

	public function new(data:World.Entity_Boss) {
		super(data.cx, data.cy);
		this.data = data;

		initLife(2000);
		renderHealthBar();
		healthBar.setSize(25, 2, 1);
		registerAnims();

		phase = INTRO;
	}

	function registerAnims() {
		spr.anim.registerStateAnim("bossIdle", 0);
		spr.anim.registerStateAnim("bossIdleGunDown", 1,
			() -> phase == PHASE_1 && usingGun && cd.getRatio("attackCooldown") > 0.25 && !cd.has("gunDownDelay"));
		spr.anim.registerStateAnim("bossIdleGunUp", 2,
			() -> phase == PHASE_1 && usingGun && (cd.getRatio("attackCooldown") <= 0.25 || cd.has("gunDownDelay")));
		spr.anim.registerStateAnim("bossRunGun", 5, 2.5, () -> phase == PHASE_1 && usingGun && M.fabs(dx) >= 0.04 * tmod);
		spr.anim.registerStateAnim("bossIdleHammer", 1, () -> phase == PHASE_1 && usingHammer);
		spr.anim.registerStateAnim("bossRunHammer", 5, 2.5, () -> phase == PHASE_1 && usingHammer && M.fabs(dx) >= 0.04 * tmod);
		spr.anim.registerStateAnim("bossFloatUp", 5, 2.5, () -> phase == PHASE_3 && floating);
		spr.anim.registerStateAnim("bossMoonBlast", 5, 2.5, () -> phase == PHASE_3 && floating && firingMoonBlast);

		spr.anim.onEnterFrame = (frame) -> {
			if (!spr.anim.isPlaying("bossHammerSwing")) {
				return;
			}
			if (frame != 2) {
				return;
			}
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

		switch phase {
			case INTRO:
				phase = PHASE_1;
			case PHASE_1:
				var lifePercent = life / maxLife;
				if (lifePercent <= 0.33) {
					phase = PHASE_2;
				}
				if (!controlsLocked()) {
					if (!cd.hasSetS("chooseAttack", 10)) {
						var rnd = irnd(0, 1);
						usingGun = rnd == 0;
						usingHammer = rnd != 0;
					}
					var speed = usingGun ? gunSpeed : meleeSpeed;
					moveToHero(speed);
					attackIfInRange();
				}
			case PHASE_2:
			case PHASE_3:
		}
	}

	override function postUpdate() {
		super.postUpdate();
		spr.anim.setGlobalSpeed(0.2);
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
		var attackCd = usingGun ? gunCd : meleeCd;
		if (sightCheck(hero) && distCase(hero) <= attackRange) {
			dir = dirTo(hero);
			if (!cd.hasSetS("attackCooldown", attackCd)) {
				attack();
			}
		}
	}

	function attack() {
		if (usingHammer) {
			lockControlS(rnd(1, 1.5));
			spr.anim.play("bossHammerSwing");
		} else if (usingGun) {
			lockControlS(1);
			spawnPrimaryBullet();
			cd.setS("gunDownDelay", 0.5);
		}
	}

	function spawnPrimaryBullet() {
		setSquashX(0.85);
		var bulletX = centerX + (dir * 3);
		var bulletY = centerY - 6;
		var angToTarget = dirToAng();
		var dmgVariance = M.ceil(gunDamage * 0.15);
		fx.normalShot(bulletX, bulletY, angToTarget, 0x292929, distPx(hero));
		var bullet = new Bullet(M.round(bulletX), M.round(bulletY), this, angToTarget, irnd(gunDamage - dmgVariance, gunDamage + dmgVariance));
		bullet.damageRadiusMul = 0.15;
		return bullet;
	}
}
