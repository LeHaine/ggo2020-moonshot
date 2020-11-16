import h2d.Sprite;
import dn.heaps.HParticle;
import dn.Tweenie;

class Fx extends dn.Process {
	var game(get, never):Game;

	inline function get_game()
		return Game.ME;

	var level(get, never):Level;

	inline function get_level()
		return Game.ME.level;

	public var pool:ParticlePool;

	public var bgAddSb:h2d.SpriteBatch;
	public var bgNormalSb:h2d.SpriteBatch;
	public var topAddSb:h2d.SpriteBatch;
	public var topNormalSb:h2d.SpriteBatch;

	public function new() {
		super(Game.ME);

		pool = new ParticlePool(Assets.tiles.tile, 2048, Const.FPS);

		bgAddSb = new h2d.SpriteBatch(Assets.tiles.tile);
		game.scroller.add(bgAddSb, Const.DP_FX_BG);
		bgAddSb.blendMode = Add;
		bgAddSb.hasRotationScale = true;

		bgNormalSb = new h2d.SpriteBatch(Assets.tiles.tile);
		game.scroller.add(bgNormalSb, Const.DP_FX_BG);
		bgNormalSb.hasRotationScale = true;

		topNormalSb = new h2d.SpriteBatch(Assets.tiles.tile);
		game.scroller.add(topNormalSb, Const.DP_FX_FRONT);
		topNormalSb.hasRotationScale = true;

		topAddSb = new h2d.SpriteBatch(Assets.tiles.tile);
		game.scroller.add(topAddSb, Const.DP_FX_FRONT);
		topAddSb.blendMode = Add;
		topAddSb.hasRotationScale = true;
	}

	override public function onDispose() {
		super.onDispose();

		pool.dispose();
		bgAddSb.remove();
		bgNormalSb.remove();
		topAddSb.remove();
		topNormalSb.remove();
	}

	public function clear() {
		pool.killAll();
	}

	public inline function allocTopAdd(t:h2d.Tile, x:Float, y:Float):HParticle {
		return pool.alloc(topAddSb, t, x, y);
	}

	public inline function allocTopNormal(t:h2d.Tile, x:Float, y:Float):HParticle {
		return pool.alloc(topNormalSb, t, x, y);
	}

	public inline function allocBgAdd(t:h2d.Tile, x:Float, y:Float):HParticle {
		return pool.alloc(bgAddSb, t, x, y);
	}

	public inline function allocBgNormal(t:h2d.Tile, x:Float, y:Float):HParticle {
		return pool.alloc(bgNormalSb, t, x, y);
	}

	public inline function getTile(id:String):h2d.Tile {
		return Assets.tiles.getTileRandom(id);
	}

	public function killAll() {
		pool.killAll();
	}

	public function markerEntity(e:Entity, ?c = 0xFF00FF, ?short = false) {
		#if debug
		if (e == null)
			return;

		markerCase(e.cx, e.cy, short ? 0.03 : 3, c);
		#end
	}

	public function markerCase(cx:Int, cy:Int, ?sec = 3.0, ?c = 0xFF00FF) {
		#if debug
		var p = allocTopAdd(getTile("fxCircle"), (cx + 0.5) * Const.GRID, (cy + 0.5) * Const.GRID);
		p.setFadeS(1, 0, 0.06);
		p.colorize(c);
		p.lifeS = sec;

		var p = allocTopAdd(getTile("pixel"), (cx + 0.5) * Const.GRID, (cy + 0.5) * Const.GRID);
		p.setFadeS(1, 0, 0.06);
		p.colorize(c);
		p.setScale(2);
		p.lifeS = sec;
		#end
	}

	public function markerFree(x:Float, y:Float, ?sec = 3.0, ?c = 0xFF00FF) {
		#if debug
		var p = allocTopAdd(getTile("fxDot"), x, y);
		p.setCenterRatio(0.5, 0.5);
		p.setFadeS(1, 0, 0.06);
		p.colorize(c);
		p.setScale(3);
		p.lifeS = sec;
		#end
	}

	public function markerText(cx:Int, cy:Int, txt:String, ?t = 1.0) {
		#if debug
		var tf = new h2d.Text(Assets.fontTiny, topNormalSb);
		tf.text = txt;

		var p = allocTopAdd(getTile("fxCircle"), (cx + 0.5) * Const.GRID, (cy + 0.5) * Const.GRID);
		p.colorize(0x0080FF);
		p.alpha = 0.6;
		p.lifeS = 0.3;
		p.fadeOutSpeed = 0.4;
		p.onKill = tf.remove;

		tf.setPosition(p.x - tf.textWidth * 0.5, p.y - tf.textHeight * 0.5);
		#end
	}

