package ui;

import entity.CrystalShardStation;
import entity.ModStation;
import dn.DecisionHelper;
import hxd.BitmapData;
import entity.Teleporter;
import dn.Process;

class CustomBitmapData extends BitmapData {
	public function clearRect(x, y, width, height) {
		#if js
		ctx.clearRect(x, y, width, height);
		#end
	}
}

class Minimap extends dn.Process {
	public static var ME:Minimap;

	var level(get, never):Level;

	inline function get_level()
		return Game.ME.level;

	var clearedPoints:Array<Int> = [];

	var bgMask:h2d.Graphics;

	var mapRoot:h2d.Layers;
	var fog:CustomBitmapData;
	var fogTexture:h3d.mat.Texture;
	var fogTextureBmp:h2d.Bitmap;
	var mapTiles:h2d.TileGroup;
	var background:h2d.Bitmap;
	var mask:h2d.Mask;

	var scale = 0.062;
	var zoom = 1;
	var enlarged = false;
	var navigating = false;

	var targetTeleporter:Null<Teleporter>;
	var currentTeleporter:Null<Teleporter>;
	var instructions:h2d.Flow;
	var ca:dn.heaps.Controller.ControllerAccess;

	var teleportInstructions(get, never):String;

	inline function get_teleportInstructions() {
		if (ca.isGamePad()) {
			return "[B] to close, [RB] to teleport, [Left-Stick] to navigate";
		} else {
			return "[ESC] to close, [E] to teleport, [W,A,S,D] to navigate";
		}
	}

	var minimapInstructions(get, never):String;

	inline function get_minimapInstructions() {
		if (ca.isGamePad()) {
			return "[B] to close, [Left-Stick] to navigate";
		} else {
			return "[ESC] to close,  [W,A,S,D] to navigate";
		}
	}

	var intrsuctionsTf:h2d.Text;

	public function new() {
		super(Main.ME);
		ME = this;

		ca = Main.ME.controller.createAccess("minimap");
		ca.lock();

		createRootInLayers(Game.ME.root, Const.DP_UI);
		bgMask = new h2d.Graphics(root);

		mapRoot = new h2d.Layers(root);
		mapRoot.filter = new h2d.filter.ColorMatrix(); // force rendering for pixel perfect
		mapRoot.setPosition(1, 1);

		var maskSize = 75;
		background = new h2d.Bitmap(h2d.Tile.fromColor(addAlpha(0x0), maskSize + 2, maskSize + 2), mapRoot);
		background.setPosition(-2, -2);

		mask = new h2d.Mask(maskSize, maskSize, mapRoot);
		mapTiles = new h2d.TileGroup(Assets.tiles.tile, mask);

		instructions = new h2d.Flow(root);
		instructions.visible = false;
		intrsuctionsTf = new h2d.Text(Assets.fontPixelMedium, instructions);
		intrsuctionsTf.text = minimapInstructions;

		refresh();

		onResize();
	}

	override function onResize() {
		super.onResize();
		if (navigating) {
			enlargeAndNavigate();
		} else if (enlarged) {
			enlarge();
		} else {
			mapRoot.setScale(Const.SCALE);
		}
	}

	override function update() {
		super.update();

		if (enlarged) {
			if (ca.bPressed() || ca.isKeyboardPressed(hxd.Key.ESCAPE)) {
				minimize();
			}
			if (ca.leftDist() > 0) {
				var x = Std.int(Math.cos(ca.leftAngle()));
				var y = Std.int(Math.sin(ca.leftAngle()));

				if (navigating && !cd.hasSetS("teleporterFocus", 0.2)) {
					var dh = new DecisionHelper(Teleporter.ALL);
					dh.remove((e) -> !e.found);
					if (targetTeleporter == currentTeleporter) {
						dh.remove((e) -> e == currentTeleporter);
					}
					dh.remove((e) -> e == targetTeleporter);

					if (x > 0) {
						dh.remove((e) -> targetTeleporter.cx > e.cx);
						dh.score((e) -> -targetTeleporter.distCaseX(e));
						dh.score((e) -> -targetTeleporter.distCaseY(e) * 3);
					} else if (x < 0) {
						dh.remove((e) -> targetTeleporter.cx < e.cx);
						dh.score((e) -> -targetTeleporter.distCaseX(e));
						dh.score((e) -> -targetTeleporter.distCaseY(e) * 3);
					}

					if (y < 0) {
						dh.remove((e) -> targetTeleporter.cy < e.cy);
						dh.score((e) -> -targetTeleporter.distCaseX(e) * 3);
						dh.score((e) -> -targetTeleporter.distCaseY(e));
					} else if (y > 0) {
						dh.remove((e) -> targetTeleporter.cy > e.cy);
						dh.score((e) -> -targetTeleporter.distCaseX(e) * 3);
						dh.score((e) -> -targetTeleporter.distCaseY(e));
					}

					var best = dh.getBest();
					if (best != null) {
						targetTeleporter = best;
						centerMaskTo(targetTeleporter.cx, targetTeleporter.cy);
					}
				} else if (!navigating) {
					mask.scrollX += x * 10 * tmod;
					mask.scrollY += y * 10 * tmod;
				}
			}

			if (ca.rbPressed() && navigating && targetTeleporter != null && targetTeleporter != currentTeleporter) {
				var teleporter = targetTeleporter;
				minimize();
				delayer.addS("teleport", () -> {
					var hero = Game.ME.hero;
					hero.teleport(teleporter);
				}, 0.25);
			}
		}
	}

