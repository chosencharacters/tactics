package levels;

import enemies.*;
import flixel.tile.FlxTilemap;
import platforms.*;

class Level extends LDTKLevel
{
	public var col:FlxTilemap;

	var project:LdtkProject;
	var level_name:String;

	public function new(project:LdtkProject, level_name:String, graphic:String)
	{
		super(project, level_name, graphic);
	}

	override function generate(Project:LdtkProject, LevelName:String, Graphic:String)
	{
		project = Project;
		level_name = LevelName;

		super.generate(project, level_name, Graphic);

		for (i in 0..._tileObjects.length)
			setTileProperties(i, FlxObject.NONE);

		var data = get_level_by_name(project, level_name);

		col = new FlxTilemap();
		col.loadMapFromArray([for (i in 0...array_len) 1], lvl_width, lvl_height, graphic, tile_size, tile_size);

		for (key in data.l_AutoSource.intGrid.keys())
			col.setTileByIndex(key, data.l_AutoSource.intGrid.get(key));
		for (i in [0, 3, 4])
			col.setTileProperties(i, FlxObject.NONE);
	}

	public function place_entities()
	{
		var data = get_level_by_name(project, level_name);

		for (entity in data.l_Entities.all_Player.iterator())
			new Player(entity.cx, entity.cy);
		for (entity in data.l_Entities.all_Grill.iterator())
			new Grill(entity.cx, entity.cy);
		for (entity in data.l_Entities.all_Slime.iterator())
			new Slime(entity.cx, entity.cy);

		/*
			for (index in 0...col.totalTiles)
			{
				var pos:FlxPoint = col.getTileCoordsByIndex(index);
				pos.subtract(tile_size / 2, tile_size / 2);
				switch (col.getTileByIndex(index))
				{
					case 2:
						new Block(pos.x, pos.y);
						setTileByIndex(index, 1);
					case 3:
						new Spikes(pos.x, pos.y);
					case 4:
						new Exit(pos.x, pos.y);
				}
		}*/
	}
}
