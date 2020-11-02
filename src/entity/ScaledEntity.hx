package entity;

/**
 * Entity that is placed on the [Game] scroller and scales when resized. Good for almost everything. See [NoScaleEntity] if you need high res sprites/UI at a low resolution.
 */
class ScaledEntity extends Entity {
	public function new(x:Int, y:Int) {
		super(x, y);
		Game.ME.scroller.add(spr, Const.DP_MAIN);
	}
}
