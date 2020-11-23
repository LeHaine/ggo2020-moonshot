package entity.mob;

class MutantMelee extends Mob {
	public function new(data:World.Entity_Mob) {
		super(data);

		initLife(50);

		damage = 30;
		hei = 14;
		attackCd = 1;
		attackRange = 1.5;
		spr.anim.registerStateAnim("mutantJumperIdle", 0);
		spr.anim.registerStateAnim("mutantJumperRun", 5, 2.5, () -> M.fabs(dx) >= 0.04 * tmod);

		spr.anim.onEnterFrame = (frame) -> {
			if (!spr.anim.isPlaying("mutantJumperAttack")) {
				return;
			}
			if (frame != 1) {
				return;
			}
			if (distCase(aggroTarget) <= attackRange) {
				var dmgVariance = M.ceil(damage * 0.15);
				aggroTarget.hit(irnd(damage - dmgVariance, damage + dmgVariance), this);
				aggroTarget.bump(0, -rnd(0.15, 0.25));
			}
		};
	}

	override function hit(dmg:Int, from:Null<Entity>) {
		super.hit(dmg, from);

		if (isAlive()) {
			spr.anim.playOverlap("mutantJumperHit", 0.66);
		}
	}

	override function attack() {
		super.attack();
		spr.anim.play("mutantJumperAttack", 1);
	}

	override function onDie() {
		super.onDie();
		new DeadBody(this, "mutantJumper", false, false);
	}
}
