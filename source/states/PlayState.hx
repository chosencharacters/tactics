package states;

import flixel.FlxState;
import flixel.text.FlxText;
import levels.Level;
import ui.Cursor;
import ui.SelectSquares;

class PlayState extends BaseState
{
	public static var self:PlayState;

	public var level:Level;

	public var units:FlxTypedGroup<Unit>;

	public var cursor:Cursor;
	public var select_squares:SelectSquares;

	public var current_grid_state:GridState;

	override public function create()
	{
		super.create();

		self = this;

		units = new FlxTypedGroup<Unit>();

		create_level();

		add(select_squares = new SelectSquares());
		add(units);
		add(cursor = new Cursor());

		current_grid_state = new GridState();
	}

	function create_level()
	{
		add(level = new Level(new LdtkProject(), "Map_0", AssetPaths.forest_tileset__png));
		level.place_entities();

		var diff_x:Float = FlxG.width > level.width ? (FlxG.width - level.width) / 2 : 0;
		var diff_y:Float = FlxG.height > level.height ? (FlxG.height - level.height) / 2 : 0;
		FlxG.worldBounds.set(level.x, level.y, level.width, level.height);
		FlxG.camera.setScrollBounds(level.x - diff_x, level.width + diff_x, level.y - diff_y, level.height + diff_y);
	}

	override public function update(elapsed:Float)
	{
		current_grid_state.update();
		if (Ctrl.any(Ctrl.reset))
			FlxG.switchState(new PlayState());
		super.update(elapsed);
	}
}
