package entity.mob;

class Rat extends Mob {
	public function new(data:World.Entity_Mob) {
		super(data);

		initLife(20);
		damage = 10;
		hei = 8;
		attackCd = 1;
		attackRange = 1.5;
		spr.anim.registerStateAnim("ratIdle", 0);
		spr.anim.registerStateAnim("ratRun", 5, 2.5, () -> M.fabs(dx) >= 0.04 * tmod);

		spr.anim.onEnterFrame = (frame) -> {
			if (!spr.anim.isPlaying("ratBite")) {
				return;
			}
			if (frame != 2) {
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
			spr.anim.playOverlap("ratHit", 0.66);
		}
	}

	override function attack() {
		super.attack();
		spr.anim.play("ratBite", 1);
	}

	override function onDie() {
		super.onDie();
		new DeadBody(this, "rat", false, false);
	}
}
