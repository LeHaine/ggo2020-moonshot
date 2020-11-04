package entity;

class Bullet extends ScaledEntity {
	public var ALL:Array<Bullet> = [];

	var owner:Entity;
	var speed = 0.5;

	public function new(x:Int, y:Int, owner:Entity, angle:Float) {
		super(0, 0);
		ALL.push(this);
		this.owner = owner;
		setPosPixel(x, y);
		dx = Math.cos(angle) * speed * tmod;
		dy = Math.sin(angle) * speed * tmod;

		spr.set("fxDot");
		spr.setCenterRatio();
		hei = 1;
		width = 1;
		radius = 0.5;
		hasGravity = false;
		frictX = 1;
		frictY = 1;
	}

	override function onTouch(from:Entity) {
		super.onTouch(from);

		if (from != owner) {
			from.hit(1, this);
			destroy();
		}
	}

	override function dispose() {
		super.dispose();
		ALL.remove(this);
	}

	override function onCollision(fromX:Int, fromY:Int) {
		super.onCollision(fromX, fromY);

		destroy();
	}
}
