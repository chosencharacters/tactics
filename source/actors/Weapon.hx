package actors;

typedef WeaponDef =
{
	w_id:Int,
	name:String,
	attack_type:WeaponAttackType,
	primary_stat:WeaponAttackStat,
	range:Int,
	might:Int,
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

@:enum
abstract WeaponAttackStat(String)
{
	/**This is an int based weapon i.e. magic,*/
	var INT = "Intelligence";

	/**This is a strength based weapon i.e. sword, axe*/
	var STR = "Strength";

	/**This is a dex based weapon i.e. dagger, arrows*/
	var DEX = "Dexterity";
}
