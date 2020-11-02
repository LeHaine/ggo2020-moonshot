package tools;

import dn.Lib.irnd;

class LootPicker {
	private var lastRollPass = false;
	private var lastSubRollPass = false;

	private function new() {}

	public static function create():LootPicker {
		return new LootPicker();
	}

	/**
	 * Rolls a number between a minumum and maxiumum values. Minimum being the successful roll value threshold.
	 * For example:
	 * if the minumum was set to 5 and the maximum to 100 it would be a 5/100 chance.
	 * Rolling anywhere from 1-5 would be a successfully roll. Anything higher would be failed. If the roll fails then the subrolls will not be rolled.
	 * @param min the mininum value to for the roll to pass.
	 * @param max the maximum value to roll against.
	 * @param onSuccessfulRoll the callback when rolled successfully.
	 * @return LootPicker
	 */
	public function roll(min:Int, max:Int, ?onSuccessfulRoll:Int->Void):LootPicker {
		reset();
		var result = irnd(1, max);
		lastRollPass = result <= min;

		#if debug
		if (ui.Console.ME.hasFlag("rolls_100")) {
			lastRollPass = true;
			if (onSuccessfulRoll != null) {
				onSuccessfulRoll(min);
			}
		}
		#else
		if (lastRollPass && onSuccessfulRoll != null) {
			onSuccessfulRoll(result);
		}
		#end

		return this;
	}

	/**
	 * Rolls a number between a minumum and maximum value. The same logic as the [roll] function.
	 * This function depends on the previous roll being successfull in order to roll. If it fails then these calls to this function will not attempt to roll.
	 * This function also depends on previous sub-rolls for the current roll to have failed.
	 * If a sub-roll rolls successfully, then any other sub-rolls called after will not attempt a roll.
	 * @param min the mininum value to for the roll to pass.
	 * @param max the maximum value to roll against.
	 * @param onSuccessfulRoll the callback when rolled successfully.
	 * @return LootPicker
	 */
	public function subRoll(min:Int, max:Int, ?onSuccessfulRoll:Int->Void):LootPicker {
		#if debug
		if (ui.Console.ME.hasFlag("rolls_100")) {
			if (onSuccessfulRoll != null) {
				onSuccessfulRoll(min);
			}
		}
		lastSubRollPass = true;
		#else
		if (lastRollPass && !lastSubRollPass) {
			var result = irnd(1, max);
			lastSubRollPass = result <= min;

			if (lastSubRollPass && onSuccessfulRoll != null) {
				onSuccessfulRoll(result);
			}
		}
		#end

		return this;
	}

	/**
	 * Resets results of the rolls.
	 */
	public function reset() {
		lastRollPass = false;
		lastSubRollPass = false;
	}
}
