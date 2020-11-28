package entity.item;

class Syringe extends Item {
	public function new(cx, cy) {
		super(cx, cy, "Heal 50%");

		spr.set("syringe");
	}

	override function use() {
		super.use();
		hero.addLife(Std.int(hero.maxLife * 0.5));
		Assets.SLIB.syringe().playOnGroup(Const.COLLECTIBLES, 0.7);
		destroy();
	}
}
