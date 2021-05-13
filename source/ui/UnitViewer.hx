package ui;

import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import flixel.text.FlxText;

class UnitViewer extends FlxTypedSpriteGroup<FlxSprite>
{
	var base:FlxSpriteExt;
	var moves_left:FlxSpriteExt;
	var hp_text:FlxText;
	var name_text:FlxText;

	public function new()
	{
		super();

		base = new FlxSpriteExt(AssetPaths.unit_ui__png);
		add(base);

		moves_left = new FlxSpriteExt(11, 28);
		moves_left.loadGraphic(AssetPaths.moves_bar__png, true, 68, 4);
		add(moves_left);

		hp_text = new FlxText(24, 4, 60, "50/50");
		hp_text = Utils.formatText(hp_text, "right", FlxColor.WHITE, false, "assets/fonts/6px-Normal.ttf", 8);
		add(hp_text);

		name_text = new FlxText(4, 57, 54, "AAAAAAAAAAAA");
		name_text = Utils.formatText(name_text, "right", FlxColor.WHITE, false, "assets/fonts/6px-Normal.ttf", 8);
		add(name_text);

		setPosition(FlxG.width - width, FlxG.height - height);

		scrollFactor.set(0, 0);
	}

	override function update(elapsed:Float)
	{
		set_data(PlayState.self.units.getFirstAlive().get_unit_data());
		super.update(elapsed);
	}

	function set_data(unit:UnitData)
	{
		moves_left.animation.frameIndex = unit.movement_left;
	}
}
