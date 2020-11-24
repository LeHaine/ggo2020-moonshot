package entity;

import ui.CrystalShardStationWindow;
import entity.interactable.DialogInteracble;

class CrystalShardStation extends Entity {
	public static var ALL:Array<CrystalShardStation> = [];

	var data:World.Entity_CrystalShardStation;
	var interactable:DialogInteracble;

	public function new(data:World.Entity_CrystalShardStation) {
		super(data.cx, data.cy);
		ALL.push(this);
		this.data = data;
		spr.set("crystalStation");

		hasGravity = false;
		isCollidable = false;
		interactable = new DialogInteracble(cx, cy, "Use Crystal Shards", () -> new CrystalShardStationWindow(onItemBought));
		interactable.follow(this);
	}

	override function dispose() {
		super.dispose();
		interactable.destroy();
		ALL.remove(this);
	}

	private function onItemBought() {
		hero.reinitLife();
		game.hud.invalidate();
	}
}
