package entity.collectible;

class CoinShard extends Collectible {
	public static var MIN_DROP = 2;
	public static var MAX_DROP = 4;

	var value:Int;

	public function new(cx, cy, value = 4) {
		super(cx, cy);
		this.value = value;
		spr.setRandom("coinShards", Std.random);
		spr.filter = new h2d.filter.Glow(0xFFFFFF, 0.5, 5, 1, 1, true);
	}

	override function onCollect() {
		super.onCollect();
		Assets.SLIB.coin().playOnGroup(Const.COLLECTIBLES, 0.3);
		game.coins += value;
	}
}
