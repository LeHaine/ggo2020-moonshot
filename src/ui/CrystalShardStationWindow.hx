package ui;

import h2d.Flow.FlowAlign;
import data.Trait;
import dn.Rand;
import hxd.Key;

class PermaUpgrade {
	public var game(get, never):Game;

	inline function get_game() {
		return Game.ME;
	}

	public var name:String;
	public var desc:String;
	public var maxLevel:Int;
	public var level(get, never):Int;

	public function get_level():Int {
		return 0;
	}

	public var price(get, never):Int;

	inline function get_price() {
		return calcPrice(level);
	}

	public function modify() {}

	public function calcPrice(level:Int):Int {
		return M.ceil((level * (level + 1)) / 2) * 10;
	}
}

class BonusCoinsUpgrade extends PermaUpgrade {
	public function new() {
		name = "Bonus coins";
		desc = "Increases the amount of coins that are dropped from an enemy by 1% each level";
		maxLevel = 50;
	}

	public override function modify() {
		game.permaUpgrades.bonusCoinsLvl++;
	}

	public override function get_level() {
		return game.permaUpgrades.bonusCoinsLvl;
	}
}

class IncreasedCoinsCarriedOverUpgrade extends PermaUpgrade {
	public function new() {
		name = "Coins kept on death";
		desc = "Increases the amount of coins that are kept on death by 250 for each level";
		maxLevel = 10;
	}

	public override function modify() {
		game.permaUpgrades.coinsCarriedOverLvl++;
	}

	public override function get_level() {
		return game.permaUpgrades.coinsCarriedOverLvl;
	}

	public override function calcPrice(level:Int):Int {
		return super.calcPrice(level) * 10;
	}
}

class BonusCrystalShardsUpgrade extends PermaUpgrade {
	public function new() {
		name = "Bonus Crystal Shards";
		desc = "Increases the amount of crystal shards that are dropped from an enemy by 1% each level";
		maxLevel = 50;
	}

	public override function modify() {
		game.permaUpgrades.bonusShardsLvl++;
	}

	public override function get_level() {
		return game.permaUpgrades.bonusShardsLvl;
	}

	public override function calcPrice(level:Int):Int {
		return super.calcPrice(level) * 2;
	}
}

class PersonalModStationUpgrade extends PermaUpgrade {
	public function new() {
		name = "Personal Modification Station";
		desc = "Unlock your own personal modification station that can be used before each run";
		maxLevel = 1;
	}

	public override function modify() {
		game.permaUpgrades.personalModStation = true;
		game.unlockPersonalModStation();
	}

	public override function get_level() {
		return game.permaUpgrades.personalModStation ? 1 : 0;
	}

	public override function calcPrice(level:Int):Int {
		return 1000;
	}
}

class IncreasedHealthUpgrade extends PermaUpgrade {
	public function new() {
		name = "Your Life";
		desc = "Increases your health by 1% each level";
		maxLevel = 10;
	}

	public override function modify() {
		game.permaUpgrades.increaseHealthLvl++;
	}

	public override function get_level() {
		return game.permaUpgrades.increaseHealthLvl;
	}

	public override function calcPrice(level:Int):Int {
		return super.calcPrice(level);
	}
}

class HigherTieredTraitsChanceUpgrade extends PermaUpgrade {
	public function new() {
		name = "Tiered Traits";
		desc = "Increases the chance of receiving a higher tiered trait at modification stations for each slot";
		maxLevel = 10;
	}

	public override function modify() {
		game.permaUpgrades.higherTieredTraitsLvl++;
	}

	public override function get_level() {
		return game.permaUpgrades.higherTieredTraitsLvl;
	}

	public override function calcPrice(level:Int):Int {
		return super.calcPrice(level) * 5;
	}
}

class CrystalShardStationWindow extends dn.Process {
	public static var ME:CrystalShardStationWindow;

	public var ca:dn.heaps.Controller.ControllerAccess;

	var mask:h2d.Graphics;
	var masterBox:h2d.Flow;
	var masterFlow:h2d.Flow;

	var itemMask:h2d.Mask;
	var itemFlow:h2d.Flow;

	var shards:h2d.Text;

	var cursorIdx = 0;

	var items:Array<{
		flow:h2d.Flow,
		price:Int,
		desc:String,
		cb:Void->Void
	}>;

	var onItemBought:Null<() -> Void>;

