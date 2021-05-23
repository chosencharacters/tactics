package actors;

import actors.Weapon.WeaponAttackStat;
import actors.Weapon.WeaponAttackType;
import flixel.math.FlxRandom;

class Slime extends Unit
{
	public function new(?X:Float = 0, ?Y:Float = 0)
	{
		super(X, Y);

		team = 2;
		speed = 3;
		max_health = 25;
		str = 5;

		name = "slime";

		loadAllFromAnimationSet("slime");

		weapons = [
			{
				w_id: Utils.get_unused_id(),
				name: "slam",
				attack_type: WeaponAttackType.RANGED,
				primary_stat: WeaponAttackStat.STR,
				can_retaliate: true,
				range: 1,
				might: 10,
				retaliate_might: 5,
				blindspot: 0,
				knockback: 3
			}
		];

		init();
	}

	override function update(elapsed:Float)
	{
		snap_to_grid();

		if (!REALIZING)
			SELECTED ? anim("move") : anim("idle");

		super.update(elapsed);
	}
}
