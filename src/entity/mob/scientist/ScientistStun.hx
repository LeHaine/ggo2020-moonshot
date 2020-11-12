package entity.mob.scientist;

class ScientistStun extends Mob {
	private var targetAggroed:Bool;

	public function new(data:World.Entity_Mob) {
		super(data);

		attackRange = 10;
		spr.anim.registerStateAnim("scientistStunIdle", 0);
		spr.anim.registerStateAnim("scientistStunIdleGunDown", 1, () -> targetAggroed && aggroTarget == null);
		spr.anim.registerStateAnim("scientistStunIdleGunUp", 2, () -> targetAggroed && aggroTarget != null);
		spr.anim.registerStateAnim("scientistStunRunGun", 5, 2.5, () -> targetAggroed && M.fabs(dx) >= 0.04 * tmod);
	}

	override function hit(dmg:Int, from:Null<Entity>) {
		super.hit(dmg, from);

		if (isAlive()) {
			spr.anim.playOverlap("scientistStunHit", 0.66);
		}
	}

	override function attack() {
		spawnPrimaryBullet();
	}

	private function spawnPrimaryBullet(damage:Int = 1, bounceMul:Float = 0., doesAoeDamage:Bool = false) {
		setSquashX(0.85);
		var bulletX = centerX + (dir * 3);
		var bulletY = centerY - 6;
		var angToTarget = angTo(aggroTarget);
		bdx = rnd(0.1, 0.15) * bounceMul * -Math.cos(angToTarget);
		bdy = rnd(0.1, 0.15) * bounceMul * -Math.sin(angToTarget);
		fx.normalShot(bulletX, bulletY, angToTarget, 0x292929, distPx(aggroTarget));
		var bullet = new Bullet(M.round(bulletX), M.round(bulletY), this, angToTarget + rnd(-5, 5) * M.DEG_RAD, damage);
		bullet.damageRadiusMul = 0.15;
		return bullet;
	}

	override function onTargetAggroed() {
		spr.anim.playOverlap("scientistStunGunDraw");
		targetAggroed = true;
	}

	override function performBusyWork() {}

	override function onDie() {
		super.onDie();
		new DeadBody(this, "scientistStun");
	}
}
