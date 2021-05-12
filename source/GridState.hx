import actors.Weapon.WeaponAttackType;
import actors.Weapon.WeaponDef;

typedef GridStateTurn =
{
	turn_type:String,
	source_unit:Unit,
	target_unit:Unit,
	weapon:WeaponDef,
	move_x:Int,
	move_y:Int,
	path:Array<SearchNode>
}

typedef SearchNode =
{
	uid:Int,
	x:Int,
	y:Int,
	value:Int,
	path:Array<SearchNode>,
	visited:Bool,
	distance:Int,
	unit:UnitData,
	weapon:WeaponDef,
	attacking_from:SearchNode
}

typedef UnitData =
{
	uid:Int,
	x:Int,
	y:Int,
	team:Int,
	speed:Int,
	movement_left:Int,
	health:Float,
	weapons:Array<WeaponDef>,
	moved_already:Bool
}

class GridState
{
	public var turns:Array<GridStateTurn> = [];

	var turn_index:Int = 0;
	var score:Int = 0;
	var ready_for_next_turn:Bool = false;
	var realizing_state:Bool = false;

	public var grid:GridArray;
	public var active_team:Int = 1;
	public var max_team:Int = 1;

	var total_turns:Int = 0;

	public function new()
	{
		grid = new GridArray(PlayState.self.level.col.getData(true), unit_data_from_group(PlayState.self.units));
	}

	public function update()
	{
		if (realizing_state)
			realize_state();
	}

	function realize_state()
	{
		if (turns.length > 0)
		{
			var turn:GridStateTurn = turns[0];
			switch (turn.turn_type)
			{
				case "move":
					turn.source_unit.realize_move(this, turn);
					if (!turn.source_unit.REALIZING)
						turns.shift();
				case "attack":
					turn.source_unit.realize_attack(this, turn.target_unit, turn.weapon);
					if (!turn.source_unit.REALIZING)
						turns.shift();
			}
		}
		if (turns.length <= 0)
			PlayState.self.regenerate_grid();
	}

	public function add_move_turn(unit:Unit, node:SearchNode, realize_state_set:Bool = true)
	{
		var turn:GridStateTurn = empty_turn();
		turn.source_unit = unit;
		turn.turn_type = "move";
		turn.path = node.path.concat([node]);

		turns.push(turn);

		realizing_state = realizing_state || realize_state_set;
	}

	public function add_attack_turn(source_unit:Unit, target_unit:Unit, weapon:WeaponDef, realize_state_set:Bool = true)
	{
		var turn:GridStateTurn = empty_turn();
		turn.source_unit = source_unit;
		turn.target_unit = target_unit;
		turn.turn_type = "attack";

		turns.push(turn);

		realizing_state = realizing_state || realize_state_set;
	}

	function empty_turn():GridStateTurn
	{
		return {
			turn_type: "",
			source_unit: null,
			target_unit: null,
			move_x: -1,
			move_y: -1,
			weapon: null,
			path: []
		};
	}

	function unit_data_from_group(units:FlxTypedGroup<Unit>):Array<UnitData>
	{
		var data_array:Array<UnitData> = [];
		for (u in units)
			data_array.push(u.get_unit_data());
		return data_array;
	}

	public function attack(source_unit:UnitData, attack_unit:UnitData, weapon:WeaponDef)
	{
		source_unit = find_unit_data_in_units(source_unit);
		attack_unit = find_unit_data_in_units(attack_unit);
		attack_unit.health -= weapon.str;

		var HORZ:Bool = source_unit.x < attack_unit.x || source_unit.x > attack_unit.x;
		var VERT:Bool = source_unit.y < attack_unit.y || source_unit.y > attack_unit.y;

		var kb_x:Int = 0;
		var kb_y:Int = 0;

		if (HORZ)
			kb_x = source_unit.x < attack_unit.x ? -weapon.knockback : weapon.knockback;
		if (VERT)
			kb_y = source_unit.y < attack_unit.y ? -weapon.knockback : weapon.knockback;

		var attack_node:SearchNode = grid.getNode(attack_unit.x, attack_unit.y);
		var kb_line:Array<SearchNode> = grid.draw_line_with_collision(attack_node, 3, kb_x, kb_y);

		if (kb_line.length > 0)
		{
			attack_node.x = kb_line[kb_line.length - 1].x;
			attack_node.y = kb_line[kb_line.length - 1].y;
		}

		write_state_to_game();
	}

	public function find_unit_data_in_units(unit:UnitData):UnitData
	{
		for (u in grid.units)
			if (u.uid == unit.uid)
				return u;
		return null;
	}

	public function find_unit_actual_in_units(unit:UnitData):Unit
	{
		for (u in PlayState.self.units)
			if (u.uid == unit.uid)
				return u;
		return null;
	}

	function write_state_to_game()
	{
		for (unit_data in grid.units)
			for (unit in PlayState.self.units)
				if (unit_data.uid == unit.uid)
					unit.write_from_unit_data(unit_data);
	}
}

