package entity;

class Bullet extends ScaledEntity {
	public function new(from:Entity) {
		super(from.cx, from.cy);

		yr = from.yr - 0.5;
		dir = from.dir;
		hasGravity = false;
		spr.set("fxDot");
		dx = dir * 0.5;
		frictX = 1;
	}

	override function onCollision(fromX:Int, fromY:Int) {
		super.onCollision(fromX, fromY);

		destroy();
	}
}
