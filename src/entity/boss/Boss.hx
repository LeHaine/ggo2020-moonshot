package entity.boss;

enum BossPhase {
	INTRO;
	PHASE_1;
	PHASE_2;
	PHASE_3;
}

class Boss extends Character {
	var targetAggroed:Bool;
	var floating:Bool;
	var firingMoonBlast:Bool;
	var usingHammer:Bool;
	var usingGun:Bool;
	var phase:BossPhase;
	var data:World.Entity_Boss;
	var damage = 10;
	var attackRange = 10;

	public function new(data:World.Entity_Boss) {
		super(data.cx, data.cy);
		this.data = data;

		initLife(1000);
		registerAnims();

		phase = INTRO;
	}

	function registerAnims() {
		spr.anim.registerStateAnim("bossIdle", 0);
		spr.anim.registerStateAnim("bossIdleGunDown", 1, () -> phase == PHASE_1 && usingGun);
		spr.anim.registerStateAnim("bossIdleGunUp", 2, () -> phase == PHASE_1 && usingGun);
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
			if (distCase(hero) <= attackRange) {
				var dmgVariance = M.ceil(damage * 0.15);
				hero.hit(irnd(damage - dmgVariance, damage + dmgVariance), this);
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
	}

	function attack() {
		if (usingHammer) {
			lockControlS(1);
			spr.anim.play("bossHammerSwing");
		}

		if (usingGun) {
			spawnPrimaryBullet();
		}
	}

	function spawnPrimaryBullet() {
		setSquashX(0.85);
		var bulletX = centerX + (dir * 3);
		var bulletY = centerY - 6;
		var angToTarget = angTo(hero);
		var dmgVariance = M.ceil(damage * 0.15);
		fx.normalShot(bulletX, bulletY, angToTarget, 0x292929, distPx(hero));
		var bullet = new Bullet(M.round(bulletX), M.round(bulletY), this, angToTarget + rnd(-5, 5) * M.DEG_RAD,
			irnd(damage - dmgVariance, damage + dmgVariance));
		bullet.damageRadiusMul = 0.15;
		return bullet;
	}
}
