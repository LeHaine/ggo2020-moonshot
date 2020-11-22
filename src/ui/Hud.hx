package ui;

import h2d.Flow;
import h2d.Text;

class Hud extends dn.Process {
	public var game(get, never):Game;

	inline function get_game()
		return Game.ME;

	public var fx(get, never):Fx;

	inline function get_fx()
		return Game.ME.fx;

	public var level(get, never):Level;

	inline function get_level()
		return Game.ME.level;

	public var hero(get, never):entity.Hero;

	inline function get_hero() {
		return Game.ME.hero;
	}

	var flow:h2d.Flow;
	var lifeBar:Bar;
	var lifeText:Text;

	var crystalsText:Text;
	var coinsText:Text;

	var invalidated = true;
	var lastLifeRatio = 1.;

	public function new() {
		super(Game.ME);

		createRootInLayers(game.root, Const.DP_UI);
		root.filter = new h2d.filter.ColorMatrix(); // force pixel perfect rendering

		flow = new h2d.Flow(root);
		flow.padding = 8;
		flow.maxWidth = flow.minWidth = M.ceil(w() / Const.UI_SCALE);
		flow.maxHeight = flow.minHeight = M.ceil(h() / Const.UI_SCALE);

		lifeBar = new Bar(100, 12, 0x00FF00, flow);
		lifeBar.enableOldValue(0xFF0000);

		var lifeBarProps = flow.getProperties(lifeBar);
		lifeBarProps.align(FlowAlign.Bottom, FlowAlign.Left);

		var lifeBox = new h2d.Flow(lifeBar);
		lifeBox.horizontalAlign = Middle;
		lifeBox.verticalAlign = Middle;
		lifeBox.maxWidth = lifeBox.minWidth = M.ceil(lifeBar.outerWidth);
		lifeBox.maxHeight = lifeBox.minHeight = M.ceil(lifeBar.outerHeight);
		lifeBox.y -= 1;
		lifeText = new Text(Assets.fontPixelSmall, lifeBox);

		var collectiblesBox = new h2d.Flow(flow);
		collectiblesBox.horizontalSpacing = 4;

		var collectiblesBoxProps = flow.getProperties(collectiblesBox);
		collectiblesBoxProps.align(FlowAlign.Bottom, FlowAlign.Right);

		Assets.tiles.h_get("crystal", collectiblesBox).scale(0.25);
		crystalsText = new Text(Assets.fontPixelSmall, collectiblesBox);
		crystalsText.text = Std.string(game.shards);

		Assets.tiles.h_get("coin", collectiblesBox).scale(0.25);
		coinsText = new Text(Assets.fontPixelSmall, collectiblesBox);
		coinsText.text = Std.string(game.coins);
	}

	override function onResize() {
		super.onResize();
		root.setScale(Const.UI_SCALE);
		flow.maxWidth = flow.minWidth = M.ceil(w() / Const.UI_SCALE);
		flow.maxHeight = flow.minHeight = M.ceil(h() / Const.UI_SCALE);
	}

	public inline function invalidate()
		invalidated = true;

	override function update() {
		super.update();
		var lifeRatio = hero.life / hero.maxLife;
		if (lifeRatio != lastLifeRatio) {
			lastLifeRatio = lifeRatio;
			invalidate();
		}
	}

	function render() {
		lifeBar.set(hero.life / hero.maxLife, 1);
		lifeText.text = '${hero.life}/${hero.maxLife}';
		coinsText.text = Std.string(game.coins);
		crystalsText.text = Std.string(game.shards);
	}

	override function postUpdate() {
		super.postUpdate();

		if (invalidated) {
			invalidated = false;
			render();
		}
	}
}
