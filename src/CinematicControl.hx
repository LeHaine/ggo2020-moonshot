import entity.Mob;
import dn.LocalStorage;

class CinematicControl extends dn.Process {
	public static var ALL:Array<CinematicControl> = [];

	public var game(get, never):Game;

	inline function get_game()
		return Game.ME;

	public var level(get, never):Level;

	inline function get_level()
		return Game.ME.level;

	public var fx(get, never):Fx;

	inline function get_fx()
		return Game.ME.fx;

	var cm:dn.Cinematic;

	var controlColor = 0x736680;

	public function new(id:CinematicId, ?trigger:World.Entity_CinematicTrigger) {
		super(game);

		ALL.push(this);
		cm = new dn.Cinematic(Const.FPS);

		switch id {
			case PrisonWakeup:
				if (game.storage.settings.finishedTutorial) {
					destroy();
				} else {
					performPrisonWakeupCinematic(trigger);
				}

			case PrisonKickTutorial:
				if (game.storage.settings.finishedTutorial) {
					destroy();
				} else {
					performKickTutorialCinematic(trigger);
				}

			case PrisonPrimaryAttackTutorial:
				if (game.storage.settings.finishedTutorial) {
					destroy();
				} else {
					performPrimaryAttackTutorialCinematic(trigger);
				}

			case PrisonDashTutorial:
				if (game.storage.settings.finishedTutorial) {
					destroy();
				} else {
					performDashTutorialCinematic();
				}

			case PrisonSecondaryAttackTutorial:
				if (game.storage.settings.finishedTutorial) {
					destroy();
				} else {
					performSecondaryAttackTutorialCinematic(trigger);
				}
			case PrisonNewCell:
				if (game.storage.settings.sawNewPrisonCell) {
					destroy();
				} else {
					performNewPrisonCellCinematic();
				}
		}
	}

	private function performPrisonWakeupCinematic(trigger:World.Entity_CinematicTrigger) {
		if (trigger == null) {
			return;
		}
		var targetPoint = new CPoint(trigger.f_cameraTarget.cx, trigger.f_cameraTarget.cy);
		var mobColor = 0xbf2242;

		cm.create({
			displayText("They left the door open?");
			end;
			clearText();
			game.camera.trackPoint(targetPoint, false);
			500;
			displayText("We finally did it! We shrunk the moon and harnessed its power within this new weapon.", mobColor);
			end;
			displayText("I shall call it, the Moon...inator? ...the Lunarinator? ...Moon shotinator? It shoots the moon, OK!", mobColor);
			end;
			displayText("When we get time, we should blast our test subject with it to see what happens.", mobColor);
			end;
			clearText();
			for (mob in entity.Mob.ALL) {
				if (mob.patrolTarget != null) {
					mob.moveTo(mob.patrolTarget.cx);
				}
			}
			1500;
			game.trackHero(false);
			500;
			displayText("Yikes.");
			end;
			complete();
		});
	}

	private function performKickTutorialCinematic(trigger:World.Entity_CinematicTrigger) {
		if (trigger == null) {
			return;
		}
		var targetPoint = new CPoint(trigger.f_cameraTarget.cx, trigger.f_cameraTarget.cy);
		cm.create({
			displayText("That scientist is just standing there by that ledge. What if I kick him off it?");
			game.camera.trackPoint(targetPoint, false);
			end;
			displayText("To kick hit the [F] key when near an enenmy. This will temporarily stun them as well as slightly damaging them.", controlColor);
			end;
			game.trackHero(false);
			500;
			complete();
		});
	}

	private function performPrimaryAttackTutorialCinematic(trigger:World.Entity_CinematicTrigger) {
		if (trigger == null) {
			return;
		}
		var targetPoint = new CPoint(trigger.f_cameraTarget.cx, trigger.f_cameraTarget.cy);
		cm.create({
			displayText("He is just standing there as well. What is with these guys? Maybe I should just end him?");
			game.camera.trackPoint(targetPoint, false);
			end;
			displayText("Pressing [Mouse-Left] button will fire the weapons primary attack.", controlColor);
			end;
			game.trackHero(false);
			500;
			complete();
		});
	}

