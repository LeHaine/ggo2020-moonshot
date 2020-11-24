package entity;

class CrystalCrop extends Character {
	public function new(x, y) {
		super(x, y);

		initLife(100);
		spr.set("crystalCrop");
	}

	override function hit(dmg:Int, from:Null<Entity>) {
		super.hit(dmg, from);
		var bonus = game.permaUpgrades.bonusShardsLvl * 0.01;
		var max = M.ceil(dmg / 10);
		max += M.ceil(max * bonus);
		for (i in 0...max) {
			var drop = new entity.collectible.CrystalShard(cx, cy, 5);
			drop.dx = rnd(0, 0.75) * -dirTo(from);
			drop.dy = rnd(-0.75, 0.75);
		}
	}

	override function onDie() {
		super.onDie();

		var bonus = game.permaUpgrades.bonusShardsLvl * 0.01;
		var max = irnd(entity.collectible.CrystalShard.MIN_DROP, entity.collectible.CrystalShard.MAX_DROP) * 5;
		max += M.ceil(max * bonus);
		for (i in 0...max) {
			var drop = new entity.collectible.CrystalShard(cx, cy, 5);
			drop.dx = rnd(-0.75, 0.75);
			drop.dy = rnd(-0.75, 0.75);
		}
	}
}
