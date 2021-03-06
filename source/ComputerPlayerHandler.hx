package;

class ComputerPlayerHandler extends PlayerHandler
{
	public function new(Team:Int)
	{
		super(Team);
	}

	override function update()
	{
		var TURN_END:Bool = true;
		for (unit in units)
			if (unit.movement_left > 0 && unit.alive)
				TURN_END = false;
		if (TURN_END)
			PlayState.self.turn_manager.end_turn();

		super.update();
	}
}
