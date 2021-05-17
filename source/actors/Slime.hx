package actors;

class Slime extends Unit
{
	public function new(?X:Float = 0, ?Y:Float = 0)
	{
		super(X, Y);

		team = 2;
		speed = 3;
		movement_left = speed;

		trace("NEW SLIME");

		name = "slime";

		trace(tile_position.x, tile_position.y);

		loadAllFromAnimationSet("slime");
	}

	override function update(elapsed:Float)
	{
		snap_to_grid();

		if (!REALIZING)
			SELECTED ? anim("move") : anim("idle");

		super.update(elapsed);
	}
}
