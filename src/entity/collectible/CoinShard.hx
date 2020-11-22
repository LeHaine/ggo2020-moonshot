package entity.collectible;

class CoinShard extends Collectible {
	public static var MIN_DROP = 15;
	public static var MAX_DROP = 25;

	public function new(cx, cy) {
		super(cx, cy);

		spr.setRandom("coinShards", Std.random);
		spr.filter = new h2d.filter.Glow(0xFFFFFF, 0.5, 5, 1, 1, true);
	}

	override function onCollect() {
		super.onCollect();
		game.coins += 2;
	}
}
