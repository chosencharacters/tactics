import GridState.GridArray;

class BasicAI extends ComputerPlayerHandler
{
	var activated:Bool = false;

	public function new(Team:Int)
	{
		super(Team);
	}

	override function update()
	{
		dumb_ai();
		super.update();
	}

	public function dumb_ai()
	{
		var current_state:GridState = PlayState.self.current_state;

		if (current_state.realizing_state)
			return;
		for (unit in current_state.grid.units)
		{
			if (unit.team == team && unit.movement_left > 0 && unit.alive)
			{
				var states:Array<GridState> = [];

				states = states.concat(simulate_all_turns(current_state, unit));

				for (state in states)
					state = evaluate_state(state.grid.units.get(unit.uid), state);

				var best_state:GridState = get_best_state(states);
				PlayState.self.current_state.clone_turns(best_state.turns);
				PlayState.self.current_state.realize_state(true);

				dumb_ai();
				return;
			}
		}
	}

	function simulate_all_turns(state:GridState, unit:UnitData):Array<GridState>
	{
		var unit_actual:Unit = state.find_unit_actual_in_units(unit);
		var states:Array<GridState> = new Array<GridState>();

		var move_options:Array<SearchNode> = state.grid.bfs_movement_options(FlxPoint.weak(unit.x, unit.y), unit);
		var attack_options:Array<SearchNode> = state.grid.attack_options.get(unit.uid);

		for (node in move_options)
		{
			var new_state:GridState = new GridState(state.grid.array, state.grid.units_array());
			var unitS:UnitData = new_state.grid.units.get(unit.uid);

			new_state.add_move_turn(unitS, node, false);
			new_state.soft_transition_state();
			states.push(new_state);
		}
		for (node in attack_options)
		{
			var new_state:GridState = new GridState(state.grid.array, state.grid.units_array());
			var path_nodes:Array<SearchNode> = PlayState.self.current_state.grid.get_path_as_nodes(node.path);
			var unitS:UnitData = new_state.grid.units.get(unit.uid);

			if (path_nodes.length == 0)
				path_nodes = [node];

			if (path_nodes.length > 1)
				new_state.add_move_turn(unitS, path_nodes[path_nodes.length - 1], false);
			new_state.add_attack_turn(unitS, node.unit, node.weapon, false, path_nodes[path_nodes.length - 1]);

			new_state.soft_transition_state();

			states.push(new_state);
		}

		return states;
	}

	function evaluate_state(unit1:UnitData, state:GridState):GridState
	{
		var total_health:Float = 0;
		var total_distances:Float = 0;

		for (unit2 in state.grid.units)
		{
			if (unit2.team != unit1.team && unit2.alive)
			{
				var node1:SearchNode = state.grid.getNode(unit1.x, unit1.y);
				var node2:SearchNode = state.grid.getNode(unit2.x, unit2.y);

				total_distances += Math.ceil(state.grid.manhatten_heuristic(node1, node2));
				total_health += unit2.health;
				// trace(unit2.name, unit2.health * 2);
			}
		}
		state.score = -(total_distances + total_health);
		/*trace(unit1.x, unit1.y, 'scores tot ${state.score} = -health ${total_health} + -distances ${total_distances}', "turns", state.turns.length,
			state.grid.attack_options.get(unit1.uid)); */
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
