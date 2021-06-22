package ui;

import GridState.GridArray;
import flixel.text.FlxText;
import levels.Level;

class Cursor extends FlxSpriteExt
{
	var position_text:FlxText;

	public var tile_position:FlxPoint = new FlxPoint();

	public function new(?X:Float = 0, ?Y:Float = 0)
	{
		super(X, Y);

		loadAllFromAnimationSet("cursor");

		// Load the sprite's graphic to the cursor
		FlxG.mouse.load(new FlxSprite().makeGraphic(8, 8).pixels);

		PlayState.self.add(position_text = new FlxText());
	}

	override function update(elapsed:Float)
	{
		FlxG.mouse.visible = false;

		var level:Level = PlayState.self.level;
		var world_tile_pos:FlxPoint = level.getTileCoordsByIndex(level.getTileIndexByCoords(FlxG.mouse.getPosition()), false);

		tile_position.set((world_tile_pos.x - level.x) / level.tile_size, (world_tile_pos.y - level.y) / level.tile_size);

		setPosition(world_tile_pos.x, world_tile_pos.y);

		select();

		position_text.text = '${x}, ${y}\n${tile_position.x}, ${tile_position.y}\n'
			+ (tile_position.y * PlayState.self.current_state.grid.width_in_tiles + tile_position.x);

		if (PlayState.self.selected_unit != null && !PlayState.self.current_state.realizing_state)
		{
			highlight_path();
		}

		super.update(elapsed);
	}

	function highlight_path()
	{
		var grid:GridArray = PlayState.self.current_state.grid;
		var unit:UnitData = PlayState.self.selected_unit.get_unit_data();

		var source_node:SearchNode = grid.get_unit_data_node(unit);

		var movement_options:Array<SearchNode> = grid.movement_options.get(PlayState.self.selected_unit.uid);
		var attack_options:Array<SearchNode> = grid.attack_options.get(PlayState.self.selected_unit.uid);

		var CURSOR_POSITION:FlxPoint = PlayState.self.cursor.tile_position;

		if (movement_options != null)
			for (target_node in movement_options)
				if (CURSOR_POSITION.x == target_node.x && CURSOR_POSITION.y == target_node.y)
					PlayState.self.select_squares.path_highlight.update_path(target_node.path.copy()
						.concat([target_node.y * grid.width_in_tiles + target_node.x]), false);

		if (attack_options != null)
			for (target_node in attack_options)
				if (CURSOR_POSITION.x == target_node.x && CURSOR_POSITION.y == target_node.y)
					PlayState.self.select_squares.path_highlight.update_path(target_node.path.copy()
						.concat([target_node.y * grid.width_in_tiles + target_node.x]), true);
	}

	function select()
	{
		var tile_x:Int = Math.floor((x - PlayState.self.level.x) / PlayState.self.level.tile_size);
		var tile_y:Int = Math.floor((y - PlayState.self.level.y) / PlayState.self.level.tile_size);

		if (Ctrl.cursor_select)
		{
			PlayState.self.unit_viewer.clear_data();

			PlayState.self.selected_unit = null;

			PlayState.self.select_squares.select_squares([]);
			for (unit in PlayState.self.units)
				unit.SELECTED = false;
			for (unit in PlayState.self.units)
			{
				var TEAM_OK:Bool = unit.team == PlayState.self.current_state.active_team;
				if (unit.tile_position.x == tile_x && unit.tile_position.y == tile_y && unit.alive)
				{
					PlayState.self.selected_unit = unit;
					if (TEAM_OK && !unit.exhausted)
						unit.select();
					return;
				}
			}
		}
	}

	public function unselect()
	{
		PlayState.self.selected_unit = null;
	}
}
