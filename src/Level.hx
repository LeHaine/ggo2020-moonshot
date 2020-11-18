class Level extends dn.Process {
	public var game(get, never):Game;

	inline function get_game()
		return Game.ME;

	public var fx(get, never):Fx;

	inline function get_fx()
		return Game.ME.fx;

	public var wid(get, never):Int;

	inline function get_wid()
		return data.l_Collisions.cWid;

	public var hei(get, never):Int;

	inline function get_hei()
		return data.l_Collisions.cHei;

	public var collisionLayers = [0, 3]; // walls, prison walls
	public var data:World.World_Level;
	public var idx:Int;

	var tilesetSource:h2d.Tile;

	var marks:Map<LevelMark, Map<Int, Int>> = new Map();
	var invalidated = true;

	public function new(idx:Int, lvl:World.World_Level) {
		super(Game.ME);
		createRootInLayers(Game.ME.scroller, Const.DP_BG);
		data = lvl;
		this.idx = idx;
		tilesetSource = hxd.Res.world.tiles.toTile();

		createLevelMarks();
	}

	/**
		Mark the level for re-render at the end of current frame (before display)
	**/
	public inline function invalidate() {
		invalidated = true;
	}

	/**
		Return TRUE if given coordinates are in level bounds
	**/
	public inline function isValid(cx, cy)
		return cx >= 0 && cx < wid && cy >= 0 && cy < hei;

	/**
		Transform coordinates into a coordId
	**/
	public inline function coordId(cx, cy)
		return cx + cy * wid;

	public inline function idToCoords(id) {
		return {cx: id % wid, cy: M.floor(id / wid)};
	}

	/** Return TRUE if mark is present at coordinates **/
	public inline function hasMark(mark:LevelMark, cx:Int, cy:Int, dir:Int = 0) {
		return !isValid(cx, cy) || !marks.exists(mark) ? false : marks.get(mark).get(coordId(cx, cy)) == (dir == 0 ? 0 : dir > 0 ? 1 : -1);
	}

	public inline function setMarks(cx, cy, marks:Array<LevelMark>) {
		for (m in marks) {
			setMark(m, cx, cy);
		}
	}

	/** Enable mark at coordinates **/
	public function setMark(mark:LevelMark, cx:Int, cy:Int, dir:Int = 0) {
		if (isValid(cx, cy) && !hasMark(mark, cx, cy)) {
			if (!marks.exists(mark)) {
				marks.set(mark, new Map());
			}
			marks[mark].set(coordId(cx, cy), dir == 0 ? 0 : dir > 0 ? 1 : -1);
		}
	}

	public inline function getMarks(mark:LevelMark):Map<Int, Int> {
		return marks.exists(mark) ? marks[mark] : [];
	}

	/** Remove mark at coordinates **/
	public function removeMark(mark:LevelMark, cx:Int, cy:Int) {
		if (isValid(cx, cy) && hasMark(mark, cx, cy))
			marks.get(mark).remove(coordId(cx, cy));
	}

	/** Return TRUE if "Collisions" layer contains a collision value **/
	public inline function hasCollision(cx, cy):Bool {
		return !isValid(cx, cy) ? true : collisionLayers.contains(data.l_Collisions.getInt(cx, cy));
	}

	public inline function hasLadder(cx, cy):Bool {
		return !isValid(cx, cy) ? true : data.l_Collisions.getInt(cx, cy) == 1
			|| hasCollision(cx, cy)
			&& data.l_Collisions.getInt(cx, cy + 1) == 1;
	}

	public inline function hasOneWayPlatform(cx, cy):Bool {
		return !isValid(cx, cy) ? true : data.l_Collisions.getInt(cx, cy) == 2;
	}

	/** Render current level**/
	function render() {
		root.removeChildren();

		var tg = new h2d.TileGroup(tilesetSource, root);
		data.l_Background.renderInTileGroup(tg, false);
		data.l_Details.renderInTileGroup(tg, false);
		data.l_Details_tiles.renderInTileGroup(tg, false);
		data.l_Extra_details.renderInTileGroup(tg, false);
		data.l_Collisions.renderInTileGroup(tg, false);
		data.l_CollisionDetails.renderInTileGroup(tg, false);
	}

	override function postUpdate() {
		super.postUpdate();

		if (invalidated) {
			invalidated = false;
			render();
		}
	}

	private inline function createLevelMarks() {
		for (cy in 0...hei) {
			for (cx in 0...wid) {
				// only grab if the ledge is two 'grid coords' higher than the entity
				// no collision at current pos, north, or south
				if (!hasCollision(cx, cy) && !hasCollision(cx, cy + 1) && !hasCollision(cx, cy - 1)) {
					// if collision to the east of current pos and no collision to the northeast
					if (hasCollision(cx + 1, cy) && !hasCollision(cx + 1, cy - 1)) {
						setMarks(cx, cy, [Grab, GrabRight]);
					}

					if (hasCollision(cx - 1, cy) && !hasCollision(cx - 1, cy - 1)) {
						setMarks(cx, cy, [Grab, GrabLeft]);
					}
				}

				// no collision at current pos or north but has collsion south.
				if (!hasCollision(cx, cy) && hasCollision(cx, cy + 1) && !hasCollision(cx, cy - 1)) {
					// if collision to the east of current pos and no collision to the northeast
					if (hasCollision(cx + 1, cy) && !hasCollision(cx + 1, cy - 1)) {
						setMark(SmallStep, cx, cy, 1);
					}

					if (hasCollision(cx - 1, cy) && !hasCollision(cx - 1, cy - 1)) {
						setMark(SmallStep, cx, cy, -1);
					}
				}

				if (!hasCollision(cx, cy) && hasCollision(cx, cy + 1)) {
					if (hasCollision(cx + 1, cy) || (!hasCollision(cx + 1, cy + 1) && !hasCollision(cx + 1, cy + 2))) {
						setMarks(cx, cy, [PlatformEnd, PlatformEndRight]);
					}
					if (hasCollision(cx - 1, cy) || (!hasCollision(cx - 1, cy + 1) && !hasCollision(cx - 1, cy + 2))) {
						setMarks(cx, cy, [PlatformEnd, PlatformEndLeft]);
					}
				}

				if (hasCollision(cx, cy) && isOuterWall(cx, cy)) {
					setMarks(cx, cy, [Walls]);
				}

				if (hasOneWayPlatform(cx, cy)) {
					setMarks(cx, cy, [OneWayPlatform]);
				}

				if (hasLadder(cx, cy)) {
					setMarks(cx, cy, [Ladder]);
				}
			}
		}
	}

	private inline function isOuterWall(cx, cy) {
		return !hasCollisionAboveOrBelow(cx, cy) || !hasCollisionLeftOrRight(cx, cy) || missingDiagonalCollision(cx, cy);
	}

	private inline function hasCollisionAboveOrBelow(cx, cy) {
		return hasCollision(cx, cy - 1) || hasCollision(cx, cy + 1);
	}

	private inline function hasCollisionLeftOrRight(cx, cy) {
		return hasCollision(cx - 1, cy) || hasCollision(cx + 1, cy);
	}

	private inline function missingDiagonalCollision(cx, cy) {
		return !hasCollision(cx + 1, cy - 1) || !hasCollision(cx - 1, cy - 1) || !hasCollision(cx + 1, cy + 1) || !hasCollision(cx - 1, cy + 1);
	}
}
