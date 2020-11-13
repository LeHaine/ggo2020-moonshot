package entity;

import entity.interactable.EndLevelInteracble;

class EndLevel extends ScaledEntity {
	private var data:World.Entity_EndLevel;

	var interactable:EndLevelInteracble;

	public function new(data:World.Entity_EndLevel) {
		super(data.cx, data.cy);
		this.data = data;

		spr.set("empty");
		hasGravity = false;
		isCollidable = false;
		interactable = new EndLevelInteracble(cx, cy, onEndLevel);
		interactable.follow(this, 0, -2);
	}

	override function dispose() {
		super.dispose();
		interactable.destroy();
	}

	function onEndLevel() {
		if (data.f_moveToNextLevel) {
			game.startNextLevel();
		}
	}
}
