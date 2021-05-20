package ui;

import GridState.GridArray;

/**
 * Displays a path from one tile to the next
 */
class PathArrow extends FlxSpriteExt
{
	var source:SearchNode;
	var target:SearchNode;

	var brush:FlxSpriteExt;

	override public function new()
	{
		super();

		var unit:Unit = PlayState.self.units.getFirstAlive();

		for (u in PlayState.self.units)
			if (u.get_unit_data().name == "Rodney")
				unit = u;

		select_unit(unit);

		brush = new FlxSpriteExt();
		brush.loadGraphic(AssetPaths.path_arrow__png, true, 32, 32);

		makeGraphic(Math.floor(PlayState.self.level.width), Math.floor(PlayState.self.level.height), FlxColor.TRANSPARENT);

		clear_arrow();
		create_arrow();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
	}

	function select_unit(unit:Unit)
	{
		var data:UnitData = unit.get_unit_data();

		PlayState.self.current_state.grid.bfs_movement_options(unit.tile_position, data);

		source = PlayState.self.current_state.grid.getNode(data.x, data.y);
		target = PlayState.self.current_state.grid.getNode(0, 0);
	}

	public function update_arrow(Source:SearchNode, Target:SearchNode)
	{
		source = Source;
		target = Target;
		clear_arrow();
		create_arrow();
	}

	function create_arrow()
	{
		var grid:GridArray = PlayState.self.current_state.grid;
		var path:Array<Int> = target.path.copy().splice(1, target.path.length - 1).concat([target.y * grid.width_in_tiles + target.x]);

		trace(target.y * grid.width_in_tiles + target.x);

		var WAS_UP:Bool = false;
		var WAS_DOWN:Bool = false;
		var WAS_LEFT:Bool = false;
		var WAS_RIGHT:Bool = false;

		trace(path, path.length);

		for (n in 0...path.length)
		{
			var node:SearchNode = grid.nodes[path[n]];
			var next_node:SearchNode = grid.nodes[path[n + 1]];

			var GOING_UP:Bool = next_node.y < node.y;
			var GOING_DOWN:Bool = next_node.y > node.y;
			var GOING_LEFT:Bool = next_node.x < node.x;
			var GOING_RIGHT:Bool = next_node.x > node.x;
			var CAP:Bool = n == path.length - 1;

			var arrow_dir:PathArrowDir = NONE;

			if (GOING_UP)
			{
				arrow_dir = UP;
				if (WAS_LEFT)
					arrow_dir = BOTTOM_LEFT;
				if (WAS_RIGHT)
					arrow_dir = BOTTOM_RIGHT;
				if (CAP)
					arrow_dir = END_UP;
			}

			if (GOING_DOWN)
			{
				arrow_dir = DOWN;
				if (WAS_LEFT)
					arrow_dir = TOP_LEFT;
				if (WAS_RIGHT)
					arrow_dir = TOP_RIGHT;
				if (CAP)
					arrow_dir = END_DOWN;
			}

			if (GOING_LEFT)
			{
				arrow_dir = LEFT;
				if (WAS_UP)
					arrow_dir = BOTTOM_LEFT;
				if (WAS_DOWN)
					arrow_dir = TOP_LEFT;
				if (CAP)
					arrow_dir = END_LEFT;
			}

			if (GOING_RIGHT)
			{
				arrow_dir = RIGHT;
				if (WAS_UP)
					arrow_dir = BOTTOM_RIGHT;
				if (WAS_DOWN)
					arrow_dir = TOP_RIGHT;
				if (CAP)
					arrow_dir = END_RIGHT;
			}

			trace("CURRENT " + node.x, node.y, "NEXT " + next_node.x, next_node.y, 'UP ${GOING_UP} ${WAS_UP}', 'DOWN ${GOING_DOWN} ${WAS_DOWN}',
				'LEFT ${GOING_LEFT} ${WAS_LEFT}', 'RIGHT ${GOING_RIGHT} ${WAS_RIGHT}', 'CURRENT ${arrow_dir}');

			WAS_UP = GOING_UP;
			WAS_DOWN = GOING_DOWN;
			WAS_LEFT = GOING_LEFT;
			WAS_RIGHT = GOING_RIGHT;

			brush.animation.frameIndex = cast(arrow_dir, Int);
			brush.setPosition(0);
			stamp(brush, node.x * PlayState.self.level.tile_size, node.y * PlayState.self.level.tile_size);

			if (CAP)
				break;
		}
	}

	function clear_arrow()
	{
		makeGraphic(Math.floor(PlayState.self.level.width), Math.floor(PlayState.self.level.height), FlxColor.TRANSPARENT, true);
	}
}

@:enum
abstract PathArrowDir(Int)
{
	var NONE = -1;
	var HORIZONTAL = 0;
	var VERTICAL = 1;
	var LEFT = 0;
	var RIGHT = 0;
	var UP = 1;
	var DOWN = 1;
	var TOP_RIGHT = 2;
	var TOP_LEFT = 3;
	var BOTTOM_RIGHT = 4;
	var BOTTOM_LEFT = 5;
	var END_UP = 6;
	var END_LEFT = 7;
	var END_DOWN = 8;
	var END_RIGHT = 9;
}
