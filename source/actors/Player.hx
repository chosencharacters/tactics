package actors;

import actors.Weapon.WeaponAttackType;

class Player extends Unit
{
	public function new(?X:Float = 0, ?Y:Float = 0)
	{
		super(X, Y);

		team = 1;
		speed = 3;
		health = 25;
		name = "Rodney";

		loadAllFromAnimationSet("boy");

		weapons = [
			{
				w_id: Utils.get_unused_id(),
				name: "gun",
				attack_type: WeaponAttackType.RANGED,
				str: 1,
				range: 1,
				blindspot: 0,
				knockback: 3
			}
		];
	}

	override function update(elapsed:Float)
	{
		snap_to_grid();

		if (!REALIZING)
			SELECTED ? anim("move") : anim("idle");

		super.update(elapsed);
	}
}
