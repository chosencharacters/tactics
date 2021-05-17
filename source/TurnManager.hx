package;

import states.PlayState;

class TurnManager
{
	var players:Array<PlayerHandler> = [];

	public var current_turn:Int = 1;
	public var rounds:Int = 0;

	public function new() {}

	public function update()
	{
		players[current_turn].update();
	}

	function set_player(player_id:Int, player_handler:PlayerHandler) {}

	function new_turn()
	{
		for (unit in PlayState.self.units)
			unit.new_turn();

		PlayState.self.current_state = new GridState();
	}

	function end_turn()
	{
		current_turn++;
		if (players.length >= current_turn)
		{
			current_turn = 1;
			rounds++;
		}
	}
}
