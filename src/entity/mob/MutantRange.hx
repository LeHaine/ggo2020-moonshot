package entity.mob;

class MutantRange extends Mob {
	public function new(data:World.Entity_Mob) {
		super(data);

		initLife(50);

		damage = 30;
		hei = 14;
		attackCd = 1.75;
		attackRange = 10;
		spr.anim.registerStateAnim("mutantJumperIdle", 0);
		spr.anim.registerStateAnim("mutantJumperRun", 5, 2.5, () -> M.fabs(dx) >= 0.04 * tmod);

		spr.anim.onEnterFrame = (frame) -> {
			if (!spr.anim.isPlaying("mutantJumperRangeAttack")) {
				return;
			}
			if (frame != 1) {
				return;
			}
			spawnAcid();
		};
	}

	function spawnAcid() {
		setSquashX(0.85);
		var acidX = centerX + (dir * 3);
		var acidY = centerY - 6;
		var angToTarget = dirToAng();
		var dmgVariance = M.ceil(damage * 0.15);
		fx.normalShot(acidX, acidY, angToTarget, 0x292929, distPx(aggroTarget));
		var acid = new AcidProjectile(M.round(acidX), M.round(acidY), this, angToTarget + rnd(-2, 2) * M.DEG_RAD,
			irnd(damage - dmgVariance, damage + dmgVariance));
		acid.damageRadiusMul = 0.15;
		return acid;
	}

	override function hit(dmg:Int, from:Null<Entity>) {
		super.hit(dmg, from);

		if (isAlive()) {
			spr.anim.playOverlap("mutantJumperHit", 0.66);
		}
	}

	override function attack() {
		super.attack();
		spr.anim.play("mutantJumperRangeAttack", 1);
	}

	override function onDie() {
		super.onDie();
		new DeadBody(this, "mutantJumper", false, false);
	}
}
