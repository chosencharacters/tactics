package;

import states.PlayState;

class TurnManager
{
	var players:Array<PlayerHandler> = [];

	public var current_team:Int = 0;
	public var rounds:Int = 0;

	public function new() {}

	public function update()
	{
		players[current_team].update();
	}

	public function set_player(player_id:Int, player_handler:PlayerHandler)
	{
		players[player_id] = player_handler;
	}

	function new_turn()
	{
		trace("oooo");

		for (unit in PlayState.self.units)
		{
			unit.color = FlxColor.WHITE;
			if (unit.team == current_team)
				unit.new_turn();
		}

		PlayState.self.current_state = new GridState();
	}

	public function end_turn()
	{
		current_team++;
		if (current_team >= players.length)
		{
			current_team = 1;
			rounds++;
		}
		new_turn();
	}
}
