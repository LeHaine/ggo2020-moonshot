package entity.mob;

class Scientist extends Mob {
	public function new(data:World.Entity_Mob) {
		super(data);

		spr.set("scientistStandShoot");
	}

	override function onDie() {
		super.onDie();
		new DeadBody(this, "scientist");
	}
}
