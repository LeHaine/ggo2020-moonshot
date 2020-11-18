package ui;

import dn.Process;

class Minimap extends dn.Process {
	public static var ME:Minimap;

	var level(get, never):Level;

	inline function get_level()
		return Game.ME.level;

	var tileGroup:h2d.TileGroup;
	var background:h2d.Bitmap;
	var mask:h2d.Mask;

	var scale = 0.062;

	public function new() {
		super(Game.ME);
		ME = this;

		createRootInLayers(Game.ME.root, Const.DP_UI);
		root.setPosition(1, 1);
		var maskSize = 75;
		background = new h2d.Bitmap(h2d.Tile.fromColor(addAlpha(0x0), maskSize + 2, maskSize + 2), root);
		background.setPosition(-2, -2);

		mask = new h2d.Mask(maskSize, maskSize, root);
		refresh();

		tileGroup = new h2d.TileGroup(Assets.tiles.tile, mask);

		onResize();
	}

	override function onResize() {
		super.onResize();
		root.setScale(Const.SCALE);
	}

	override function update() {
		super.update();

		if (!cd.hasSetF("refresh", 10)) {
			tileGroup.clear();

			for (cx in 0...level.wid) {
				for (cy in 0...level.hei) {
					if (!level.hasCollision(cx, cy)) {
						dotCase(cx, cy, 0x3f80d4);
					}
				}
			}

			for (cid in level.getMarks(Walls).keys()) {
				var coords = level.idToCoords(cid);
				dotCase(coords.cx, coords.cy, 0xFFFFFF);
			}

			for (cid in level.getMarks(OneWayPlatform).keys()) {
				var coords = level.idToCoords(cid);
				dotCase(coords.cx, coords.cy, 0xa7a7a7);
			}

			for (cid in level.getMarks(Ladder).keys()) {
				var coords = level.idToCoords(cid);
				dotCase(coords.cx, coords.cy, 0x995d29);
			}

			var hero = Game.ME.hero;

			if (hero != null) {
				dotCase(hero.cx, hero.cy, 0x00FF00, "fxVertLine", -2);
				centerMaskTo(hero.cx, hero.cy);
			}
		}
	}

	override function onDispose() {
		super.onDispose();
		ME = null;
	}

	public function refresh() {
		cd.unset("refresh");
		var width = level.wid * Const.SCALE;
		var height = level.hei * Const.SCALE;

		mask.scrollBounds = h2d.col.Bounds.fromValues(-width / 2, -height / 2, width * 2, height * 2);
	}

	inline function dotCase(cx:Int, cy:Int, col:UInt, tile:String = "pixel", offsetY = 0) {
		tileGroup.addColor(Std.int(cx * Const.GRID * scale), Std.int(cy * Const.GRID * scale) + offsetY, Color.getR(col), Color.getG(col), Color.getB(col),
			1.0, Assets.tiles.h_get(tile).tile);
	}

	inline function centerMaskTo(cx, cy) {
		mask.scrollTo(cx * Const.GRID * scale * Const.SCALE / 2, cy * Const.GRID * scale * Const.SCALE / 2);
	}
}
