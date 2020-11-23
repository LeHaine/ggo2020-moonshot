package entity;

class AcidProjectile extends Bullet {
	public function new(x:Int, y:Int, owner:Entity, angle:Float, damage:Int = 1) {
		super(x, y, owner, angle, damage);
		spr.set("acidProjectile");
		width = 5;
		hei = 3;

		trailColor = 0x6abe30;
	}

	override function onBulletCollision() {
		fx.acidExplosion(centerX, centerY);
		destroy();
	}
}
