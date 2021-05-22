package ui.attack;

import GridState.AttackData;
import flixel.FlxSubState;
import flixel.system.FlxSplash;

/**
 * Fancy attack animation, like Advance Wars/Fire Emblem
 */
class AttackAnimationSubstate extends FlxSubState
{
	var dark_bg:FlxSpriteExt;
	var dark_bg_alpha:Float = 0.75;

	var animation:AttackAnimationHandler;

	public function new(attack_data:AttackData)
	{
		super();

		create_dark_bg();

		add(dark_bg);
		add(animation = new AttackAnimationHandler(attack_data, new AttackBackground()));

		animation.offset.y = FlxG.height / 2;
	}

	override function update(elapsed:Float)
	{
		if (!animation.finished)
		{
			if (dark_bg.alpha <= dark_bg_alpha)
				dark_bg.alpha += dark_bg_alpha / 10;

			if (animation.offset.y > 0)
				animation.offset.y -= FlxG.height / (2 * 10);
		}
		else
		{
			animation.offset.y += FlxG.height / (2 * 10);
			dark_bg.alpha -= dark_bg_alpha / 10;
			if (dark_bg.alpha <= 0)
				FlxG.state.closeSubState();
		}

		super.update(elapsed);
	}

	function create_dark_bg()
	{
		dark_bg = new FlxSpriteExt(-16, 16);
		dark_bg.makeGraphic(FlxG.width + 32, FlxG.height + 32, FlxColor.BLACK);
		dark_bg.alpha = 0;

		dark_bg.scrollFactor.set();
	}
}