	override function postUpdate() {
		super.postUpdate();
		if (!cd.hasSetF("refresh", 10)) {
			mapTiles.clear();

			for (cid in level.getMarks(Bg).keys()) {
				var coords = level.idToCoords(cid);
				pixel(coords.cx, coords.cy, 0x3f80d4);
			}

			for (cid in level.getMarks(Walls).keys()) {
				var coords = level.idToCoords(cid);
				pixel(coords.cx, coords.cy, 0xFFFFFF);
			}

			for (cid in level.getMarks(OneWayPlatform).keys()) {
				var coords = level.idToCoords(cid);
				pixel(coords.cx, coords.cy, 0xa7a7a7);
			}

			for (cid in level.getMarks(Ladder).keys()) {
				var coords = level.idToCoords(cid);
				pixel(coords.cx, coords.cy, 0x995d29);
			}

			for (e in Teleporter.ALL) {
				if (targetTeleporter == e) {
					icon(e.cx, e.cy, "minimapIconsTeleporterSelect");
				} else {
					icon(e.cx, e.cy, "minimapIconsTeleporter");
				}
			}

			for (e in ModStation.ALL) {
				icon(e.cx, e.cy, "minimapIconsCoin");
			}

			for (e in CrystalShardStation.ALL) {
				icon(e.cx, e.cy, "minimapIconsShard");
			}

			var hero = Game.ME.hero;

			if (hero != null) {
				pixel(hero.cx, hero.cy, 0x00FF00, "fxVertLine", 0, -2);
				addClearFogPoint(hero.cx, hero.cy);
				if (!enlarged) {
					centerMaskTo(hero.cx, hero.cy);
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

		fog = new CustomBitmapData(width, height);
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
		bgMask.visible = true;
		Game.ME.pause();
		enlarged = true;

		var hero = Game.ME.hero;

		if (hero != null) {
			centerMaskTo(hero.cx, hero.cy);
		}
		intrsuctionsTf.text = minimapInstructions;
		instructions.setPosition(Std.int(mapRoot.x), Std.int(mapRoot.y + background.getBounds().height - 60));
		instructions.visible = true;
	}

	public function enlargeAndNavigate() {
		enlarge();
		intrsuctionsTf.text = teleportInstructions;
		navigating = true;

		var dh = new DecisionHelper(Teleporter.ALL);
		var hero = Game.ME.hero;
		dh.remove((e) -> !e.found);
		dh.score((e) -> -hero.distCase(e));
		currentTeleporter = dh.getBest();
		targetTeleporter = currentTeleporter;
		centerMaskTo(targetTeleporter.cx, targetTeleporter.cy);
	}

	public function minimize() {
		Game.ME.resume();
		bgMask.visible = false;
		ca.releaseExclusivity();
		ca.lock();
		zoom = 1;
		enlarged = false;
		navigating = false;
		mapRoot.setPosition(1, 1);
		targetTeleporter = null;
		currentTeleporter = null;
		instructions.visible = false;
		onResize();
	}

	inline function addClearFogPoint(cx, cy) {
		var radius = 7;
		var startX = Std.int(Math.max(cx - radius, 0));
		var startY = Std.int(Math.max(cy + radius, 0));
		var diameter = radius * 2;
		var endX = diameter + startX;
		var endY = startY - diameter;

		var width = endX - startX;
		var height = startY - endY;

		#if js
		fog.clearRect(startX, endY, width, height);
		#else
		fog.fill(startX, endY, width, height, addAlpha(0x0, 0));
		#end
		fogTexture.uploadBitmap(fog);
	}

	inline function pixel(cx:Int, cy:Int, col:UInt, tile:String = "pixel", offsetX = 0, offsetY = 0) {
		mapTiles.addColor(Std.int(cx * Const.GRID * scale) + offsetX, Std.int(cy * Const.GRID * scale) + offsetY, Color.getR(col), Color.getG(col),
			Color.getB(col), 1.0, Assets.tiles.getTile(tile));
	}

	inline function icon(x:Float, y:Float, tile:String) {
		mapTiles.add(Std.int(x * Const.GRID * scale) - 2, Std.int(y * Const.GRID * scale) - 3, Assets.tiles.getTile(tile));
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
