package;

import flixel.FlxGame;
import openfl.display.Sprite;

class Main extends Sprite
{
	static var WIDTH:Int = 640;
	static var HEIGHT:Int = 360;
	static var FPS:Int = 60;

	public static var REVERSE_MENU_CONTROLS:Bool = false;
	public static var DISABLE_SCREENSHAKE:Bool = false;

	public static var DEBUG_PATH:Bool = false;

	public function new()
	{
		super();

		Lists.init();
		Ctrl.set();

		addChild(new FlxGame(WIDTH, HEIGHT, PlayState, 1, FPS, FPS, true));
	}
}
