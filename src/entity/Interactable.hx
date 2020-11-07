package entity;

import hxd.Timer;
import dn.heaps.filter.PixelOutline;
import h2d.filter.Outline;

class Interactable extends UIEntity {
	public static var ALL:Array<Interactable> = [];

	private var wrapper:h2d.Flow;
	private var downArrow:HSprite;
	private var window:h2d.Flow;

	public var secondaryInteractionDelay:Float;
	public var secondaryDelayActionTimer:Float;
	public var canInteract:Bool;

	public function new(x, y) {
		super(x, y);
		ALL.push(this);
		secondaryInteractionDelay = 0.3;
		secondaryDelayActionTimer = 0;

		wrapper = new h2d.Flow();
		wrapper.alpha = 0;
		wrapper.visible = false;
		wrapper.layout = Vertical;

		window = new h2d.Flow(wrapper);
		window.alpha = 0.85;
		window.backgroundTile = h2d.Tile.fromColor(0x000000, 32, 32);
		window.filter = new PixelOutline(0xffffff);
		window.borderWidth = 7;
		window.borderHeight = 7;
		window.layout = Vertical;
		window.padding = 5;
		window.verticalSpacing = 3;

		downArrow = new HSprite(Assets.tiles, "uiDownArrow", wrapper);
		downArrow.setCenterRatio(0.5, 0);
		downArrow.alpha = 0.85;
	}

	override public function dispose() {
		super.dispose();
		ALL.remove(this);
	}

	public function canInteraction(by:entity.Hero) {
		return canInteract;
	}

	public function interact(by:entity.Hero) {}

	public function canSecondaryInteraction(by:entity.Hero) {
		if (!canInteract) {
			return false;
		}
		secondaryDelayActionTimer += Timer.elapsedTime;
		return secondaryDelayActionTimer >= secondaryInteractionDelay;
	}

	public function secondaryInteract(by:entity.Hero) {}

	public function resetSecondaryInteractionTimer() {
		secondaryDelayActionTimer = 0;
	}

	public function focus() {
		wrapper.visible = true;
		game.tw.createS(wrapper.alpha, 0 > 1, 0.2).end(() -> canInteract = true);
	}

	public function unfocus() {
		canInteract = false;
		resetSecondaryInteractionTimer();
		game.tw.createS(wrapper.alpha, 0, 0.3).end(() -> {
			wrapper.visible = false;
		});
	}

	private function setOutlineColor(color:Int) {
		window.filter = new Outline(0.5, color);
	}
}
