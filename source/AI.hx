import GridState.GridArray;

class AI
{
	var team:Int = 0;
	var activated:Bool = false;

	public function new(Team:Int)
	{
		team = Team;
	}

	public function dumb_ai()
	{
		if (activated)
			return;
		activated = true;

		var current_state:GridState = PlayState.self.current_grid_state;
		var states:Array<GridState> = [];

		for (unit in current_state.grid.units)
			if (unit.team == team)
				states = states.concat(simulate_all_turns(current_state, unit));

		for (state in states)
			state = evaluate_state(state);

		trace(states.length);
		var best_state:GridState = get_best_state(states);
		best_state.realize_state(true);
		PlayState.self.current_grid_state = best_state;
		// best_state.write_state_to_game();

		trace(best_state.turns[0]);
	}

	function simulate_all_turns(state:GridState, unit:UnitData):Array<GridState>
	{
		var unit_actual:Unit = state.find_unit_actual_in_units(unit);
		var states:Array<GridState> = new Array<GridState>();

		var move_options:Array<SearchNode> = state.grid.bfs_movement_options(FlxPoint.weak(unit.x, unit.y), unit);

		for (move_node in move_options)
		{
			var new_state:GridState = new GridState(state.grid.array, state.grid.units_array());

			new_state.add_move_turn(unit, move_node, false);
			new_state.soft_transition_state();
			states.push(new_state);
		}

		return states;
	}

	function evaluate_state(state:GridState):GridState
	{
		for (unit1 in state.grid.units)
		{
			for (unit2 in state.grid.units)
			{
				var node1:SearchNode = state.grid.getNode(unit1.x, unit1.y);
				var node2:SearchNode = state.grid.getNode(unit2.x, unit2.y);
				if (unit1.team != unit2.team)
					state.score -= Math.ceil(state.grid.manhatten_heuristic(node1, node2)) + node2.path.length;
			}
		}
		return state;
	}

	function get_best_state(states:Array<GridState>)
	{
		var best_state:GridState = states[0];
		for (state in states)
			if (state.score > best_state.score)
				best_state = state;
		return best_state;
	}

	function one_unit_ai(unit:UnitData) {}
}