	public function new(?itemBoughtCb:() -> Void) {
		super(Main.ME);
		ME = this;
		onItemBought = itemBoughtCb;
		ca = Main.ME.controller.createAccess("modStation", true);

		createRootInLayers(Main.ME.root, Const.DP_UI);
		root.filter = new h2d.filter.ColorMatrix(); // force pixel perfect rendering

		mask = new h2d.Graphics(root);
		tw.createS(mask.alpha, 0 > 1, 0.3);

		masterBox = new h2d.Flow(root);
		masterBox.layout = Vertical;
		masterBox.verticalAlign = Middle;
		masterBox.horizontalAlign = Middle;

		masterFlow = new h2d.Flow(masterBox);
		masterFlow.padding = 32;
		masterFlow.verticalSpacing = 4;
		masterFlow.layout = Vertical;
		masterFlow.horizontalAlign = Middle;
		masterFlow.backgroundTile = Assets.tiles.getTile("uiWindow");
		masterFlow.borderHeight = masterFlow.borderWidth = 32;

		var titleTf = new h2d.Text(Assets.fontPixelLarge, masterFlow);
		titleTf.text = "Crystal Shard Station";

		var subTitleTf = new h2d.Text(Assets.fontPixelMedium, masterFlow);
		subTitleTf.text = "Unlock permanent upgrades";

		var shardsBox = new h2d.Flow(masterFlow);
		shardsBox.verticalAlign = Middle;
		shardsBox.horizontalSpacing = 4;
		shardsBox.padding = 16;

		shards = new h2d.Text(Assets.fontPixelMedium, shardsBox);
		shards.textColor = 0xFF3333;
		var crystalIcon = Assets.tiles.h_get("crystal", shardsBox);
		crystalIcon.scale(0.5);

		itemMask = new h2d.Mask(masterFlow.innerWidth, 400, masterFlow);

		itemFlow = new h2d.Flow(itemMask);
		itemFlow.layout = Vertical;
		itemFlow.verticalSpacing = 1;

		masterFlow.addSpacing(8);
		var tf = new h2d.Text(Assets.fontPixelMedium, masterFlow);
		if (Game.ME.ca.isGamePad()) {
			tf.text = "[B] to cancel";
		} else {
			tf.text = "ESC to cancel";
		}
		tf.textColor = 0xd95b52;

		cd.setS("lock", 0.2);
		addUpgrades();
		itemMask.width = itemFlow.innerWidth;
		itemMask.height = Std.int(Math.min(itemFlow.outerHeight, 400));
		itemFlow.minHeight = 900;
		onResize();
		Game.ME.pause();
	}

	function addUpgrades() {
		itemFlow.enableInteractive = false;
		items = [];
		itemFlow.removeChildren();

		addItem(new BonusCoinsUpgrade(), 0);
		addItem(new BonusCrystalShardsUpgrade(), 1);
		addItem(new IncreasedCoinsCarriedOverUpgrade(), 2);
		addItem(new PersonalModStationUpgrade(), 3);
		addItem(new HigherTieredTraitsChanceUpgrade(), 4);
		addItem(new IncreasedHealthUpgrade(), 5);

		itemFlow.enableInteractive = true;
		itemFlow.interactive.onWheel = (e) -> {
			var newY = itemFlow.y + 25 * -M.sign(e.wheelDelta);
			itemFlow.y = hxd.Math.clamp(newY, -itemFlow.outerHeight / 2, 0);
		}
	}

