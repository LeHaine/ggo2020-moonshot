package entity.collectible;

class CrystalShard extends Collectible {
	public function new(cx, cy) {
		super(cx, cy);

		spr.setRandom("crystalShards", Std.random);
		spr.filter = new h2d.filter.Glow(0xFFFFFF, 1, 5, 1, 1, true);
	}

	override function onCollect() {
		super.onCollect();
		game.money += 1;
	}
}