	inline function collides(p:HParticle, offX = 0., offY = 0.) {
		var x = Std.int((p.x + offX) / Const.GRID);
		var y = Std.int((p.y + offY) / Const.GRID);
		return level.hasCollision(x, y) || level.hasOneWayPlatform(x, y);
	}

	public function flashBangS(c:UInt, a:Float, ?t = 0.1) {
		var e = new h2d.Bitmap(h2d.Tile.fromColor(c, 1, 1, a));
		game.root.add(e, Const.DP_FX_FRONT);
		e.scaleX = game.w();
		e.scaleY = game.h();
		e.blendMode = Add;
		game.tw.createS(e.alpha, 0, t).end(function() {
			e.remove();
		});
	}

	function _bloodPhysics(p:HParticle) {
		if (collides(p) && p.data0 != 1) {
			p.data0 = 1;
			p.frict = 0.8;
			p.dx *= 0.4;
			p.dy = p.gy = 0;
			p.gy = rnd(0, 0.001);
			p.frict = rnd(0.5, 0.7);
			p.dsY = rnd(0, 0.001);
			p.rotation = 0;
			p.dr = 0;
			if (!collides(p, -5, 0) || !collides(p, 5, 0)) {
				p.scaleY *= rnd(2, 3);
			}
			if (!collides(p, 0, -5) || !collides(p, 0, 5)) {
				p.scaleX *= rnd(2, 3);
			}
		}
	}

	public function gibs(x:Float, y:Float, dir:Int, amount:Int = 10, color:UInt = 0x951d1d) {
		for (i in 0...amount) {
			var p = allocTopNormal(getTile("fxGib"), x + rnd(0, 4, true), y + rnd(0, 8, true));
			p.colorize(color);
			p.setFadeS(rnd(0.6, 1), 0, rnd(1, 3));
			p.dx = dir * rnd(3, 7);
			p.dy = rnd(-1, 0);
			p.gy = rnd(0.07, 0.10);
			p.rotation = rnd(0, M.PI2);
			p.frict = rnd(0.92, 0.96);
			p.lifeS = rnd(3, 10);
			p.onUpdate = _bloodPhysics;
		}
	}

	public function normalShot(fx:Float, fy:Float, a:Float, c:UInt, dist:Float) {
		// ceneter
		for (i in 0...4) {
			var d = i <= 2 ? 0 : rnd(0, 5);
			var p = allocTopAdd(getTile("fxDot"), fx + Math.cos(a) * d, fy + Math.sin(a) * d);
			p.setFadeS(rnd(0.6, 1), 0, rnd(0.1, 0.12));
			p.colorize(c);
			p.setCenterRatio(0, 0.5);

			p.scaleX = rnd(8, 15);
			p.scaleXMul = rnd(0.9, 0.97);

			p.rotation = a;
			p.lifeS = 0;
		}

		//  sides
		for (i in 0...20) {
			var a = a + rnd(0.2, 0.5, true);
			var d = i <= 2 ? 0 : rnd(0, 5);
			var p = allocTopAdd(getTile("fxDot"), fx + Math.cos(a) * d, fy + Math.sin(a) * d);
			p.alpha = 0.7;
			p.setFadeS(rnd(0.4, 0.6), 0, rnd(0.1, 0.12));
			p.colorize(0xF5450A);
			p.setCenterRatio(0, 0.5);

			p.scaleX = rnd(3, 5);
			p.scaleXMul = rnd(0.9, 0.97);

			p.rotation = a;
			p.lifeS = 0;
		}

		// trail
		var n = 40;
		for (i in 0...n) {
			var d = 0.8 * dist * i / (n - 1) + rnd(0, 6);
			var p = allocTopAdd(getTile("fxDot"), fx + Math.cos(a) * d, fy + Math.sin(a) * d);
			p.setFadeS(rnd(0.4, 0.6), 0, rnd(0.1, 0.12));
			p.colorize(c);

			p.scaleX = rnd(3, 5);
			p.moveAng(a, rnd(2, 10));
			p.frict = 0.8;
			p.gy = rnd(0, 0.1);
			p.scaleXMul = rnd(0.9, 0.97);

			p.rotation = a;
			p.lifeS = 0.1 * i / (n - 1);
		}
	}

