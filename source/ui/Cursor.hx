package ui;

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

		position_text.text = x + ", " + y + "\n" + tile_position.x + ", " + tile_position.y;
		super.update(elapsed);
	}

	function select()
	{
		var tile_x:Int = Math.floor((x - PlayState.self.level.x) / PlayState.self.level.tile_size);
		var tile_y:Int = Math.floor((y - PlayState.self.level.y) / PlayState.self.level.tile_size);

		if (Ctrl.cursor_select)
		{
			PlayState.self.select_squares.select_squares([]);
			for (unit in PlayState.self.units)
				unit.SELECTED = false;
			for (unit in PlayState.self.units)
			{
				var TEAM_OK:Bool = unit.team == PlayState.self.current_grid_state.active_team;
				if (TEAM_OK && unit.tile_position.x == tile_x && unit.tile_position.y == tile_y)
				{
					unit.select();
					return;
				}
			}
		}
	}
}
