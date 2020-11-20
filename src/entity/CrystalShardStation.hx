package entity;

import ui.CrystalShardStationWindow;
import entity.interactable.DialogInteracble;

class CrystalShardStation extends Entity {
	var data:World.Entity_CrystalShardStation;
	var interactable:DialogInteracble;

	public function new(data:World.Entity_CrystalShardStation) {
		super(data.cx, data.cy);
		this.data = data;
		spr.set("modStation");

		hasGravity = false;
		isCollidable = false;
		interactable = new DialogInteracble(cx, cy, "Use Crystal Shards", () -> new CrystalShardStationWindow(onItemBought));
		interactable.follow(this);
	}

	override function dispose() {
		super.dispose();
		interactable.destroy();
	}

	private function onItemBought() {
		hero.reinitLife();
		game.hud.invalidate();
	}
}
