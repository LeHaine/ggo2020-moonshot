package entity;

class Water extends Entity {
	var data:World.Entity_Water;

	public function new(data:World.Entity_Water) {
		super(data.cx, data.cy, false);
		hasGravity = false;
		ignoreBullets = true;
		Game.ME.scroller.add(spr, Const.DP_FRONT_DETAILS);
		spr.set("water");
		spr.blendMode = Add;
		hei = 8;

		var shadow = new h2d.filter.DropShadow(0, -90, 0x8C96E8, 0.4, 0, 8, 1);
		spr.filter = new h2d.filter.Group([shadow]);
	}

	override function onTouch(from:Entity) {
		super.onTouch(from);

		if (from.is(Character)) {
			var char = cast(from, Character);
			if (!char.inWater) {
				fx.waterSplash(from.footX, headY);
			}
		}
	}

	override function onTouching(from:Entity) {
		super.onTouching(from);

		if (from.is(Character) && (from.dx != 0 || from.dy != 0)) {
			fx.water(from.footX, headY);
		}
	}

	override function onTouchStop(from:Entity) {
		super.onTouchStop(from);

		if (from.is(Character)) {
			var char = cast(from, Character);
			if (char.touchingWaterEntites <= 1) {
				fx.waterSplash(from.footX, headY);
			}
		}
	}
}
