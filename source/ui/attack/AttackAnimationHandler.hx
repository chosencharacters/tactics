package ui.attack;

import GridState.AttackData;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;

class AttackAnimationHandler extends FlxTypedSpriteGroup<FlxSprite>
{
	var tick:Int = 0;

	/**attacking unit*/
	var unit1:AttackUnit;

	/**defending unit*/
	var unit2:AttackUnit;

	public var finished:Bool = false;

	public function new(attack_data:AttackData, attack_background:FlxSprite)
	{
		super();

		unit1 = new AttackUnit(attack_data, attack_background.x, 220 + 32, "boy", true);
		unit2 = new AttackUnit(attack_data, attack_background.x + attack_background.width, 220 + 32, "slime", false);

		unit1.set_target(unit2);
		unit2.set_target(unit1);

		add(attack_background);
		add(unit1);
		add(unit2);
	}

	override function update(elapsed:Float)
	{
		tick++;
		if (tick == 15)
			unit1.start_attack();
		if (unit1.finished)
			finished = true;
		super.update(elapsed);
	}
}
