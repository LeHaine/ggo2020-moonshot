package entity;

/**
 * Entity that is not placed on the [Game] scroller and has an indepedent resolutions. Good for low res games that need high res UI/fonts and need to be in the "game world".
 */
class NoScaleEntity extends Entity {
	public static var ALL:Array<NoScaleEntity> = [];

	public function new(x:Int, y:Int) {
		super(x, y);
		ALL.push(this);
		Game.ME.root.add(spr, Const.DP_UI);
	}

	override function dispose() {
		super.dispose();
		ALL.remove(this);
	}

	override function syncPosition() {
		var scaledX = (cx + xr) * Const.GRID;
		var scaledY = (cy + yr) * Const.GRID;
		spr.x = camera.scrollerToGlobalX(scaledX);
		spr.y = camera.scrollerToGlobalY(scaledY);
	}
}
