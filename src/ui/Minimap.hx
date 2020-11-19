package ui;

import entity.Teleporter;
import dn.Process;

class Minimap extends dn.Process {
	public static var ME:Minimap;

	var level(get, never):Level;

	inline function get_level()
		return Game.ME.level;

	var clearedPoints:Array<Int> = [];

	var bgMask:h2d.Graphics;

	var mapRoot:h2d.Layers;
	var fog:hxd.BitmapData;
	var fogTexture:h3d.mat.Texture;
	var fogTextureBmp:h2d.Bitmap;
	var mapTiles:h2d.TileGroup;
	var background:h2d.Bitmap;
	var mask:h2d.Mask;

	var scale = 0.062;
	var zoom = 1;
	var enlarged = false;
	var navigating = false;
	var ca:dn.heaps.Controller.ControllerAccess;

	public function new() {
		super(Main.ME);
		ME = this;

		ca = Main.ME.controller.createAccess("minimap");
		ca.lock();

		createRootInLayers(Game.ME.root, Const.DP_UI);
		bgMask = new h2d.Graphics(root);

		mapRoot = new h2d.Layers(root);
		mapRoot.setPosition(1, 1);

		var maskSize = 75;
		background = new h2d.Bitmap(h2d.Tile.fromColor(addAlpha(0x0), maskSize + 2, maskSize + 2), mapRoot);
		background.setPosition(-2, -2);

		mask = new h2d.Mask(maskSize, maskSize, mapRoot);
		mapTiles = new h2d.TileGroup(Assets.tiles.tile, mask);

		refresh();

		onResize();
	}

	override function onResize() {
		super.onResize();
		if (navigating) {
			enlargeAndNavigate();
		} else {
			mapRoot.setScale(Const.SCALE);
		}
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
				if (!enlarged) {
					centerMaskTo(hero.cx, hero.cy);
				}
			}
			fogTexture.uploadBitmap(fog);
		}

		if (enlarged) {
			if (ca.bPressed() || ca.isKeyboardPressed(hxd.Key.ESCAPE)) {
				minimize();
			}
			if (ca.leftDist() > 0) {
				var x = Math.cos(ca.leftAngle());
				var y = Math.sin(ca.leftAngle());

				if (navigating) {} else {
					mask.scrollX += x * 10 * tmod;
					mask.scrollY += y * 10 * tmod;
				}
			}
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

	public function enlarge() {
		ca.unlock();
		ca.takeExclusivity();
		zoom = 3;
		mapRoot.setScale(Const.SCALE * zoom);
		var gameW = M.ceil(w());
		var gameH = M.ceil(h());
		var maskW = mask.getBounds().width;
		var maskH = mask.getBounds().height;
		mapRoot.setPosition((gameW - maskW) / 2, (gameH - maskH) / 2);

		bgMask.clear();
		bgMask.beginFill(0x000000, 0.75);
		bgMask.drawRect(0, 0, Main.ME.w(), Main.ME.h());
		bgMask.alpha = 1;
		Game.ME.pause();
		enlarged = true;

		var hero = Game.ME.hero;

		if (hero != null) {
			centerMaskTo(hero.cx, hero.cy);
		}
	}

	public function enlargeAndNavigate() {
		enlarge();
		navigating = true;
	}

	public function minimize() {
		Game.ME.resume();
		bgMask.alpha = 0;
		ca.releaseExclusivity();
		ca.lock();
		zoom = 1;
		enlarged = false;
		navigating = false;
		mapRoot.setPosition(1, 1);
		onResize();
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
		mask.scrollTo(cx * zoom * Const.GRID * scale * Const.SCALE / 2, cy * zoom * Const.GRID * scale * Const.SCALE / 2);
	}

	private function isLeftJoystickDown() {
		return M.radDistance(ca.leftAngle(), M.PIHALF) <= M.PIHALF * 0.5;
	}

	private function isLeftJoystickUp() {
		return M.radDistance(ca.leftAngle(), -M.PIHALF) <= M.PIHALF * 0.5;
	}
}