class GridArray
{
	public var array:Array<Int> = [];
	public var units:Array<UnitData> = [];
	public var nodes:Array<SearchNode> = [];

	public var width_in_tiles:Int = 0;
	public var height_in_tiles:Int = 0;

	public var collisions:Array<Int> = [1];

	public var movement_options:Map<Int, Array<SearchNode>> = new Map<Int, Array<SearchNode>>();
	public var attack_options:Map<Int, Array<SearchNode>> = new Map<Int, Array<SearchNode>>();

	public function new(ArrayCopy:Array<Int>, units_array:Array<UnitData>)
	{
		array = ArrayCopy;
		units = units_array;

		width_in_tiles = PlayState.self.level.widthInTiles;
		height_in_tiles = PlayState.self.level.heightInTiles;

		for (i in 0...array.length)
		{
			nodes.push(new_node(i % width_in_tiles, Math.floor(i / width_in_tiles), array[i]));
			nodes[i].unit = getTileUnit(nodes[i].x, nodes[i].y);
		}
	}

	/**
	 * Gets the tile from a 1D array
	 * @param X tile X to search
	 * @param Y tile Y to search
	 * @return collision value of the tile to search
	 */
	public function getTile(X:Int, Y:Int):Int
	{
		if (X < 0 || X >= width_in_tiles || Y < 0 || Y >= height_in_tiles)
			return -1;
		return array[Y * width_in_tiles + X];
	}

	/**
	 * Gets the node from a 1D array
	 * @param X tile X to search
	 * @param Y tile Y to search
	 * @return The Node
	 */
	public function getNode(X:Int, Y:Int):SearchNode
	{
		if (X < 0 || X >= width_in_tiles || Y < 0 || Y >= height_in_tiles)
			return null;
		return nodes[Y * width_in_tiles + X];
	}

	/**
	 * Gets the team of the unit on the tile
	 * @param X tile X to search
	 * @param Y tile Y to search
	 * @return team of the unit on that tile, 0 for nothing
	 */
	public function getTileTeam(X:Int, Y:Int):Int
	{
		for (u in units)
			if (u.x == X && u.y == Y)
				return u.team;
		return 0;
	}

	/**
	 * Gets the team of the unit on the tile
	 * @param X tile X to search
	 * @param Y tile Y to search
	 * @return unit on that tile
	 */
	public function getTileUnit(X:Int, Y:Int):UnitData
	{
		for (u in units)
			if (u.x == X && u.y == Y)
				return u;
		return null;
	}

	/**
	 * Creates a new SeerchNode with the params
	 * @param x x position
	 * @param y y position
	 * @return Mostly blank SearchNode
	 */
	public function new_node(x:Int, y:Int, value:Int = 0, ?unit:UnitData, ?weapon:WeaponDef):SearchNode
	{
		return {
			uid: x * width_in_tiles + y,
			x: x,
			y: y,
			value: 0,
			visited: false,
			path: [],
			distance: 0,
			unit: unit,
			weapon: weapon,
			attacking_from: null,
		};
	}

	/**
	 * Breadth first search, repurposed to get available movement positions
	 * @param state 
	 * @param start 
	 * @param goal 
	 * @return Array<FlxPoint>
	 */
	public function bfs_movement_options(start:FlxPoint, goal:FlxPoint, unit:UnitData, speed:Int):Array<SearchNode>
	{
		var start_node:SearchNode = getNode(Math.floor(start.x), Math.floor(start.y));
		var open_set:Array<SearchNode> = [start_node];
		var visited:Array<SearchNode> = [];
		var current:SearchNode;

		movement_options.set(unit.uid, []);
		attack_options.set(unit.uid, []);

		for (n in nodes)
		{
			n.visited = false;
			n.distance = 0;
			n.path = [];
		}

		while (open_set.length > 0)
		{
			current = open_set.shift();
			current.visited = true;
			visited.push(current);
			if (current.distance < speed)
				for (neighbor in get_neighbors(current, unit))
					if (!neighbor.visited)
					{
						neighbor.path = current.path.concat([current]);
						neighbor.distance = neighbor.path.length;

						trace(neighbor.path.length);
						var cur_atk_opts:Array<SearchNode> = attack_options.get(unit.uid);
						var new_atk_opts:Array<SearchNode> = calculate_immediate_attack_options(unit, neighbor, unit.moved_already);

						cur_atk_opts = combine_node_arrays(cur_atk_opts, new_atk_opts);

						attack_options.set(unit.uid, cur_atk_opts);

						trace(attack_options.get(unit.uid).length, "post");

						/*
							trace(current.unit);
							if (neighbor.unit != null)
								trace('!!!!!!!!!!!!!!!UNIT IS HERE!!!!!!!!!!!!!!!');
						 */
						set_add(open_set, neighbor);
					}
		}

		var response_array:Array<SearchNode> = [];

		for (v in visited)
		{
			var VALID_VISITED:Bool = true;
			for (u in units)
				if (u.x == v.x && u.y == v.y)
					VALID_VISITED = false;
			if (VALID_VISITED)
				response_array.push(v);
		}

		movement_options.set(unit.uid, response_array);

		return response_array;
	}

