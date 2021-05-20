package ui;

import GridState.GridArray;

/**
 * Displays a path from one tile to the next
 */
class PathHighlight extends FlxSpriteExt
{
	var draw_path:Array<Int>;

	var brush:FlxSpriteExt;

	var fade_timer:Int = 0;

	/** Transparency of the path */
	var ALPHA_SET:Float = 0.75;

	/**The speed the path fades out after the movement is done*/
	var FADE_TIMER_SET:Int = 10;

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
			alpha = (fade_timer / FADE_TIMER_SET) * ALPHA_SET;
		fade_timer--;
		super.update(elapsed);
	}

	/**
	 * Updates the path
	 * @param Path highlightable path
	 */
	public function update_path(?PathNodes:Array<SearchNode>, ?PathInt:Array<Int>, ?AttackMode:Bool = false)
	{
		draw_path = [];

		if (PathInt != null)
			draw_path = PathInt;
		if (PathNodes != null)
			for (node in PathNodes)
				draw_path.push(node.uid);

		fade_timer = FADE_TIMER_SET;
		alpha = ALPHA_SET;
		clear_all();
		highlight_squares(AttackMode);
	}

	/**
	 * highlights squares
	 */
	function highlight_squares(AttackMode:Bool)
	{
		if (draw_path == null || draw_path.length <= 0)
			return;

		var grid:GridArray = PlayState.self.current_state.grid;

		var path:Array<Int> = draw_path.copy();

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
