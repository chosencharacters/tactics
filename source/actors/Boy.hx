package actors;

import actors.Weapon.WeaponAttackStat;
import actors.Weapon.WeaponAttackType;

class Boy extends Unit
{
	public function new(?X:Float = 0, ?Y:Float = 0)
	{
		super(X, Y);

		team = 1;
		speed = 3;
		health = 25;
		str = 5;

		name = "Rodney";

		loadAllFromAnimationSet("boy");

		weapons = [
			{
				w_id: Utils.get_unused_id(),
				name: "sword",
				attack_type: WeaponAttackType.RANGED,
				primary_stat: WeaponAttackStat.STR,
				can_retaliate: true,
				range: 1,
				might: 15,
				retaliate_might: 7,
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
