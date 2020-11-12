package entity.mob.scientist;

class ScientistHammer extends Mob {
	private var targetAggroed:Bool;

	public function new(data:World.Entity_Mob) {
		super(data);

		attackRange = 2;
		attackCd = 3;
		baseSpd = 0.02;
		spr.anim.registerStateAnim("scientistHammerIdle", 0);
		spr.anim.registerStateAnim("scientistHammerIdleHammer", 1, () -> targetAggroed);
		spr.anim.registerStateAnim("scientistHammerRunHammer", 5, 2.5, () -> targetAggroed && M.fabs(dx) >= 0.04 * tmod);

		spr.anim.onEnterFrame = (frame) -> {
			if (!spr.anim.isPlaying("scientistHammerSwing")) {
				return;
			}
			if (frame != 2) {
				return;
			}
			camera.bump(0, rnd(0.1, 0.15));
			camera.shakeS(0.2, 0.5);
			if (distCase(hero) <= attackRange) {
				hero.hit(3, this);
				hero.bump(0, -rnd(0.15, 0.25));
			}
		};
	}

	override function hit(dmg:Int, from:Null<Entity>) {
		super.hit(dmg, from);

		if (isAlive()) {
			spr.anim.playOverlap("scientistHammerHit", 0.66);
		}
	}

	override function attack() {
		lockControlS(1);
		spr.anim.play("scientistHammerSwing");
	}

	override function onTargetAggroed() {
		spr.anim.playOverlap("scientistHammerHammerDraw");
		targetAggroed = true;
	}

	override function performBusyWork() {}

	override function onDie() {
		super.onDie();
		new DeadBody(this, "scientistHammer");
	}
}
