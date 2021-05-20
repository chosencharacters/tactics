package states;

import TurnManager;
import flixel.FlxState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import levels.Level;
import ui.Cursor;
import ui.PathHighlight;
import ui.SelectSquares;
import ui.UnitViewer;

class PlayState extends BaseState
{
	public static var self:PlayState;

	public var level:Level;

	public var units:FlxTypedGroup<Unit>;

	public var ui:FlxTypedGroup<FlxSprite>;
	public var cursor:Cursor;
	public var select_squares:SelectSquares;
	public var selected_unit:Unit;

	public var current_state:GridState;

	public var unit_viewer:UnitViewer;

	var tick:Int = 30;

	public var turn_manager:TurnManager = new TurnManager();

	override public function create()
	{
		super.create();

		self = this;

		units = new FlxTypedGroup<Unit>();

		create_level();

		add(select_squares = new SelectSquares());
		add(units);
		add(cursor = new Cursor());
		add(ui = new FlxTypedGroup<FlxSprite>());

		ui.add(unit_viewer = new UnitViewer());

		regenerate_state();
		turn_manager.set_player(1, new HumanPlayerHandler(1));
		turn_manager.set_player(2, new BasicAI(2));
		turn_manager.end_turn();
	}

	public function regenerate_state()
	{
		current_state = new GridState();
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
		turn_manager.update();
		sort_units();
		current_state.update();
		if (Ctrl.any(Ctrl.reset))
			FlxG.switchState(new PlayState());
		super.update(elapsed);
	}

	public function sort_units()
	{
		haxe.ds.ArraySort.sort(units.members, function(a:Unit, b:Unit):Int
		{
			var a_index:Float = a.tile_position.y * current_state.grid.width_in_tiles + a.tile_position.x;
			var b_index:Float = b.tile_position.y * current_state.grid.width_in_tiles + b.tile_position.x;
			if (a_index == b_index)
				return 0;
			return a_index > b_index ? 1 : -1;
		});
	}
}
