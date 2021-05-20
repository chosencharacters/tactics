package ui;

import GridState.GridArray;

/**
 * Displays a path from one tile to the next
 */
class PathHighlight extends FlxSpriteExt
{
	var source:SearchNode;
	var target:SearchNode;

	var brush:FlxSpriteExt;

	var fade_timer:Int = 0;

	/**The speed the path fades out after the movement is done*/
	var FADE_TIMER_SET:Int = 5;

	override public function new()
	{
		super();

		brush = new FlxSpriteExt();
		brush.loadGraphic(AssetPaths.movable_tile__png, true, 32, 32);

		makeGraphic(Math.floor(PlayState.self.level.width), Math.floor(PlayState.self.level.height), FlxColor.TRANSPARENT);
	}

	override function update(elapsed:Float)
	{
		if (fade_timer == 0)
			clear_all();
		if (fade_timer != FADE_TIMER_SET && fade_timer > 0)
			alpha = fade_timer / FADE_TIMER_SET;
		fade_timer--;
		super.update(elapsed);
	}

	function select_test_unit(unit:Unit)
	{
		var data:UnitData = unit.get_unit_data();

		PlayState.self.current_state.grid.bfs_movement_options(unit.tile_position, data);

		source = PlayState.self.current_state.grid.getNode(data.x, data.y);
		target = PlayState.self.current_state.grid.getNode(0, 0);
	}

	/**
	 * Updates the path
	 * @param Source starting position
	 * @param Target ending position
	 */
	public function update_path(Source:SearchNode, Target:SearchNode, AttackMode:Bool = false)
	{
		source = Source;
		target = Target;

		fade_timer = FADE_TIMER_SET;
		alpha = 1;

		clear_all();
		highlight_squares(AttackMode);
	}

	/**
	 * highlights squares
	 */
	function highlight_squares(AttackMode:Bool)
	{
		if (target == null)
			return;

		var grid:GridArray = PlayState.self.current_state.grid;

		var path:Array<Int> = target.path.copy().concat([target.y * grid.width_in_tiles + target.x]);

		for (n in path)
		{
			var node:SearchNode = grid.nodes[n];
			brush.color = AttackMode && path.indexOf(n) == path.length - 1 ? FlxColor.RED : FlxColor.WHITE;
			stamp(brush, node.x * PlayState.self.level.tile_size, node.y * PlayState.self.level.tile_size);
		}
	}

	public function clear_all()
	{
		makeGraphic(Math.floor(PlayState.self.level.width), Math.floor(PlayState.self.level.height), FlxColor.TRANSPARENT, true);
	}
}
