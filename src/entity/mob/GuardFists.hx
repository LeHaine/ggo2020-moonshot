package entity.mob;

class GuardFists extends Mob {
	private var targetAggroed:Bool;

	public function new(data:World.Entity_Mob) {
		super(data);

		initLife(40);
		damage = 10;
		attackRange = 1.25;
		attackCd = 0.25;
		baseSpd = 0.025;
		spr.anim.registerStateAnim("guardFistsIdle", 0);
		spr.anim.registerStateAnim("guardFistsIdleFists", 1, () -> targetAggroed);
		spr.anim.registerStateAnim("guardFistsRunFists", 5, 2.5, () -> targetAggroed && M.fabs(dx) >= 0.04 * tmod);
	}

	override function hit(dmg:Int, from:Null<Entity>) {
		super.hit(dmg, from);

		if (isAlive()) {
			spr.anim.playOverlap("guardFistsHit", 0.66);
		}
	}

	override function attack() {
		lockControlS(1);
		var fist = irnd(0, 1);
		if (fist == 0) {
			spr.anim.play("guardFistsLeftFist");
		} else {
			spr.anim.play("guardFistsRightFist");
		}

		camera.bump(0, rnd(0.1, 0.15));
		camera.shakeS(0.1, 0.25);
		if (distCase(hero) <= attackRange) {
			var dmgVariance = M.ceil(damage * 0.15);
			hero.hit(irnd(damage - dmgVariance, damage + dmgVariance), this);
			hero.bump(rnd(0.05, 0.15) * dirTo(hero), -rnd(0.05, 0.15));
		}
	}

	override function onTargetAggroed() {
		targetAggroed = true;
	}

	override function performBusyWork() {}

	override function onDie() {
		super.onDie();
		new DeadBody(this, "guardFists");
	}
}
