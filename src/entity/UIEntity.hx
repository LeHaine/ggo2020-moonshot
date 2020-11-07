package entity;

class UIEntity extends NoScaleEntity {
	private var entityUpdatedListener:(e:Entity) -> Void;
	private var offsetX:Int = 0;
	private var offsetY:Int = 0;

	public function new(x:Int = 0, y:Int = 0) {
		super(x, y);
		hasGravity = false;
		isCollidable = false;
		spr.set("empty");
		entityUpdatedListener = (e:Entity) -> {
			setPosPixel(e.centerX + offsetX, e.centerY + offsetY);
		}
	}

	/**
	 * Follow entity on scroller.
	 * @param entity the entity to follow
	 * @param offsetX the amount of pixels to offset on the x coord
	 * @param offsetY the amopunt of pixels to ffset on the y coord
	 */
	public function follow(entity:Entity, offsetX:Int = 0, offsetY:Int = 0) {
		this.offsetX = offsetX;
		this.offsetY = offsetY;
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
