package ui;

import entity.Teleporter;
import dn.Process;

class Minimap extends dn.Process {
	public static var ME:Minimap;

	var level(get, never):Level;

	inline function get_level()
		return Game.ME.level;

	var clearedPoints:Array<Int> = [];

	var fog:hxd.BitmapData;
	var fogTexture:h3d.mat.Texture;
	var fogTextureBmp:h2d.Bitmap;
	var mapTiles:h2d.TileGroup;
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
		mapTiles = new h2d.TileGroup(Assets.tiles.tile, mask);

		refresh();

		onResize();
	}

	override function onResize() {
		super.onResize();
		root.setScale(Const.SCALE);
	}

	override function update() {
		super.update();

		var hero = Game.ME.hero;
		addClearFogPoint(hero.cx, hero.cy);

		if (!cd.hasSetF("refresh", 10)) {
			mapTiles.clear();
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

			for (e in Teleporter.ALL) {
				dotCase(e.cx, e.cy, 0x502999, "fxVertLine", -2);
			}

			var hero = Game.ME.hero;

			if (hero != null) {
				dotCase(hero.cx, hero.cy, 0x00FF00, "fxVertLine", -2);
				addClearFogPoint(hero.cx, hero.cy);
				centerMaskTo(hero.cx, hero.cy);
			}
			fogTexture.uploadBitmap(fog);
		}
	}

	override function onDispose() {
		super.onDispose();
		fog.dispose();
		fogTexture.dispose();
		ME = null;
	}

	public function refresh() {
		cd.unset("refresh");
		var width = Std.int(level.wid * Const.SCALE);
		var height = Std.int(level.hei * Const.SCALE);

		mask.scrollBounds = h2d.col.Bounds.fromValues(-width / 2, -height / 2, width * 2, height * 2);
		if (fogTextureBmp != null) {
			mask.removeChild(fogTextureBmp);
		}
		if (fogTexture != null) {
			fogTexture.dispose();
		}
		if (fog != null) {
			fog.dispose();
		}

		fog = new hxd.BitmapData(width, height);
		fog.fill(0, 0, fog.width, fog.height, addAlpha(0x0));
		fogTexture = h3d.mat.Texture.fromBitmap(fog);
		fogTextureBmp = new h2d.Bitmap(h2d.Tile.fromTexture(fogTexture), mask);
	}

	inline function addClearFogPoint(cx, cy) {
		var radius = 7;
		var startX = Std.int(Math.max(cx - radius, 0));
		var startY = Std.int(Math.max(cy + radius, 0));
		var diameter = radius * 2;
		var endX = diameter + startX;
		var endY = startY - diameter;
		fog.lock();
		for (x in startX...endX) {
			for (y in endY...startY) {
				fog.setPixel(Std.int(x * Const.GRID * scale), Std.int(y * Const.GRID * scale), addAlpha(0x0, 0));
			}
		}
		fog.unlock();
	}

	inline function dotCase(cx:Int, cy:Int, col:UInt, tile:String = "pixel", offsetY = 0) {
		mapTiles.addColor(Std.int(cx * Const.GRID * scale), Std.int(cy * Const.GRID * scale) + offsetY, Color.getR(col), Color.getG(col), Color.getB(col),
			1.0, Assets.tiles.h_get(tile).tile);
	}

	inline function centerMaskTo(cx, cy) {
		mask.scrollTo(cx * Const.GRID * scale * Const.SCALE / 2, cy * Const.GRID * scale * Const.SCALE / 2);
	}
}