	function addItem(upgrade:PermaUpgrade, index:Int) {
		var flow = new h2d.Flow(itemFlow);
		flow.verticalAlign = Top;
		flow.backgroundTile = Assets.tiles.getTile("uiButton");
		flow.borderHeight = flow.borderWidth = 16;
		flow.padding = 4;
		flow.maxWidth = flow.minWidth = 290;
		flow.minHeight = 100;
		flow.horizontalSpacing = 10;
		flow.enableInteractive = true;

		var price = upgrade.price;
		var shards = Game.ME.shards;

		var infoBox = new h2d.Flow(flow);
		infoBox.maxWidth = infoBox.minWidth = 300;
		infoBox.padding = 8;
		infoBox.verticalSpacing = 8;
		infoBox.layout = Vertical;

		var nameTf = new h2d.Text(Assets.fontPixelMedium, infoBox);
		nameTf.text = upgrade.name;
		nameTf.maxWidth = 300;
		nameTf.textColor = price <= shards ? 0xFFFFFF : 0xE77272;

		var desc = new h2d.Text(Assets.fontPixelSmall, infoBox);
		desc.text = upgrade.desc;
		desc.maxWidth = 300;
		desc.textColor = 0xBBBBBB;

		var priceLevelBox = new h2d.Flow(flow);
		priceLevelBox.minHeight = flow.innerHeight;
		priceLevelBox.layout = Vertical;
		priceLevelBox.maxWidth = priceLevelBox.minWidth = 90;
		priceLevelBox.padding = 8;

		var levelTf = new h2d.Text(Assets.fontPixelSmall, priceLevelBox);
		levelTf.text = 'Level: ${upgrade.level} / ${upgrade.maxLevel}';
		levelTf.textColor = 0x8CD12E;

		var priceBox = new h2d.Flow(priceLevelBox);
		priceBox.horizontalAlign = FlowAlign.Right;
		priceLevelBox.getProperties(priceBox).verticalAlign = FlowAlign.Bottom;
		priceBox.maxWidth = priceBox.minWidth = 115;
		priceBox.horizontalSpacing = 8;

		flow.addSpacing(8);

		var priceTf = new h2d.Text(Assets.fontPixelMedium, priceBox);
		setUpgradePrice(upgrade, priceTf);
		var crystalIcon = Assets.tiles.h_get("crystal", priceBox);
		crystalIcon.scale(0.5);

		var interact = () -> {
			var maxed = upgrade.level == upgrade.maxLevel;
			if (Game.ME.shards >= upgrade.price && !maxed) {
				Game.ME.shards -= upgrade.price;
				upgrade.modify();
				Game.ME.storage.save();
				setUpgradePrice(upgrade, priceTf);
				if (onItemBought != null) {
					onItemBought();
				}
				Assets.SLIB.accept0(0.5);
			}
		}

		flow.interactive.propagateEvents = true;
		flow.interactive.onOver = (e) -> {
			Assets.SLIB.select0(0.5);
			cursorIdx = index;
		}
		flow.interactive.onClick = (e) -> {
			interact();
		}

		items.push({
			flow: flow,
			price: price,
			desc: upgrade.desc,
			cb: interact,
		});
	}

	function setUpgradePrice(upgrade:PermaUpgrade, tf:h2d.Text) {
		var shards = Game.ME.shards;
		var price = upgrade.price;
		var maxed = upgrade.level == upgrade.maxLevel;
		if (maxed) {
			tf.text = "MAXED";
			tf.textColor = 0xFF9900;
		} else if (price > 0) {
			tf.text = Std.string(price);
			tf.textColor = price <= shards ? 0xFF9900 : 0xD20000;
		} else {
			tf.text = "FREE";
			tf.textColor = 0x8CD12E;
		}
	}

	var closed:Bool;

	function close() {
		if (!closed) {
			closed = true;
			tw.createS(root.alpha, 0, 0.4);
			tw.createS(masterFlow.y, -masterFlow.outerHeight, 0.4).end(() -> {
				destroy();
			});
		}
	}

	override function update() {
		super.update();

		shards.text = Std.string(Game.ME.shards);

		for (item in items) {
			item.flow.alpha = 0.7;
		}
		var item = items[cursorIdx];

		if (item != null) {
			item.flow.alpha = 1;

			if ((ca.downPressed() || ca.dpadDownPressed()) && cursorIdx < items.length - 1) {
				cursorIdx++;
				Assets.SLIB.select0(0.5);
				itemFlow.y -= item.flow.outerHeight;
			}

			if ((ca.upPressed() || ca.dpadUpPressed()) && cursorIdx > 0) {
				cursorIdx--;
				Assets.SLIB.select0(0.5);
				itemFlow.y += item.flow.outerHeight;
			}
			if (!cd.has("lock") && ca.aPressed()) {
				item.cb();
			}
		}

		if (ca.bPressed() || Key.isPressed(Key.ESCAPE)) {
			close();
		}
	}

	override public function onDispose() {
		super.onDispose();
		if (ME == this) {
			ME = null;
		}
		ca.dispose();
		Game.ME.resume();
	}

	override function onResize() {
		super.onResize();

		mask.clear();
		mask.beginFill(0x000000, 0.75);
		mask.drawRect(0, 0, Main.ME.w(), Main.ME.h());

		masterBox.reflow();
		masterBox.x = Std.int(Main.ME.w() * 0.5 - masterBox.outerWidth * 0.5);
		masterBox.y = Std.int(Main.ME.h() * 0.5 - masterBox.outerHeight * 0.5);
	}
}