	public function moonShot(fx:Float, fy:Float, a:Float, c:UInt, dist:Float) {
		// center
		for (i in 0...4) {
			var d = i <= 2 ? 0 : rnd(0, 5);
			var p = allocTopAdd(getTile("fxDot"), fx + Math.cos(a) * d, fy + Math.sin(a) * d);
			p.setFadeS(rnd(0.6, 1), 0, rnd(0.1, 0.12));
			p.colorize(c);
			p.setCenterRatio(0, 0.5);

			p.scaleX = rnd(1, 1.5);
			p.scaleXMul = rnd(0.9, 0.97);

			p.rotation = a;
			p.lifeS = 0;
		}

		// sides
		for (i in 0...5) {
			var a = a + rnd(0.2, 0.5, true);
			var d = i <= 2 ? 0 : rnd(0, 5);
			var p = allocTopAdd(getTile("fxDot"), fx + Math.cos(a) * d, fy + Math.sin(a) * d);
			p.setFadeS(rnd(0.4, 0.6), 0, rnd(0.1, 0.12));
			p.colorize(c);
			p.setCenterRatio(0, 0.5);

			p.scaleX = rnd(3, 5);
			p.scaleXMul = rnd(0.9, 0.97);

			p.rotation = a;
			p.lifeS = 0;
		}

		// bullet trail
		var n = 10;
		for (i in 0...n) {
			var d = 0.8 * dist * i / (n - 1) + rnd(0, 6);
			var p = allocTopAdd(getTile("fxDot"), fx + Math.cos(a) * d, fy + Math.sin(a) * d);
			p.setFadeS(rnd(0.4, 0.6), 0, rnd(0.1, 0.12));
			p.colorize(c);

			p.scaleX = rnd(3, 5);
			p.moveAng(a, rnd(2, 10));
			p.frict = 0.8;
			p.gy = rnd(0, 0.1);
			p.scaleXMul = rnd(0.9, 0.97);

			p.rotation = a;
			p.lifeS = 0.1 * i / (n - 1);
		}
	}

	public function strongMoonShot(fx:Float, fy:Float, a:Float, c:UInt, dist:Float) {
		// center
		for (i in 0...12) {
			var d = i <= 2 ? 0 : rnd(0, 5);
			var p = allocTopAdd(getTile("fxDot"), fx + Math.cos(a) * d, fy + Math.sin(a) * d);
			p.setFadeS(rnd(0.6, 1), 0, rnd(0.1, 0.12));
			p.colorize(c);
			p.setCenterRatio(0, 0.5);

			p.scaleX = rnd(8, 15);
			p.scaleXMul = rnd(0.9, 0.97);

			p.rotation = a;
			p.lifeS = 0;
		}

		// sides
		for (i in 0...40) {
			var a = a + rnd(0.2, 0.5, true);
			var d = i <= 2 ? 0 : rnd(0, 5);
			var p = allocTopAdd(getTile("fxDot"), fx + Math.cos(a) * d, fy + Math.sin(a) * d);
			p.setFadeS(rnd(0.4, 0.6), 0, rnd(0.1, 0.12));
			p.colorize(c);
			p.setCenterRatio(0, 0.5);

			p.scaleX = rnd(3, 5);
			p.scaleXMul = rnd(0.9, 0.97);

			p.rotation = a;
			p.lifeS = 0;
		}

		// trail
		var n = 80;
		for (i in 0...n) {
			var d = 0.8 * dist * i / (n - 1) + rnd(0, 6);
			var p = allocTopAdd(getTile("fxDot"), fx + Math.cos(a) * d, fy + Math.sin(a) * d);
			p.setFadeS(rnd(0.4, 0.6), 0, rnd(0.1, 0.12));
			p.colorize(c);

			p.scaleX = rnd(3, 5);
			p.moveAng(a, rnd(2, 10));
			p.frict = 0.8;
			p.gy = rnd(0, 0.1);
			p.scaleXMul = rnd(0.9, 0.97);

			p.rotation = a;
			p.lifeS = 0.1 * i / (n - 1);
		}
	}

