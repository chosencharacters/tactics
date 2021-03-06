package actors;

class Girl extends Unit
{
	public function new(?X:Float = 0, ?Y:Float = 0)
	{
		super(X, Y);

		team = 1;
		speed = 4;
		name = "Alex";
		max_health = 35;

		loadAllFromAnimationSet("girl");
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
