package states;

import flixel.FlxState;
import flixel.text.FlxText;
import levels.Level;

class BaseState extends FlxState
{
	override public function create()
	{
		super.create();
	}

	override public function update(elapsed:Float)
	{
		Ctrl.update();
		super.update(elapsed);
	}
}
