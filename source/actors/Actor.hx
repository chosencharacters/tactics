package actors;

class Actor extends FlxSpriteExt
{
	public var tile_position:FlxPoint = new FlxPoint();
	public var move_tile_position:FlxPoint = new FlxPoint();

	var level:Level;

	public var team:Int = 0;

	var random:FlxRandom;

	public function new(?X:Float = 0, ?Y:Float = 0)
	{
		level = PlayState.self.level;
		random = new FlxRandom();

		tile_position.set(X, Y);

		super(X, Y);
	}
}
