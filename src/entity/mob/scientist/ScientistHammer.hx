package entity.mob.scientist;

class ScientistHammer extends Mob {
	public function new(data:World.Entity_Mob) {
		super(data);

		initLife(40);
		damage = 13;
		attackRange = 2.5;
		attackCd = 3;
		baseSpd = 0.02;
		spr.anim.registerStateAnim("scientistHammerIdle", 0);
		spr.anim.registerStateAnim("scientistHammerWalk", 3, 2.5, () -> !targetAggroed && M.fabs(dx) >= 0.02 * tmod);
		spr.anim.registerStateAnim("scientistHammerIdleHammer", 1, () -> targetAggroed);
		spr.anim.registerStateAnim("scientistHammerRunHammer", 5, 2.5, () -> targetAggroed && M.fabs(dx) >= 0.04 * tmod);

		spr.anim.onEnterFrame = (frame) -> {
			if (!spr.anim.isPlaying("scientistHammerSwing")) {
				return;
			}
			if (frame != 2) {
				return;
			}
			Assets.SLIB.groundHit0().playOnGroup(Const.MOB_ATTACK, 0.7);
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
			spr.anim.playOverlap("scientistHammerHit", 0.66);
		}
	}

	override function attack() {
		lockControlS(1);
		spr.anim.play("scientistHammerSwing");
	}

	override function onTargetAggroed() {
		super.onTargetAggroed();
		spr.anim.playOverlap("scientistHammerHammerDraw");
	}

	override function performBusyWork() {}

	override function onDie() {
		super.onDie();
		new DeadBody(this, "scientistHammer");
	}
}
