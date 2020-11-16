package entity;

class UIEntity extends ScaledEntity {
	private var entityUpdatedListener:(e:Entity) -> Void;
	private var offsetXr:Float = 0;
	private var offsetYr:Float = 0;

	public function new(x:Int = 0, y:Int = 0) {
		super(x, y);
		hasGravity = false;
		isCollidable = false;
		spr.set("empty");
		entityUpdatedListener = (e:Entity) -> {
			cx = e.cx;
			cy = e.cy;
			xr = e.xr + offsetXr;
			yr = e.yr + offsetYr;
		}
	}

	/**
	 * Follow entity on scroller.
	 * @param entity the entity to follow
	 * @param offsetXr the amount of grid coords to offset on the x coord
	 * @param offsetYr the amopunt of grid coords to offset on the y coord
	 */
	public function follow(entity:Entity, offsetXr:Float = 0, offsetYr:Float = 0) {
		this.offsetXr = offsetXr;
		this.offsetYr = offsetYr;
		entity.registerEntityUpdatedListener(entityUpdatedListener);
	}

	public function unfollow(entity:Entity) {
		entity.unregisterEntityUpdatedListeber(entityUpdatedListener);
	}

	override function hit(dmg:Int, from:Null<Entity>) {}

	override function performEntityCollisions() {}

	override function performXCollisionCheck() {}

	override function performYCollisionCheck() {}
}
