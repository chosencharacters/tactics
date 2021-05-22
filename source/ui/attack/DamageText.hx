package ui.attack;

import flixel.text.FlxText;

class DamageText extends FlxText
{
	public function new(?X:Float, ?Y:Float, Damage:Float = 0)
	{
		trace(Damage);
		super(X, Y, 100, Math.floor(Damage) + "");

		Utils.formatText(this, "center", FlxColor.WHITE, true, "assets/fonts/6px-Normal.ttf", 16);
		velocity.set(500, 500);

		x -= width / 2;
		y -= height / 2;
	}

	override function update(elapsed:Float)
	{
		x += 2;
		y -= 2;
		alpha -= 0.05;
		if (alpha <= 0)
			kill();
		super.update(elapsed);
	}
}
