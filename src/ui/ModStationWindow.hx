package ui;

import h2d.Flow.FlowAlign;
import data.Trait;
import dn.Rand;
import hxd.Key;

class ModStationWindow extends dn.Process {
	public static var ME:ModStationWindow;

	public var ca:dn.heaps.Controller.ControllerAccess;

	var mask:h2d.Graphics;
	var masterBox:h2d.Flow;
	var masterFlow:h2d.Flow;
	var itemFlow:h2d.Flow;

	var coins:h2d.Text;

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
		titleTf.text = "Modification Station";

		var subTitleTf = new h2d.Text(Assets.fontPixelMedium, masterFlow);
		subTitleTf.text = "Choose one trait to upgrade";

		var coinsBox = new h2d.Flow(masterFlow);
		coinsBox.verticalAlign = Middle;
		coinsBox.horizontalSpacing = 4;
		coinsBox.padding = 16;

		coins = new h2d.Text(Assets.fontPixelMedium, coinsBox);
		coins.textColor = 0xFF3333;
		var coinIcon = Assets.tiles.h_get("coin", coinsBox);
		coinIcon.scale(0.5);

		itemFlow = new h2d.Flow(masterFlow);
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
		generateTraits();
		onResize();
		Game.ME.pause();
	}

	function generateTraits() {
		items = [];
		itemFlow.removeChildren();

		addItem(drawFreeSlot(), 0, 0);
		addItem(drawNormalPriceSlot(), 1, 1);
		addItem(drawExpensiveSlot(), 2, 2.5);
	}

	function drawFreeSlot() {
		var tieredIncrease = Game.ME.permaUpgrades.higherTieredTraitsLvl * 0.1;
		var traitList = new dn.RandList<Tier>();
		traitList.add(Tier.C, 50);
		traitList.add(Tier.B, 30);
		var chance = 15 + Std.int(15 * tieredIncrease);
		traitList.add(Tier.A, chance);
		chance = 5 + Std.int(5 * tieredIncrease);
		traitList.add(Tier.S, chance);

		return drawTrait(traitList.draw());
	}

	function drawNormalPriceSlot() {
		var tieredIncrease = Game.ME.permaUpgrades.higherTieredTraitsLvl * 0.1;
		var traitList = new dn.RandList<Tier>();
		traitList.add(Tier.C, 40);
		traitList.add(Tier.B, 30);
		var chance = 20 + Std.int(20 * tieredIncrease);
		traitList.add(Tier.A, chance);
		chance = 10 + Std.int(10 * tieredIncrease);
		traitList.add(Tier.S, chance);

		return drawTrait(traitList.draw());
	}

	function drawExpensiveSlot() {
		var tieredIncrease = Game.ME.permaUpgrades.higherTieredTraitsLvl * 0.1;
		var traitList = new dn.RandList<Tier>();
		traitList.add(Tier.C, 10);
		traitList.add(Tier.B, 20);
		var chance = 40 + Std.int(40 * tieredIncrease);
		traitList.add(Tier.A, chance);
		chance = 30 + Std.int(30 * tieredIncrease);
		traitList.add(Tier.S, chance);

		return drawTrait(traitList.draw());
	}

	private function drawTrait(?tier:Tier) {
		if (tier != null) {
			return TraitSelector.chooseRandomTraitFromTier(tier);
		}
		return null;
	}

	function addItem(trait:Trait, index:Int, priceMul:Float = 1.) {
		var flow = new h2d.Flow(itemFlow);
		flow.verticalAlign = Top;
		flow.backgroundTile = Assets.tiles.getTile("uiButton");
		flow.borderHeight = flow.borderWidth = 16;
		flow.padding = 4;
		flow.maxWidth = flow.minWidth = 290;
		flow.horizontalSpacing = 10;
		flow.enableInteractive = true;

		var iconBox = new h2d.Flow(flow);
		iconBox.horizontalSpacing = 8;
		iconBox.maxWidth = iconBox.minWidth = 75;
		iconBox.maxHeight = iconBox.minHeight = 75;
		iconBox.padding = 8;
		iconBox.verticalAlign = Middle;

		Assets.tiles.h_get(trait.icon, iconBox);

		var price = Std.int(trait.price * priceMul);
		var coins = Game.ME.coins;

		var infoBox = new h2d.Flow(flow);
		infoBox.maxWidth = infoBox.minWidth = 300;
		infoBox.padding = 8;
		infoBox.verticalSpacing = 8;
		infoBox.layout = Vertical;

		var nameTf = new h2d.Text(Assets.fontPixelMedium, infoBox);
		nameTf.text = trait.name;
		nameTf.maxWidth = 300;
		nameTf.textColor = price <= coins ? 0xFFFFFF : 0xE77272;

		var desc = new h2d.Text(Assets.fontPixelSmall, infoBox);
		desc.text = trait.desc;
		desc.maxWidth = 300;
		desc.textColor = 0xBBBBBB;

		for (attr in trait.attributes) {
			var attrBox = new h2d.Flow(infoBox);
			attrBox.horizontalSpacing = 8;
			attrBox.maxWidth = attrBox.minWidth = 250;

			var attrTf = new h2d.Text(Assets.fontPixelMedium, attrBox);
			attrTf.text = '${attr.name}:';
			attrTf.textColor = 0xBBBBBB;

			var attrValueTf = new h2d.Text(Assets.fontPixelMedium, attrBox);
			attrBox.getProperties(attrValueTf).horizontalAlign = FlowAlign.Right;
			var value = attr.isPercentage ? '${M.pretty(attr.value * 100)}%' : Std.string(attr.value);
			var sign = attr.value >= 0 ? "+" : "";
			var textColor = attr.positive ? 0x00FF00 : 0xFF0000;
			attrValueTf.text = '${sign}${value}';
			attrValueTf.textColor = textColor;
		}
		var priceBox = new h2d.Flow(flow);
		flow.getProperties(priceBox).verticalAlign = FlowAlign.Bottom;
		priceBox.horizontalSpacing = 8;
		priceBox.maxWidth = priceBox.minWidth = 90;
		priceBox.padding = 8;

		flow.addSpacing(8);

		var priceTf = new h2d.Text(Assets.fontPixelMedium, priceBox);
		if (price > 0) {
			priceTf.text = Std.string(price);
			priceTf.textColor = price <= coins ? 0xFF9900 : 0xD20000;
		} else {
			priceTf.text = "FREE";
			priceTf.textColor = 0x8CD12E;
		}

		var coinIcon = Assets.tiles.h_get("coin", priceBox);
		coinIcon.scale(0.5);

		var interact = () -> {
			if (Game.ME.coins >= price) {
				if (onItemBought != null) {
					onItemBought();
				}
				close();
				Game.ME.coins -= price;
				Game.ME.addTrait(trait);
			}
		}

		flow.interactive.onOver = (e) -> {
			cursorIdx = index;
		}
		flow.interactive.onClick = (e) -> interact();

		items.push({
			flow: flow,
			price: price,
			desc: trait.desc,
			cb: interact,
		});
	}

	var closed:Bool;

	function close() {
		if (!closed) {
			closed = true;
			cd.setS("closing", 99999);
			tw.createS(root.alpha, 0, 0.4);
			tw.createS(masterFlow.y, -masterFlow.outerHeight, 0.4).end(() -> {
				destroy();
			});
		}
	}

	override function update() {
		super.update();

		coins.text = Std.string(Game.ME.coins);

		for (item in items) {
			item.flow.alpha = 0.7;
		}
		var item = items[cursorIdx];

		if (item != null) {
			item.flow.alpha = 1;

			if (ca.upPressed() && cursorIdx < items.length - 1) {
				cursorIdx++;
			}

			if (ca.downPressed() && cursorIdx > 0) {
				cursorIdx--;
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
