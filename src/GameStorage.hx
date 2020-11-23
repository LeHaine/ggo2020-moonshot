import dn.LocalStorage;

typedef HeroData = {
	var hasGun:Bool;
}

typedef PermaUpgrades = {
	var bonusShardsLvl:Int;
	var bonusCoinsLvl:Int;
	var coinsCarriedOverLvl:Int;
	var personalModStation:Bool;
	var higherTieredTraitsLvl:Int;
	var increaseHealthLvl:Int;
}

typedef Settings = {
	var finishedTutorial:Bool;
	var sawNewPrisonCell:Bool;
	var musicMuted:Bool;
}

typedef Collectibles = {
	var coins:Int;
	var shards:Int;
}

class GameStorage {
	public var game(get, never):Game;

	inline function get_game()
		return Game.ME;

	public var heroData:HeroData;
	public var settings:Settings;
	public var permaUpgrades:PermaUpgrades;
	public var collectibles:Collectibles;

	public function new() {}

	public function loadSavedData() {
		heroData = LocalStorage.readObject("hero", true, {
			hasGun: false
		});
		settings = LocalStorage.readObject("settings", true, {finishedTutorial: false, sawNewPrisonCell: false, musicMuted: false});
		permaUpgrades = LocalStorage.readObject("perma_upgrades", true, {
			bonusShardsLvl: 0,
			bonusCoinsLvl: 0,
			coinsCarriedOverLvl: 0,
			personalModStation: false,
			higherTieredTraitsLvl: 0,
			increaseHealthLvl: 0,
		});
		collectibles = LocalStorage.readObject("collectibles", true, {
			coins: 0,
			shards: 0
		});
	}

	public function save() {
		var hero = game.hero;
		var heroData = {hasGun: hero.hasGun};
		LocalStorage.writeObject("hero", true, heroData);
		LocalStorage.writeObject("settings", true, settings);
		LocalStorage.writeObject("perma_upgrades", true, permaUpgrades);
		LocalStorage.writeObject("collectibles", true, collectibles);
	}

	public function clear() {
		LocalStorage.delete("hero");
		LocalStorage.delete("settings");
		LocalStorage.delete("perma_upgrades");
		LocalStorage.delete("collectibles");
	}
}
