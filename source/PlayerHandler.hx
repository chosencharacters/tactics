package;

import states.PlayState;

class PlayerHandler
{
	public var units:Array<Unit> = [];
	public var team:Int = 0;

	public function new(Team:Int)
	{
		team = Team;
		update_my_units();
	}

	public function update()
	{
		update_my_units();
	}

	function update_my_units()
	{
		units = [];
		for (unit in PlayState.self.units)
			if (unit.team == team && unit.alive)
				units.push(unit);
	}
}
