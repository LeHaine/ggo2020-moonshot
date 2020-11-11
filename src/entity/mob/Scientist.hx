package entity.mob;

class Scientist extends Mob {
	public function new(data:World.Entity_Mob) {
		super(data);

		spr.anim.registerStateAnim("scientistIdleGunDown", 0);
	}

	override function hit(dmg:Int, from:Null<Entity>) {
		super.hit(dmg, from);

		if (isAlive()) {
			spr.anim.playOverlap("scientistHit", 0.66);
		}
	}

	override function attack() {}

	override function onTargetAggroed() {}

	override function performBusyWork() {}

	override function onDie() {
		super.onDie();
		new DeadBody(this, "scientist");
	}
}
