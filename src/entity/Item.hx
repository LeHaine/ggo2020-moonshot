package entity;

import entity.interactable.DialogInteracble;

class Item extends Entity {
	var interactable:DialogInteracble;

	var glow:h2d.filter.Glow;

	public function new(cx, cy, useText:String = "Use", glowColor:Int = 0x16a300) {
		super(cx, cy, false);

		glow = new h2d.filter.Glow(glowColor, 0, 5, 1, 1, true);
		spr.filter = glow;

		game.scroller.add(spr, Const.DP_DROPS);
		ignoreBullets = true;

		interactable = new DialogInteracble(cx, cy, useText, use);
		interactable.onFocus = () -> {
			game.tw.createS(glow.alpha, 0 > 1, 0.2);
		}
		interactable.onUnfocus = () -> {
			game.tw.createS(glow.alpha, 0, 0.3);
		}
		interactable.follow(this);
	}

	override function dispose() {
		super.dispose();
		interactable.destroy();
	}

	function use() {}
}
