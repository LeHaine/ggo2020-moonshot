package entity.mob;

class Scientist extends Mob {
	public function new(x, y) {
		super(x, y);

		spr.set("scientistStandShoot");
	}

	override function onDie() {
		super.onDie();
		new DeadBody(this, "scientist");
	}
}
