package entity;

class CinematicTrigger extends Entity {
	var data:World.Entity_CinematicTrigger;

	public function new(data:World.Entity_CinematicTrigger) {
		super(data.cx, data.cy);
		this.data = data;

		hei = Const.GRID * 2;
		spr.set("empty");
		hasGravity = false;
		ignoreBullets = true;
	}

	override function onTouch(from:Entity) {
		super.onTouch(from);

		if (from.is(Hero)) {
			//	#if !debug
			new CinematicControl(data.f_id, data);
			//	#end
			destroy();
		}
	}
}