	/**
	 * Adds to an array if it doesn't already exist
	 * @param set array to add to
	 * @param node thing to add
	 * @return Array<T> set with/without plus
	 */
	function set_add<T>(set:Array<T>, node:T):Array<T>
	{
		var ALREADY_IN_SET:Bool = false;
		for (s in set)
			if (s == node)
				ALREADY_IN_SET = true;
		if (!ALREADY_IN_SET)
			set.push(node);
		return set;
	}

	public function calculate_all_attack_options(unit:UnitData, movement_range:Array<SearchNode>, moved_already:Bool):Array<SearchNode>
	{
		var attack_options:Array<SearchNode> = [];

		for (node in movement_range)
			node.visited = false;

		for (node in movement_range)
			attack_options = attack_options.concat(calculate_immediate_attack_options(unit, node, moved_already));

		return attack_options;
	}

	public function calculate_immediate_attack_options(unit:UnitData, node:SearchNode, moved_already:Bool = false):Array<SearchNode>
	{
		var attack_options:Array<SearchNode> = [];

		for (weapon in unit.weapons)
			// can't use artillery weapons if you've already moved
			if (!(moved_already && weapon.attack_type == WeaponAttackType.ARTILLERY))
				for (col in -weapon.range...weapon.range)
					for (row in -weapon.range...weapon.range)
					{
						var enemy_unit:UnitData = getTileUnit(node.x + col, node.y + row);
						if (enemy_unit != null && enemy_unit.team != unit.team)
						{
							var attack_node:SearchNode = new_node(node.x + col, node.y + row, enemy_unit, weapon);
							attack_node.attacking_from = node;
							attack_node.path = node.path.copy();

							/*
								trace('///\nsource node path (${node.x}, ${node.y}) length: ${node.path.length}'
									+ '\nattack node path (${attack_node.x}, ${attack_node.y}) length: ${attack_node.path.length}\n///');
							 */

							attack_options.push(attack_node);
						}
					}
		return attack_options;
	}

	/**
	 * Manhatten heuristic i.e. distance two points
	 * @param start node to start at
	 * @param node node to end at (usually the "current" node)
	 * @return Float heuristic value i.e. distance two points
	 */
	function manhatten_heuristic(start:SearchNode, end:SearchNode):Float
	{
		var XX:Float = end.x - start.x;
		var YY:Float = end.y - start.y;
		return Math.sqrt(XX * XX + YY * YY);
	}

	/**
	 * Gets neighbors in four cardinal directions that aren't colliding
	 * @param current node to get the neighbors of
	 * @param team team of the node to act as collision tiles if they don't match
	 * @return Array<SearchNode> valid neighbors
	 */
	function get_neighbors(current:SearchNode, unit:UnitData):Array<SearchNode>
	{
		var neighbors:Array<SearchNode> = [];

		for (i in 0...4)
		{
			var neighbor_x:Int = current.x;
			var neighbor_y:Int = current.y;
			switch (i)
			{
				case 0:
					neighbor_x += -1;
				case 1:
					neighbor_x += 1;
				case 2:
					neighbor_y += -1;
				case 3:
					neighbor_y += 1;
			}

			var node:SearchNode = getNode(neighbor_x, neighbor_y);

			if (attack_options.get(unit.uid) == null)
				attack_options.get(unit.uid);

			// trace('${node.x} ${node.y} ${node.unit}');
			if (node != null)
			{
				var VALID_TEAM:Bool = node.unit == null || node.unit.team == unit.team || node.unit.team == 0;

				if (node.value >= 0 && collisions.indexOf(node.value) <= -1 && VALID_TEAM)
					neighbors.push(node);
			}
		}

		return neighbors;
	}

	function get_collision(node:SearchNode)
	{
		if (collisions.indexOf(node.value) > -1)
			return false;
		return true;
	}

	public function draw_line_with_collision(start:SearchNode, distance:Int, vel_x:Int, vel_y:Int):Array<SearchNode>
	{
		var current:SearchNode = start;
		var path:Array<SearchNode> = [];
		for (i in 0...distance)
		{
			current = getNode(current.x + vel_x, current.y + vel_y);
			if (current.unit != null || get_collision(current))
				return path;
			path.push(current);
		}
		return path;
	}

	function combine_node_arrays(array_1:Array<SearchNode>, array_2:Array<SearchNode>):Array<SearchNode>
	{
		for (node2 in array_2)
		{
			var NODE_ALREADY_IN_ARRAY:Bool = false;
			var NODE_PATH_BETTER:Bool = false;
			for (node1 in array_1)
			{
				if (node1.uid == node2.uid)
				{
					NODE_ALREADY_IN_ARRAY = true;
					trace(node2.path.length, node1.path.length);
					if (node2.path.length < node1.path.length)
					{
						trace("NODE PATH BETTER");
						NODE_PATH_BETTER = true;
						array_1.remove(node1);
					}
					break;
				}
			}
			if (!NODE_ALREADY_IN_ARRAY)
				array_1.push(node2);
		}
		return array_1;
	}
}
