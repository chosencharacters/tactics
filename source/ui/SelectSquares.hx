package ui;

import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;

class SelectSquares extends FlxTypedSpriteGroup<FlxSpriteExt>
{
	var squares_array:Array<Array<FlxSpriteExt>> = [];

	var width_in_tiles:Int = 0;
	var height_in_tiles:Int = 0;

	var base_alpha:Float = 0.25;

	public function new(?X:Float = 0, ?Y:Float = 0)
	{
		super(PlayState.self.level.x, PlayState.self.level.y);
		create_squares();
		clear_squares();
	}

	function create_squares()
	{
		width_in_tiles = PlayState.self.level.widthInTiles;
		height_in_tiles = PlayState.self.level.heightInTiles;

		for (col in 0...width_in_tiles)
			for (row in 0...height_in_tiles)
				create_square(col, row);
	}

	function create_square(X:Int, Y:Int)
	{
		if (squares_array[X] == null)
			squares_array[X] = [];
		var square:FlxSpriteExt = new FlxSpriteExt(X * PlayState.self.level.tile_size, Y * PlayState.self.level.tile_size);
		square.loadGraphic(AssetPaths.movable_tile__png);
		alpha = base_alpha;
		squares_array[X].push(square);
		add(square);
	}

	public function select_squares(positions:Array<SearchNode>, attack_highlights:Bool = false)
	{
		if (!attack_highlights)
			clear_squares();

		var transparent_square_alpha:Float = base_alpha / 8;

		// cool transparent square effect
		for (pos in positions)
		{
			for (i in 0...4)
			{
				var square:FlxSpriteExt = get_square(Math.floor(pos.x), Math.floor(pos.y));
				switch (i)
				{
					case 0:
						square = get_square(Math.floor(pos.x - 1), Math.floor(pos.y));
					case 1:
						square = get_square(Math.floor(pos.x + 1), Math.floor(pos.y));
					case 2:
						square = get_square(Math.floor(pos.x), Math.floor(pos.y - 1));
					case 3:
						square = get_square(Math.floor(pos.x), Math.floor(pos.y + 1));
				}
				if (square != null)
				{
					if (!attack_highlights)
					{
						square.visible = true;
						square.alpha = transparent_square_alpha;
					}
					square.color = FlxColor.WHITE;
				}
			}
		}

		// select squares
		for (pos in positions)
		{
			var square:FlxSpriteExt = get_square(Math.floor(pos.x), Math.floor(pos.y));
			square.visible = true;
			square.alpha = attack_highlights ? 1 : base_alpha;
			square.color = attack_highlights ? FlxColor.RED : FlxColor.WHITE;
		}
	}

	function clear_squares()
	{
		for (col in 0...width_in_tiles)
			for (row in 0...height_in_tiles)
				get_square(col, row).visible = false;
	}

	function get_square(X:Int, Y:Int):FlxSpriteExt
	{
		return squares_array[X] != null ? squares_array[X][Y] : null;
		// return squares_array[Y * width_in_tiles + X];
	}
}
