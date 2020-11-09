package ui;

import h2d.Flow.FlowAlign;
import data.WeaponTrait;
import dn.Rand;
import hxd.Key;

class ModStationWindow extends dn.Process {
	public static var ME:ModStationWindow;

	public var ca:dn.heaps.Controller.ControllerAccess;

	var mask:h2d.Graphics;
	var masterBox:h2d.Flow;
	var masterFlow:h2d.Flow;
	var itemFlow:h2d.Flow;

	var money:h2d.Text;

	var cursorIdx = 0;

	var items:Array<{
		flow:h2d.Flow,
		price:Int,
		desc:String,
		cb:Void->Void
	}>;

	public function new(seed:Int) {
		super(Main.ME);
		ME = this;
		ca = Main.ME.controller.createAccess("modStation", true);

		createRootInLayers(Main.ME.root, Const.DP_UI);

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

		var titleTf = new h2d.Text(Assets.fontLarge, masterFlow);
		titleTf.text = "Modification Station";

		var subTitleTf = new h2d.Text(Assets.fontSmall, masterFlow);
		subTitleTf.text = "Modify your weapon traits here";

		var moneyBox = new h2d.Flow(masterFlow);
		moneyBox.verticalAlign = Middle;
		moneyBox.horizontalSpacing = 4;
		moneyBox.padding = 16;

		money = new h2d.Text(Assets.fontMedium, moneyBox);
		money.textColor = 0xFF3333;
		var coinIcon = Assets.tiles.h_get("coin", moneyBox);
		coinIcon.scale(0.5);

		itemFlow = new h2d.Flow(masterFlow);
		itemFlow.layout = Vertical;
		itemFlow.verticalSpacing = 1;

		masterFlow.addSpacing(8);
		var tf = new h2d.Text(Assets.fontMedium, masterFlow);
		if (Game.ME.ca.isGamePad()) {
			tf.text = "[B-Button] to cancel";
		} else {
			tf.text = "ESC to cancel";
		}
		tf.textColor = 0xFFA8A2;

		cd.setS("lock", 0.2);
		generateTraits(seed);
		onResize();
		Game.ME.pause();
	}

	function generateTraits(seed) {
		items = [];
		itemFlow.removeChildren();

		var rnd = new Rand(seed);

		#if debug
		var testTrait = new data.Traits.SplitShot();

		addItem(testTrait, 0);
		addItem(testTrait, 1);
		addItem(testTrait, 2);
		#end
	}

	function addItem(trait:WeaponTrait, index:Int) {
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

		var price = trait.price;
		var money = Game.ME.money;

		var infoBox = new h2d.Flow(flow);
		infoBox.maxWidth = infoBox.minWidth = 300;
		infoBox.padding = 8;
		infoBox.verticalSpacing = 8;
		infoBox.layout = Vertical;

		var nameTf = new h2d.Text(Assets.fontMedium, infoBox);
		nameTf.text = trait.name;
		nameTf.maxWidth = 300;
		nameTf.textColor = price <= money ? 0xFFFFFF : 0xE77272;

		var desc = new h2d.Text(Assets.fontSmall, infoBox);
		desc.text = trait.desc;
		desc.maxWidth = 300;
		desc.textColor = 0xBBBBBB;

		var attrBox = new h2d.Flow(infoBox);
		attrBox.horizontalSpacing = 8;
		attrBox.maxWidth = attrBox.minWidth = 250;

		var attrTf = new h2d.Text(Assets.fontMedium, attrBox);
		attrTf.text = '${trait.attribute}:';
		attrTf.textColor = 0xBBBBBB;

		var attrValueTf = new h2d.Text(Assets.fontMedium, attrBox);
		attrBox.getProperties(attrValueTf).horizontalAlign = FlowAlign.Right;
		attrValueTf.text = '+${Std.string(trait.attributeValue)}';
		attrValueTf.textColor = 0x00FF00;

		var priceBox = new h2d.Flow(flow);
		flow.getProperties(priceBox).verticalAlign = FlowAlign.Bottom;
		priceBox.horizontalSpacing = 8;
		priceBox.maxWidth = priceBox.minWidth = 90;
		priceBox.padding = 8;

		flow.addSpacing(8);

		var priceTf = new h2d.Text(Assets.fontMedium, priceBox);
		if (price > 0) {
			priceTf.text = Std.string(price);
			priceTf.textColor = price <= money ? 0xFF9900 : 0xD20000;
		} else {
			priceTf.text = "FREE";
			priceTf.textColor = 0x8CD12E;
		}

		var coinIcon = Assets.tiles.h_get("coin", priceBox);
		coinIcon.scale(0.5);

		var interact = () -> {
			if (Game.ME.money >= trait.price) {
				close();
				// TODO upgrade weapon impl here
			}
		}

		flow.interactive.onOver = (e) -> {
			//		Assets.SBANK.select(1);
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
			//		Assets.SBANK.accept(0.8);
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

		money.text = Std.string(Game.ME.money);

		for (item in items) {
			item.flow.alpha = 0.7;
		}
		var item = items[cursorIdx];

		if (item != null) {
			item.flow.alpha = 1;

			if (ca.downPressed() && cursorIdx < items.length - 1) {
				cursorIdx++;
			}

			if (ca.upPressed() && cursorIdx > 0) {
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
