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
	var turns:Array<GridStateTurn> = [];
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
					turn.unit.realize_move(FlxPoint.weak(turn.move_x, turn.move_y));
			}
		}
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

	public function getTile(X:Int, Y:Int)
	{
		if (X < 0 || X >= width_in_tiles || Y < 0 || Y >= height_in_tiles)
			return -1;
		return array[Y * width_in_tiles + X];
	}

	public function getTileTeam(X:Int, Y:Int)
	{
		for (u in units)
		{
			if (u.x == X && u.y == Y)
				return u.team;
		}
		return 0;
	}

	public function new_node(x:Int, y:Int):SearchNode
	{
		return {
			visited: false,
			distance: 0,
			x: x,
			y: y
		};
	}
}
