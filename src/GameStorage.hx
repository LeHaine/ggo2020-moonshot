import dn.LocalStorage;

typedef HeroData = {
	var hasGun:Bool;
}

typedef Settings = {
	var finishedTutorial:Bool;
}

class GameStorage {
	public var game(get, never):Game;

	inline function get_game()
		return Game.ME;

	public var heroData:HeroData;
	public var settings:Settings;

	public function new() {}

	public function loadSavedData() {
		heroData = LocalStorage.readObject("hero", true, {hasGun: false});
		settings = LocalStorage.readObject("settings", true, {finishedTutorial: false});
	}

	public function save() {
		var hero = game.hero;
		var heroData = {hasGun: hero.hasGun};
		LocalStorage.writeObject("hero", true, heroData);
		LocalStorage.writeObject("settings", true, settings);
	}

	public function clear() {
		LocalStorage.delete("hero");
		LocalStorage.delete("settings");
	}
}
