package entity;

class Water extends Entity {
	var data:World.Entity_Water;

	public function new(data:World.Entity_Water) {
		super(data.cx, data.cy, false);
		hasGravity = false;
		Game.ME.scroller.add(spr, Const.DP_FRONT_DETAILS);
		spr.set("water");
		spr.blendMode = Add;
		hei = 8;

		var shadow = new h2d.filter.DropShadow(0, -90, 0x8C96E8, 0.4, 0, 8, 1);
		spr.filter = new h2d.filter.Group([shadow]);
	}

	override function onTouching(from:Entity) {
		super.onTouching(from);

		if (from.is(Character) && (from.dx != 0 || from.dy != 0)) {
			fx.water(from.footX, headY);
		}
	}
}
