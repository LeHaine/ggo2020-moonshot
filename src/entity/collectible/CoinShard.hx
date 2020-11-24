package entity.collectible;

class CoinShard extends Collectible {
	public static var MIN_DROP = 8;
	public static var MAX_DROP = 13;

	var value:Int;

	public function new(cx, cy, value = 4) {
		super(cx, cy);
		this.value = value;
		spr.setRandom("coinShards", Std.random);
		spr.filter = new h2d.filter.Glow(0xFFFFFF, 0.5, 5, 1, 1, true);
	}

	override function onCollect() {
		super.onCollect();
		game.coins += value;
	}
}
