package ui;

import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import flixel.text.FlxText;
import flixel.ui.FlxBar;

class UnitViewer extends FlxTypedSpriteGroup<FlxSprite>
{
	var base:FlxSpriteExt;

	var moves_left:FlxSpriteExt;
	var moves_max:FlxSpriteExt;

	var hp_text:FlxText;
	var name_text:FlxText;

	var hp_bar:FlxBar;

	public function new()
	{
		super();

		base = new FlxSpriteExt(AssetPaths.unit_ui__png);
		add(base);

		moves_max = new FlxSpriteExt(22, 56);
		moves_max.loadGraphic(AssetPaths.moves_bar_max__png, true, 136, 8);
		add(moves_max);

		moves_left = new FlxSpriteExt(22, 56);
		moves_left.loadGraphic(AssetPaths.moves_bar__png, true, 136, 8);
		add(moves_left);

		hp_text = new FlxText(43, 7, 120, "50/50");
		hp_text = Utils.formatText(hp_text, "right", FlxColor.WHITE, false, "assets/fonts/6px-Normal.ttf", 16);
		add(hp_text);

		name_text = new FlxText(5, 115, 108, "Rodney");
		name_text = Utils.formatText(name_text, "right", FlxColor.WHITE, false, "assets/fonts/6px-Normal.ttf", 16);
		add(name_text);

		hp_bar = new FlxBar(22, 28, FlxBarFillDirection.LEFT_TO_RIGHT, 136, 8);
		hp_bar.createFilledBar(0xff32222c, 0xff1bff00);
		add(hp_bar);

		setPosition(FlxG.width - width, FlxG.height - height);

		scrollFactor.set(0, 0);

		clear_data();
	}

	override function update(elapsed:Float)
	{
		Utils.move_and_trace("", hp_bar, this);
		if (PlayState.self.selected_unit != null)
			set_data(PlayState.self.selected_unit.get_unit_data());
		super.update(elapsed);
	}

	function set_data(unit:UnitData)
	{
		moves_left.animation.frameIndex = unit.movement_left;
		moves_max.animation.frameIndex = unit.speed;

		hp_bar.setRange(0, unit.max_health);
		hp_bar.value = unit.health;

		hp_text.text = unit.health + "/" + unit.max_health;
		name_text.text = unit.name;

		hp_bar.updateBar();
	}

	public function clear_data()
	{
		trace("data clear");

		hp_bar.value = 0;

		hp_text.text = "";
		name_text.text = "";

		moves_left.animation.frameIndex = moves_max.animation.frameIndex = 0;

		hp_bar.updateBar();
	}
}
