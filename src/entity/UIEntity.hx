package entity;

class UIEntity extends NoScaleEntity {
	private var entityUpdatedListener:(e:Entity) -> Void;

	public function new(x:Int, y:Int) {
		super(x, y);
		hasGravity = false;
		spr.set("empty");
		entityUpdatedListener = (e:Entity) -> {
			cx = e.cx;
			cy = e.cy;
			xr = e.xr;
			yr = e.yr;
		}
	}

	public function follow(entity:Entity) {
		entity.registerEntityUpdatedListener(entityUpdatedListener);
	}

	public function unfollow(entity:Entity) {
		entity.unregisterEntityUpdatedListeber(entityUpdatedListener);
	}

	override function hit(dmg:Int, from:Null<Entity>) {}

	override function performXCollisionCheck() {}

	override function performYCollisionCheck() {}
}
