package entity;

class GoldMoonStatue extends Character {
	public function new(x, y) {
		super(x, y);

		initLife(100);

		spr.set("goldMoonStatue");
	}

	override function hit(dmg:Int, from:Null<Entity>) {
		super.hit(dmg, from);
		var bonus = game.permaUpgrades.bonusCoinsLvl * 0.01;
		var max = M.ceil(dmg / 10);
		max += M.ceil(max * bonus);
		for (i in 0...max) {
			var drop = new entity.collectible.CoinShard(cx, cy, 20);
			drop.dx = rnd(0, 0.75) * -dirTo(from);
			drop.dy = rnd(-0.75, 0.75);
		}
	}

	override function onDie() {
		super.onDie();

		var bonus = game.permaUpgrades.bonusCoinsLvl * 0.01;
		var max = irnd(entity.collectible.CoinShard.MIN_DROP, entity.collectible.CoinShard.MAX_DROP);
		max += M.ceil(max * bonus);
		for (i in 0...max) {
			var drop = new entity.collectible.CoinShard(cx, cy, 20);
			drop.dx = rnd(-0.75, 0.75);
			drop.dy = rnd(-0.75, 0.75);
		}
	}
}
