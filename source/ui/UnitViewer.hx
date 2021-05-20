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

	var unit_copy:FlxSprite;
	var unit_copy_base_position:FlxPoint = new FlxPoint(118, 90);
	var unit_copy_base_dimensions:FlxPoint = new FlxPoint(44, 44);
	var unit_copy_base_color:FlxColor = 0xff585651;

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

		unit_copy = new FlxSprite();
		unit_copy.makeGraphic(Math.floor(unit_copy_base_dimensions.x), Math.floor(unit_copy_base_dimensions.y), unit_copy_base_color);
		clear_unit_copy();
		add(unit_copy);

		setPosition(FlxG.width - width, FlxG.height - height);

		scrollFactor.set(0, 0);

		clear_data();
	}

	override function update(elapsed:Float)
	{
		Utils.move_and_trace("", hp_bar, this);
		if (PlayState.self.selected_unit != null)
			set_data(PlayState.self.current_state.grid.units.get(PlayState.self.selected_unit.uid));
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

		copy_unit();
	}

	public function clear_data()
	{
		hp_bar.value = 0;

		hp_text.text = "";
		name_text.text = "";

		moves_left.animation.frameIndex = moves_max.animation.frameIndex = 0;

		hp_bar.updateBar();
		clear_unit_copy();
	}

	function clear_unit_copy()
	{
		unit_copy.graphic.bitmap.fillRect(unit_copy.graphic.bitmap.rect, unit_copy_base_color);
		unit_copy.setPosition(x + unit_copy_base_position.x, y + unit_copy_base_position.y);
		unit_copy.scrollFactor.set();
	}

	function copy_unit()
	{
		clear_unit_copy();
		if (PlayState.self.selected_unit != null)
		{
			unit_copy.stamp(PlayState.self.selected_unit, Math.floor(unit_copy_base_dimensions.x / 2 - PlayState.self.selected_unit.width / 2),
				Math.floor(unit_copy_base_dimensions.y - PlayState.self.selected_unit.height));
			unit_copy.flipX = PlayState.self.selected_unit.flipX;
		}
	}
}
