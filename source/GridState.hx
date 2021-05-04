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
	u_id:Int,
	x:Int,
	y:Int,
	team:Int,
	speed:Int,
	movement_left:Int,
	health:Float,
	weapons:Array<WeaponDef>
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

	public function add_move_turn(unit:Unit, move_x:Float, move_y:Float, realize_state_set:Bool = true)
	{
		var turn:GridStateTurn = empty_turn();
		turn.source_unit = unit;
		turn.move_x = Math.floor(move_x);
		turn.move_y = Math.floor(move_y);
		turn.turn_type = "move";

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
			weapon: null
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
		source_unit = find_unit_in_units(source_unit);
		attack_unit = find_unit_in_units(attack_unit);
		attack_unit.health -= weapon.str;

		var HORZ:Bool = source_unit.x < attack_unit.x || source_unit.x > attack_unit.x;
		var VERT:Bool = source_unit.y < attack_unit.y || source_unit.y > attack_unit.y;

		if (HORZ)
			attack_unit.x = source_unit.x < attack_unit.x ? attack_unit.x - weapon.knockback : attack_unit.x + weapon.knockback;
		if (VERT)
			attack_unit.y = source_unit.y < attack_unit.y ? attack_unit.y - weapon.knockback : attack_unit.y + weapon.knockback;

		write_state_to_game();
	}

	function find_unit_in_units(unit:UnitData):UnitData
	{
		for (u in grid.units)
		{
			if (u.u_id == unit.u_id)
				return u;
		}
		return null;
	}

	function write_state_to_game()
	{
		for (unit_data in grid.units)
			for (unit in PlayState.self.units)
				if (unit_data.u_id == unit.u_id)
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
		{
			if (u.x == X && u.y == Y)
				return u.team;
		}
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
		{
			if (u.x == X && u.y == Y)
				return u;
		}
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

		for (n in nodes)
		{
			n.visited = false;
			n.distance = 0;
		}

		while (open_set.length > 0)
		{
			current = open_set.shift();
			current.visited = true;
			visited.push(current);
			for (neighbor in get_neighbors(current, unit.team))
				if (!neighbor.visited && neighbor.distance <= speed)
				{
					neighbor.path = current.path.concat([current]);
					neighbor.distance = neighbor.path.length;
					if (current.distance < speed)
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
		{
			attack_options = attack_options.concat(calculate_immediate_attack_options(unit, node, moved_already));
		}
		return attack_options;
	}

	public function calculate_immediate_attack_options(unit:UnitData, node:SearchNode, moved_already:Bool = false)
	{
		var attack_options:Array<SearchNode> = [];

		for (weapon in unit.weapons)
		{
			// can't use artillery weapons if you've already moved
			if (!(moved_already && weapon.attack_type == WeaponAttackType.ARTILLERY))
			{
				for (col in -weapon.range...weapon.range)
				{
					for (row in -weapon.range...weapon.range)
					{
						var enemy_unit:UnitData = getTileUnit(node.x + col, node.y + row);
						if (enemy_unit != null && enemy_unit.team != unit.team)
						{
							var attack_node:SearchNode = new_node(node.x + col, node.y + row, enemy_unit, weapon);
							attack_node.attacking_from = node;
							attack_options.push(attack_node);
						}
					}
				}
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
	function get_neighbors(current:SearchNode, team:Int):Array<SearchNode>
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
			if (node != null)
			{
				var VALID_TEAM:Bool = node.unit == null || node.unit.team == team || node.unit.team == 0;

				if (node.value >= 0 && collisions.indexOf(node.value) <= -1 && VALID_TEAM)
					neighbors.push(node);
			}
		}

		return neighbors;
	}
}
