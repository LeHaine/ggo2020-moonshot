class Const {
	public static var FPS = 60;
	public static var FIXED_FPS = 30;
	public static var AUTO_SCALE_TARGET_WID = 480; // -1 to disable auto-scaling on width
	public static var AUTO_SCALE_TARGET_HEI = -1; // -1 to disable auto-scaling on height
	public static var SCALE = 1.0; // ignored if auto-scaling
	public static var UI_SCALE = 1.0;
	public static var GRAVITY = 0.028;
	public static var GRID = 16;

	static var _uniq = 0;
	public static var NEXT_UNIQ(get, never):Int;

	static inline function get_NEXT_UNIQ()
		return _uniq++;

	public static var INFINITE = 999999;

	static var _inc = 0;
	public static var DP_BG = _inc++;
	public static var DP_FX_BG = _inc++;
	public static var DP_DROPS = _inc++;
	public static var DP_MAIN = _inc++;
	public static var DP_FRONT = _inc++;
	public static var DP_FRONT_DETAILS = _inc++;
	public static var DP_FX_FRONT = _inc++;
	public static var DP_TOP = _inc++;
	public static var DP_UI = _inc++;
	public static var DP_UI_FRONT = _inc++;

	static var _soundInc = 2;
	public static var HERO_SHOTS = _soundInc++;
	public static var HERO_JUMP = _soundInc++;
	public static var HERO_EXTRA = _soundInc++;
	public static var MOB_HIT = _soundInc++;
	public static var MOB_DEATH = _soundInc++;
	public static var MOB_ATTACK = _soundInc++;
	public static var MOB_JUMP = _soundInc++;
	public static var MOB_EXTRA = _soundInc++;
	public static var BARREL_EXPLOSION = _soundInc++;
	public static var COLLECTIBLES = _soundInc++;
	public static var EXTRA = _soundInc++;
	public static var UI = _soundInc++;
}
