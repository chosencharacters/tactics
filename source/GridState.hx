typedef GridStateTurn =
{
	turn_type:String,
	unit:Unit,
	move_x:Int,
	move_y:Int
}

typedef SearchNode =
{
	visited:Bool,
	distance:Int,
	x:Int,
	y:Int
}

typedef UnitData =
{
	x:Int,
	y:Int,
	team:Int,
	speed:Int,
	u_id:Int
}

class GridState
{
	public var turns:Array<GridStateTurn> = [];

	var turn_index:Int = 0;
	var score:Int = 0;

	var ready_for_next_turn:Bool = false;
	var realizing_state:Bool = false;

	public var grid:GridArray;

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
		for (turn in turns)
		{
			switch (turn.turn_type)
			{
				case "move":
					turn.unit.realize_move(this, FlxPoint.weak(turn.move_x, turn.move_y));
			}
		}
		if (turns.length <= 0)
			PlayState.self.regenerate_grid();
	}

	public function add_move_turn(unit:Unit, move_x:Float, move_y:Float, realize_state_set:Bool = true)
	{
		var turn:GridStateTurn = empty_turn();
		turn.unit = unit;
		turn.move_x = Math.floor(move_x);
		turn.move_y = Math.floor(move_y);
		turn.turn_type = "move";

		turns.push(turn);

		realizing_state = realizing_state || realize_state_set;
	}

	function empty_turn():GridStateTurn
	{
		return {
			turn_type: "",
			unit: null,
			move_x: -1,
			move_y: -1
		};
	}

	function unit_data_from_group(units:FlxTypedGroup<Unit>):Array<UnitData>
	{
		var data_array:Array<UnitData> = [];
		for (u in units)
			data_array.push(u.get_unit_data());
		return data_array;
	}
}

class GridArray
{
	public var array:Array<Int> = [];
	public var units:Array<UnitData> = [];

	public var width_in_tiles:Int = 0;
	public var height_in_tiles:Int = 0;

	public function new(ArrayCopy:Array<Int>, units_array:Array<UnitData>)
	{
		array = ArrayCopy;
		units = units_array;

		width_in_tiles = PlayState.self.level.widthInTiles;
		height_in_tiles = PlayState.self.level.heightInTiles;
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
	 * Creates a new SeerchNode with the params
	 * @param x x position
	 * @param y y position
	 * @return Mostly blank SearchNode
	 */
	public function new_node(x:Int, y:Int):SearchNode
	{
		return {
			visited: false,
			distance: 0,
			x: x,
			y: y
		};
	}

	/**
	 * Breadth first search, repurposed to get available movement positions
	 * @param state 
	 * @param start 
	 * @param goal 
	 * @return Array<FlxPoint>
	 */
	public function bfs_movement_options(start:FlxPoint, goal:FlxPoint, unit:UnitData):Array<SearchNode>
	{
		var open_set:Array<SearchNode> = [new_node(Math.floor(start.x), Math.floor(start.y))];
		var visited:Array<SearchNode> = [];
		var current:SearchNode;
		var collisions:Array<Int> = [1];

		while (open_set.length > 0)
		{
			current = open_set.pop();
			visited.push(current);
			for (neighbor in get_neighbors(current, unit.team, collisions))
				if (!Utils.set_contains_node(visited, neighbor) && neighbor.distance <= unit.speed)
					open_set.push(neighbor);
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
	 * Manhatten heuristic i.e. distance two points
	 * @param start node to start at
	 * @param node node to end at (usually the "current" node)
	 * @return Float heuristic value i.e. distance two points
	 */
	function manhatten_heuristic(start:FlxPoint, end:FlxPoint):Float
	{
		return Utils.getDistance(start, end);
	}

	/**
	 * Gets neighbors in four cardinal directions that aren't colliding
	 * @param current node to get the neighbors of
	 * @param team team of the node to act as collision tiles if they don't match
	 * @return Array<SearchNode> valid neighbors
	 */
	function get_neighbors(current:SearchNode, team:Int, collisions:Array<Int>):Array<SearchNode>
	{
		var neighbors:Array<SearchNode> = [];

		for (i in 0...4)
		{
			var new_neighbor:SearchNode = new_node(current.x, current.y);
			switch (i)
			{
				case 0:
					new_neighbor.x += -1;
				case 1:
					new_neighbor.x += 1;
				case 2:
					new_neighbor.y += -1;
				case 3:
					new_neighbor.y += 1;
			}

			new_neighbor.distance = current.distance + 1;

			var tile:Int = getTile(Math.floor(new_neighbor.x), Math.floor(new_neighbor.y));
			var tile_team:Int = getTileTeam(new_neighbor.x, new_neighbor.y);

			var VALID_TEAM:Bool = tile_team == team || tile_team == 0;

			if (tile >= 0 && collisions.indexOf(tile) <= -1 && VALID_TEAM)
			{
				neighbors.push(new_neighbor);
			}
		}

		return neighbors;
	}
}
