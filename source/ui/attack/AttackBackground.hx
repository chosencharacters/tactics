package ui.attack;

import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;

/**
 * Simple attack background, this can change based on the tile they're standing on
 */
class AttackBackground extends FlxTypedSpriteGroup<FlxSpriteExt>
{
	var environment:FlxSpriteExt;
	var border:FlxSpriteExt;

	public function new(?node:SearchNode)
	{
		super(102, 76);

		border = new FlxSpriteExt(0, 0, AssetPaths.attack_anim_border__png);
		environment = new FlxSpriteExt(border.x, border.y, AssetPaths.attack_anim_environment__png);
		environment_copy_border_position();

		add(environment);
		add(border);

		scrollFactor.set();
	}

	override function update(elapsed:Float)
	{
		environment_copy_border_position();
		super.update(elapsed);
	}

	function environment_copy_border_position()
	{
		environment.setPosition(border.x, border.y);
		environment.offset.copyFrom(border.offset);
	}
}
