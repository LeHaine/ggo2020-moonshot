package entity.collectible;

class CrystalShard extends Collectible {
	public static var MIN_DROP = 5;
	public static var MAX_DROP = 12;

	var value:Int;

	public function new(cx, cy, value = 1) {
		super(cx, cy);
		this.value = value;
		spr.setRandom("crystalShards", Std.random);
		spr.filter = new h2d.filter.Glow(0xFFFFFF, 1, 5, 1, 1, true);
	}

	override function onCollect() {
		super.onCollect();
		game.shards += value;
	}
}
