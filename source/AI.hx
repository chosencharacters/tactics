{
	var team:Int = 0;

	public function new(Team:Int)
	{
		team = Team;
	}

	function minimax(position:GridState, depth:Int, maximizing_player:Int):Int
	{
		if (depth == 0 || position.game_over)
			return evaluate(position);

		if (position.turn_index == team)
		{
			var max_eval:Int = -999999999;
			for (pos)
		}

		return 0;
	}

	function evaluate(position:GridState):Int
	{
		return 0;
	}

	function get_successive_positions(state:GridState, check_team:Int)
	{
		var positions:Array<GridState> = [];
		for (unit in state.grid.units)
		{
			var moves:Array<GridStateTurn> = [];
			if (unit.team == check_team) {}
		}
	}
}