	public function moonShotExplosion(x:Float, y:Float, mul:Float) {
		var dustColor = 0xa9c2d8;

		// dust particles
		var n = Std.int(M.ceil(40 * mul));
		for (i in 0...n) {
			var p = allocTopNormal(getTile("fxSmallCircle"), x + rnd(0, 3, true), y + rnd(0, 4, true));
			p.setFadeS(rnd(0.7, 1), 0, rnd(3, 7));
			p.colorize(Color.interpolateInt(dustColor, 0x0, rnd(0, 0.1)));

			p.setScale(rnd(0.3, 0.7, true) * mul);
			p.scaleMul = rnd(0.98, 0.99);

			p.dx = rnd(0, 9, true) * mul;
			p.dy = i <= n * 0.25 ? -rnd(6, 12) * mul : -rnd(1, 7) * mul;
			p.gy = rnd(0.1, 0.3);
			p.frict = rnd(0.85, 0.96);

			p.rotation = rnd(0, 6.28);
			p.dr = rnd(0, 0.3, true);

			p.lifeS = rnd(5, 10);
			p.onUpdate = _hardPhysics;
			p.delayS = i > 20 ? rnd(0, 0.1) : 0;
		}

		// bigger dust particles
		var n = Std.int(M.ceil(20 * mul));
		for (i in 0...n) {
			var p = allocBgNormal(getTile("fxSmallCircle"), x + rnd(0, 3, true), y + rnd(0, 4, true));
			p.colorize(Color.interpolateInt(dustColor, 0x0, rnd(0, 0.1)));
			p.setFadeS(rnd(0.7, 1), 0, rnd(3, 7));

			p.setScale(rnd(0.75, 1.5, true) * mul);
			p.scaleMul = rnd(0.98, 0.99);

			p.dx = rnd(0, 5, true) * mul;
			p.dy = rnd(-5, 0) * mul;
			p.gy = rnd(0.1, 0.2);
			p.frict = rnd(0.85, 0.96);

			p.rotation = rnd(0, 6.28);
			p.dr = rnd(0, 0.3, true);

			p.lifeS = rnd(5, 10);
			p.onUpdate = _hardPhysics;
			p.delayS = i > 20 ? rnd(0, 0.1) : 0;
		}

		// smoke
		var n = Std.int(M.ceil(10 * mul));
		for (i in 0...n) {
			var p = allocBgNormal(getTile("fxSmoke"), x + rnd(0, 5, true), y + rnd(0, 7, true));
			p.colorAnimS(0xcfd6d8, 0xabb7ba, rnd(2, 4));
			p.setFadeS(rnd(0.2, 0.4), 0, rnd(0.5, 1));

			p.setScale(rnd(0.25, 0.5, true) * mul);
			p.scaleMul = rnd(0.998, 0.999);

			p.dx = rnd(0, 1.3, true) * mul;
			p.dy = rnd(-2, 0) * mul;
			p.frict = rnd(0.93, 0.96);
			p.gy = -rnd(0.005, 0.008);

			p.rotation = rnd(0, 6.28);
			p.dr = rnd(0, 0.02, true);

			p.lifeS = rnd(0.25, 0.35);
			p.delayS = i > 20 ? rnd(0, 0.1) : 0;
		}
	}

	function _hardPhysics(p:HParticle) {
		if (collides(p) && Math.isNaN(p.data0)) {
			p.data0 = 1;
			p.gy = 0;
			p.dx *= 0.5;
			p.dy = 0;
			p.dr = 0;
			p.frict = 0.8;
			p.rotation *= 0.03;
		}
	}

	public function woundBleed(x:Float, y:Float) {
		var n = 2;
		for (i in 0...n) {
			var p = allocTopNormal(getTile("fxDot"), x + rnd(0, 3, true), y + rnd(0, 4, true));
			p.colorize(Color.interpolateInt(0xFF0000, 0x6F0000, rnd(0, 1)));
			p.dx = Math.sin(x + ftime * 0.03) * 0.2;
			p.gy = rnd(0.1, 0.2);
			p.frict = rnd(0.85, 0.96);
			p.lifeS = rnd(1, 3);
			p.setFadeS(rnd(0.7, 1), 0, rnd(3, 7));
			p.onUpdate = _bloodPhysics;
			p.delayS = i > 20 ? rnd(0, 0.1) : 0;
		}
	}

	public function laserSparks(x:Float, y:Float, endX:Float, endY:Float) {
		var dx = endX - x;
		var dy = endY - y;
		for (i in 0...20) {
			var p = allocBgAdd(getTile("pixel"), x + rnd(0, dx), y + rnd(0, dy));
			p.colorize(0xff9200);
			p.colorAnimS(0xcfd6d8, 0xabb7ba, rnd(2, 4));
			p.setFadeS(rnd(0.2, 0.4), 0, rnd(0.5, 1));

			p.setScale(rnd(1, 1.25, true));
			p.scaleMul = rnd(0.998, 0.999);

			p.dx = rnd(0, 0.7, true);
			p.dy = rnd(-1, 1);
			p.frict = rnd(0.93, 0.96);
			p.gy = rnd(-0.005, 0.005);

			p.rotation = rnd(0, 6.28);
			p.dr = rnd(0, 0.02, true);

			p.lifeS = rnd(0.25, 0.35);
			p.delayS = i > 20 ? rnd(0, 0.1) : 0;
			p.onUpdate = _killOnCollision;
		}
	}

