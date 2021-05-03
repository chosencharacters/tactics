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
		grid = new GridArray(PlayState.self.level.col.getData(true));
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
	var height_in_tiles:Int = 0;

	public function new(ArrayCopy:Array<Int>)
	{
		array = ArrayCopy;
		width_in_tiles = PlayState.self.level.widthInTiles;
		height_in_tiles = PlayState.self.level.heightInTiles;

		var indexes:Array<Int> = [];

		/*
			for (i in 0...array.length)
			{
				if (array[i] == 1)
				{
					var square:FlxSpriteExt = new FlxSpriteExt();
					var point:FlxPoint = PlayState.self.level.getTileCoordsByIndex(i, false);
					square.setPosition(point.x, point.y);
					square.makeGraphic(32, 32, FlxColor.RED);
					square.alpha = 0.25;

					indexes.push(i);

					PlayState.self.add(square);
				}
			}
		 */

		trace(indexes);
	}

	public function getTile(X:Int, Y:Int)
	{
		if (X < 0 || X > width_in_tiles || Y < 0 || Y > height_in_tiles)
			return -1;
		return array[Y * width_in_tiles + X];
	}
}
