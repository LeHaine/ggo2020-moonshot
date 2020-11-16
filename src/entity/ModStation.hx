package entity;

import ui.ModStationWindow;
import entity.interactable.DialogInteracble;

class ModStation extends Entity {
	var data:World.Entity_ModStation;
	var interactable:DialogInteracble;

	public function new(data:World.Entity_ModStation) {
		super(data.cx, data.cy);
		this.data = data;
		spr.set("modStation");

		hasGravity = false;
		isCollidable = false;
		interactable = new DialogInteracble(cx, cy, "Modify Traits", () -> new ModStationWindow(0, onItemBought));
		interactable.follow(this);
	}

	override function dispose() {
		super.dispose();
		interactable.destroy();
	}

	private function onItemBought() {
		#if !debug
		destroy();
		interactable.destroy();
		#end
	}
}
