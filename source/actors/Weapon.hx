package actors;

typedef WeaponDef =
{
	w_id:Int,
	name:String,
	attack_type:WeaponAttackType,
	str:Int,
	range:Int,
	blindspot:Int,
	knockback:Int
}

@:enum
abstract WeaponAttackType(Int)
{
	/**Can move and attack to get max range, Melee weapons are RANGED but with range of 1*/
	var RANGED = 0;

	/**Can't move and attack with this weapon*/
	var ARTILLERY = 1;
}
