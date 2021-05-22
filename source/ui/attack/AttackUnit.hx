package ui.attack;

import GridState.AttackData;
import actors.Weapon.WeaponDef;

class AttackUnit extends FlxSpriteExt
{
	public var ATTACK_DISTANCE:Int = 64; // pixels AWAY from the enemy
	public final MOVE_SPEED:Int = 400;

	/**Is this the attacking unit?*/
	var ATTACKER:Bool = false;

	/**Is the attack finished? Both these need to be true.*/
	var ATTACK_FINISHED:Bool = false;

	var target:AttackUnit;

	public var weapon:WeaponDef;

	/**Has this animation resolved everything it needs to do*/
	public var finished:Bool = false;

	var attack_data:AttackData;

	public function new(Data:AttackData, ?X:Float = 0, ?Y:Float = 0, type:String, is_attacker:Bool = true)
	{
		super(X, Y);

		attack_data = Data;

		loadAllFromAnimationSet(type);

		if (!is_attacker)
		{
			flipX = true;
			x -= width;
		}

		ATTACKER = is_attacker;

		y += -height;
	}

	override function update(elapsed:Float)
	{
		switch (state)
		{
			case "moving":
				run_forward();
			case "attacking":
				attack();
			case "damage":
				receive_damage();
			case "none":
				finished = true;
		}
		super.update(elapsed);
	}

	/**
	 * Set the opposite unit
	 * @param Target the opposite unit
	 */
	public function set_target(Target:AttackUnit)
	{
		target = Target;
	}

	/**
	 * Start an attack animation
	 */
	public function start_attack()
	{
		sstate("moving");
	}

	/**
	 * Attack handler
	 */
	function attack()
	{
		ttick();
		if (tick < 5)
			return;
		velocity.x = 0;
		animProtect("attack");
		if (animation.finished)
		{
			anim("idle");
			sstate("none");
			finished = true;
		}
	}

	/**
	 * Run forward and start an attack
	 */
	function run_forward()
	{
		ttick();
		if (tick < 5)
			return;
		anim("move");
		velocity.x = MOVE_SPEED;
		if (x + width > target.x - ATTACK_DISTANCE)
		{
			x = target.x - ATTACK_DISTANCE - width;
			velocity.x = 0;
			anim("idle");
			sstate("attacking");
			target.sstate("damage");
		}
	}

	/**
	 * Take a hit, shake and red flash
	 */
	function receive_damage()
	{
		if (tick == 0)
		{
			color = FlxColor.RED;
			var damage:Float = !ATTACKER ? attack_data.attacking_damage : attack_data.defending_damage;
			FlxG.state.subState.add(new DamageText(getGraphicMidpoint().x, getGraphicMidpoint().y, damage));
			Utils.shake("light");
		}

		ttick();
		offset.y = tick % 12 >= 6 ? -2 : 2;
		offset.x = tick % 12 >= 6 ? -2 : 2;
		color = color.getLightened(0.05);

		if (tick > 15)
		{
			offset.set(0, 0);
			sstate("none");
		}
	}
}