	public function explosion(x:Float, y:Float, r:Float) {
		var c = 0x8493b0;

		var p = allocTopAdd(getTile("fxSmallCircle"), x, y);
		p.colorize(0xFF0000);
		p.setFadeS(0.5, 0, 0.1);
		p.setScale(2 * r / p.t.width);
		p.lifeS = 0;
		p.ds = 0.1;
		p.dsFrict = 0.8;

		var p = allocTopAdd(getTile("fxSmallCircle"), x, y);
		p.colorize(0xFF0000);
		p.setFadeS(0.5, 0, 0.1);
		p.setScale(2 * r / p.t.width);
		p.lifeS = 0;
		p.ds = 0.02;
		p.dsFrict = 0.8;

		// Dots
		var n = 100;
		for (i in 0...n) {
			var p = allocTopNormal(getTile("fxSmallCircle"), x + rnd(0, 3, true), y + rnd(0, 4, true));
			p.setFadeS(rnd(0.7, 1), 0, rnd(3, 7));
			p.colorize(Color.interpolateInt(c, 0x0, rnd(0, 0.1)));

			p.setScale(rnd(0.3, 0.7, true));
			p.scaleMul = rnd(0.98, 0.99);

			p.dx = rnd(0, 9, true);
			p.dy = i <= n * 0.25 ? -rnd(6, 12) : -rnd(1, 7);
			p.gy = rnd(0.1, 0.3);
			p.frict = rnd(0.85, 0.96);

			p.rotation = rnd(0, 6.28);
			p.dr = rnd(0, 0.3, true);

			p.lifeS = rnd(5, 10);
			p.onUpdate = _hardPhysics;
			p.delayS = i > 20 ? rnd(0, 0.1) : 0;
		}

		// Big dirt
		var n = 20;
		for (i in 0...n) {
			var p = allocBgNormal(getTile("fxSmallCircle"), x + rnd(0, 3, true), y + rnd(0, 4, true));
			p.colorize(Color.interpolateInt(c, 0x0, rnd(0, 0.1)));
			p.setFadeS(rnd(0.7, 1), 0, rnd(3, 7));

			p.setScale(rnd(1, 2, true));
			p.scaleMul = rnd(0.98, 0.99);

			p.dx = rnd(0, 5, true);
			p.dy = rnd(-5, 0);
			p.gy = rnd(0.1, 0.2);
			p.frict = rnd(0.85, 0.96);

			p.rotation = rnd(0, 6.28);
			p.dr = rnd(0, 0.3, true);

			p.lifeS = rnd(5, 10);
			p.onUpdate = _hardPhysics;
			p.delayS = i > 20 ? rnd(0, 0.1) : 0;
		}

		// Smoke
		var n = 40;
		for (i in 0...n) {
			var p = allocBgNormal(getTile("fxSmoke"), x + rnd(0, 5, true), y + rnd(0, 7, true));
			p.colorAnimS(0xE1451E, 0x222035, rnd(2, 4));
			p.setFadeS(rnd(0.2, 0.4), 0, rnd(0.5, 1));

			p.setScale(rnd(1.5, 2, true));
			p.scaleMul = rnd(0.998, 0.999);

			p.dx = rnd(0, 1.3, true);
			p.dy = rnd(-2, 0);
			p.frict = rnd(0.93, 0.96);
			p.gy = -rnd(0.005, 0.008);

			p.rotation = rnd(0, 6.28);
			p.dr = rnd(0, 0.02, true);

			p.lifeS = rnd(4, 5);
			p.delayS = i > 20 ? rnd(0, 0.1) : 0;
		}

		// Fire
		var n = 40;
		for (i in 0...n) {
			var p = allocTopAdd(getTile("fxSmoke"), x + rnd(0, 3, true), y - rnd(0, 6));
			p.colorAnimS(0xE78F0C, 0x5A5F98, rnd(1, 3));
			p.setFadeS(rnd(0.7, 1), 0, rnd(0.5, 1));

			p.setScale(rnd(0.8, 1.5, true));
			p.scaleMul = rnd(0.97, 0.99);

			p.moveAwayFrom(x, y, rnd(0, 2));
			p.frict = rnd(0.85, 0.96);

			p.rotation = rnd(0, 6.28);
			p.dr = rnd(0, 0.03, true);

			p.lifeS = rnd(1, 3);
			p.delayS = i > 20 ? rnd(0, 0.1) : 0;
		}
	}

	function _killOnCollision(p:HParticle) {
		if (collides(p) && Math.isNaN(p.data0)) {
			p.data0 = 1;
			p.kill();
		}
	}

	override function update() {
		super.update();

		pool.update(game.tmod);
	}
}