	private function performDashTutorialCinematic() {
		cm.create({
			displayText("A random hole in the floor? This is an odd place. I think I can jump it.");
			end;
			displayText("Press [SPACE] to jump and then [SHIFT + SPACE] while in the air to dash further than you can jump.", controlColor);
			end;
			150;
			complete();
		});
	}

	private function performSecondaryAttackTutorialCinematic(trigger:World.Entity_CinematicTrigger) {
		if (trigger == null) {
			return;
		}
		var targetPoint = new CPoint(trigger.f_cameraTarget.cx, trigger.f_cameraTarget.cy);
		cm.create({
			displayText("I'm no longer shocked at this point. I am just going to blast him.");
			game.camera.trackPoint(targetPoint, false);
			end;
			displayText("Press and hold your [Mouse-Right] button to charge and fire your secondary attack. This can cause massive damage as well as AOE damage.",
				controlColor);
			end;
			game.trackHero(false);
			500;
			game.storage.settings.finishedTutorial = true;
			game.storage.save();
			complete();
		});
	}

	private function performNewPrisonCellCinematic() {
		cm.create({
			displayText("This looks different. Looks like they changed it up a bit.");
			end;
			150;
			game.storage.settings.sawNewPrisonCell = true;
			game.storage.save();
			complete();
		});
	}

	private function displayText(str:String, ?c = 0x589bd1) {
		clearText();
		var f = new h2d.Flow();
		game.root.add(f, Const.DP_UI);
		f.setScale(Const.SCALE);
		curText = f;
		f.borderWidth = 4;
		f.borderHeight = 4;
		f.layout = Vertical;
		f.padding = 8;

		var bg = new h2d.ScaleGrid(Assets.tiles.getTile("uiDialogBox"), 4, 4, f);
		f.getProperties(bg).isAbsolute = true;
		bg.colorMatrix = dn.Color.getColorizeMatrixH2d(c);

		f.onAfterReflow = function() {
			bg.width = f.outerWidth;
			bg.height = f.outerHeight;
		}

		var tf = new h2d.Text(Assets.fontPixel, f);
		tf.text = str;
		tf.maxWidth = 250;
		tf.textColor = 0xffffff;

		f.addSpacing(16);
		var tf = new h2d.Text(Assets.fontPixel, f);
		if (game.ca.isGamePad()) {
			tf.text = "[B] to continue";
		} else {
			tf.text = "F to continue";
		}
		tf.text = "F to continue";
		tf.textColor = 0xffffff;
		f.getProperties(tf).align(Top, Right);

		f.x = Std.int(w() / Const.SCALE * 0.5 - f.outerWidth * 0.5 + rnd(0, 30, true));
		f.y = rnd(20, 40);

		tw.createS(f.x, f.x - 20 > f.x, 0.2);
		cd.setS("skipLock", 0.2);
	}

	var curText:Null<h2d.Flow>;

	private function clearText() {
		if (curText != null) {
			var f = curText;
			curText = null;
			tw.createS(f.x, f.x + 20, 0.2);
			tw.createS(f.alpha, 0, 0.2).end(() -> {
				f.remove();
			});
		}
	}

	private function complete() {
		clearText();
		delayer.addS(destroy, 0.3);
	}

	override function update() {
		cm.update(tmod);
		super.update();

		if (game.ca.bPressed())
			if (!cd.has("skipLock")) {
				cm.signal();
			}
	}

	override function postUpdate() {
		super.postUpdate();
		if (curText != null) {
			curText.setScale(Const.SCALE);
		}
	}

	override function onDispose() {
		super.onDispose();
		cm.destroy();
		cm = null;
		ALL.remove(this);
	}

	public static function isEmpty() {
		return ALL.length == 0;
	}
}
