package entity.mob.scientist;

class ScientistPistol extends Mob {
	private var targetAggroed:Bool;

	public function new(data:World.Entity_Mob) {
		super(data);

		damage = 10;
		attackRange = 10;
		spr.anim.registerStateAnim("scientistPistolIdle", 0);
		spr.anim.registerStateAnim("scientistPistolIdleGunDown", 1, () -> targetAggroed && aggroTarget == null);
		spr.anim.registerStateAnim("scientistPistolIdleGunUp", 2, () -> targetAggroed && aggroTarget != null);
		spr.anim.registerStateAnim("scientistPistolRunGun", 5, 2.5, () -> targetAggroed && M.fabs(dx) >= 0.04 * tmod);
	}

	override function hit(dmg:Int, from:Null<Entity>) {
		super.hit(dmg, from);

		if (isAlive()) {
			spr.anim.playOverlap("scientistPistolHit", 0.66);
		}
	}

	override function attack() {
		spawnPrimaryBullet();
	}

	private function spawnPrimaryBullet() {
		setSquashX(0.85);
		var bulletX = centerX + (dir * 3);
		var bulletY = centerY - 6;
		var angToTarget = angTo(aggroTarget);
		var dmgVariance = M.ceil(damage * 0.15);
		fx.normalShot(bulletX, bulletY, angToTarget, 0x292929, distPx(aggroTarget));
		var bullet = new Bullet(M.round(bulletX), M.round(bulletY), this, angToTarget + rnd(-5, 5) * M.DEG_RAD,
			irnd(damage - dmgVariance, damage + dmgVariance));
		bullet.damageRadiusMul = 0.15;
		return bullet;
	}

	override function onTargetAggroed() {
		spr.anim.playOverlap("scientistPistolGunDraw");
		targetAggroed = true;
	}

	override function performBusyWork() {}

	override function onDie() {
		super.onDie();
		new DeadBody(this, "scientistPistol");
	}
}
