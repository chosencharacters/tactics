package actors;

import flixel.tile.FlxBaseTilemap.FlxTilemapDiagonalPolicy;

class Unit extends Actor
{
	public var SELECTED:Bool = false;

	var speed:Int = 0;

	var movement_options:Array<FlxPoint> = new Array<FlxPoint>();

	public function new(?X:Float = 0, ?Y:Float = 0)
	{
		super(X, Y);

		PlayState.self.units.add(this);
	}

	override function update(elapsed:Float)
	{
		select_position();
		super.update(elapsed);
	}

	function snap_to_grid()
	{
		var cords:FlxPoint = FlxPoint.weak(tile_position.x * level.tile_size, tile_position.y * level.tile_size);
		cords.x += PlayState.self.level.tile_size / 2 - width / 2;
		cords.y += PlayState.self.level.tile_size - height;
		setPosition(cords.x, cords.y);
	}

	public function select()
	{
		SELECTED = true;
		get_movement_options();
	}

	function get_movement_options()
	{
		var start:Float = Sys.time();

		movement_options = [];

		var unit_world_pos:FlxPoint = new FlxPoint(tile_position.x * level.tile_size + level.x, tile_position.y * level.tile_size + level.y);

		var mod_speed:Int = speed + 1;
		for (row in -mod_speed...mod_speed)
		{
			for (col in -mod_speed...mod_speed)
			{
				var pos:FlxPoint = new FlxPoint(tile_position.x + row, tile_position.y + col);
				var goal_world_pos:FlxPoint = FlxPoint.weak(pos.x * level.tile_size + level.x, pos.y * level.tile_size + level.y);

				var VALID_POSITION:Bool = pos.x >= 0 && pos.y >= 0 && !(tile_position.x == pos.x && tile_position.y == pos.y);

				if (VALID_POSITION)
				{
					var start_index:Int = level.getTileIndexByCoords(unit_world_pos);
					var end_index:Int = level.getTileIndexByCoords(goal_world_pos);
					var sqrt_distance:Float = Utils.getDistance(level.getTileCoordsByIndex(start_index), level.getTileCoordsByIndex(end_index));

					var path:Array<FlxPoint> = level.findPath(unit_world_pos, goal_world_pos, false);

					if (path != null && path.length <= speed && sqrt_distance <= (speed) * level.tile_size)
					{
						movement_options.push(pos);
					}
				}
			}
		}

		PlayState.self.select_squares.select_squares(movement_options);

		trace("TIME: " + (Sys.time() - start));

		return movement_options;
	}

	function teleport(X:Float, Y:Float)
	{
		tile_position.x = Math.floor(X);
		tile_position.y = Math.floor(Y);
	}

	public function select_position()
	{
		var SELECT_INPUT:Bool = Ctrl.cursor_select;
		var CURSOR_POSITION:FlxPoint = PlayState.self.cursor.tile_position;
		var selected_pos:FlxPoint;

		if (!SELECT_INPUT || !SELECTED)
			return;

		for (pos in movement_options)
		{
			var CURSOR_MATCH:Bool = CURSOR_POSITION.x == pos.x && CURSOR_POSITION.y == pos.y;
			var SELF_MATCH:Bool = CURSOR_POSITION.x == tile_position.x && CURSOR_POSITION.y == tile_position.y;
			if (CURSOR_MATCH && !SELF_MATCH)
			{
				teleport(CURSOR_POSITION.x, CURSOR_POSITION.y);
				SELECTED = false;
				Ctrl.cursor_select = false;
				PlayState.self.select_squares.select_squares([]);
				return;
			}
		}
	}
}
