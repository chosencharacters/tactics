package actors;

import flixel.math.FlxRandom;

class Slime extends Unit
{
	public function new(?X:Float = 0, ?Y:Float = 0)
	{
		super(X, Y);

		team = 2;
		speed = 3;
		max_health = 25;

		name = "slime";

		loadAllFromAnimationSet("slime");

		init();
	}

	override function update(elapsed:Float)
	{
		snap_to_grid();

		if (!REALIZING)
			SELECTED ? anim("move") : anim("idle");

		super.update(elapsed);
	}
}
