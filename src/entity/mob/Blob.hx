package entity.mob;

class Blob extends Mob {
	var explosionRadius = 3;

	public function new(data:World.Entity_Mob) {
		super(data);

		initLife(20);
		damage = 50;
		hei = 16;
		attackCd = 1;
		attackRange = 2;
		spr.anim.registerStateAnim("blobIdle", 0);
		spr.anim.registerStateAnim("blobRoll", 5, 1.25, () -> M.fabs(dx) >= 0.02 * tmod && M.fabs(dx) < 0.04 * tmod);
		spr.anim.registerStateAnim("blobRoll", 6, 2.5, () -> M.fabs(dx) >= 0.04 * tmod);

		spr.anim.onEnterFrame = (frame) -> {
			if (!spr.anim.isPlaying("blobExplode")) {
				return;
			}
			if (frame != 3) {
				return;
			}
			kill(this);
		};
	}

	override function hit(dmg:Int, from:Null<Entity>) {
		super.hit(dmg, from);

		if (isAlive()) {
			blink(0xb53822);
		}
	}

	override function attack() {
		super.attack();
		spr.anim.play("blobExplode", 1);
		lockControlS(3);
	}

	override function onDie() {
		super.onDie();
		fx.blobExplosion(centerX, centerY, explosionRadius);
		Assets.SLIB.blobExplosion0().playOnGroup(Const.MOB_EXTRA, 0.7);

		if (distCase(aggroTarget) <= explosionRadius) {
			var dmgVariance = M.ceil(damage * 0.15);
			aggroTarget.hit(irnd(damage - dmgVariance, damage + dmgVariance), this);
			aggroTarget.bump(0, -rnd(0.15, 0.25));
		}
	}
}
