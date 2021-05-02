typedef GridStateTurn =
{
	turn_type:String,
	unit:Unit,
	move_x:Int,
	move_y:Int
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
		grid = new GridArray(PlayState.self.level.getData(true);
	}

	public function update()
	{
		if (realizing_state)
			realize_state();
	}

	function realize_state()
	{
		for (turn in turns) {}
	}

	function add_move_turn(unit:Unit, move_x:Float, move_y:Float)
	{
		var turn:GridStateTurn = empty_turn();
		turn.unit = unit;
		turn.move_x = Math.floor(move_x);
		turn.move_y = Math.floor(move_y);
		turn.turn_type = "move";

		turns.push(turn);
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
}

class GridArray
{
	var array:Array<Int> = [];
	var width_in_tiles:Int = 0;

	public function new(ArrayCopy:Array<Int>)
	{
		array = ArrayCopy;
		width_in_tiles = PlayState.self.level.widthInTiles;
	}

	public function getTile(X:Int, Y:Int)
	{
		return array[Y * width_in_tiles + X];
	}
}