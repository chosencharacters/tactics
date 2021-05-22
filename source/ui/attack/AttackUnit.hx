package ui.attack;

import GridState.AttackData;
import GridState.GridArray;
import actors.Weapon.WeaponDef;

class AttackUnit extends FlxSpriteExt
{
	public var ATTACK_DISTANCE:Int = 64; // pixels AWAY from the enemy
	public final MOVE_SPEED:Int = 400;

	/**Is this the attack unit?*/
	var ATTACKER:Bool = false;

	/**Is the attack finished? Both these need to be true.*/
	var ATTACK_FINISHED:Bool = false;

	var target:AttackUnit;

	public var weapon:WeaponDef;

	/**Has this animation resolved everything it needs to do*/
	public var finished:Bool = false;

	var attack_data:AttackData;

	public function new(Data:AttackData, ?X:Float = 0, ?Y:Float = 0, is_attacker:Bool = true)
	{
		super(X, Y);

		attack_data = Data;

		var state:GridState = PlayState.self.current_state;

		var unit:Unit = null;
		if (is_attacker)
			unit = state.unit_from_unit_data(attack_data.attacking_unit);
		else
			unit = state.unit_from_unit_data(attack_data.defending_unit);

		loadAllFromAnimationSet(unit.loaded_image);

		if (!is_attacker)
		{
			flipX = true;
			x -= width;
		}

		ATTACKER = is_attacker;

		ATTACK_DISTANCE = 64 * (attack_data.attack_range + 1);

		y += -height;
	}

	override function update(elapsed:Float)
	{
		finished = state == "none";
		switch (state)
		{
			case "moving":
				run_forward();
			case "attack":
				attack();
			case "damage":
				receive_damage();
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
		if (tick == 0)
			target.sstate("damage");
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
		if (attack_data.attack_range >= 4 || attack_data.artillery)
		{
			sstateAnim("attack");
			return;
		}

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
			sstate("attack");
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

			if (!ATTACKER && attack_data.defending_damage > 0)
			{
				if (tick > 30)
					sstate("attack");
			}
			else
			{
				sstate("none");
			}
		}
	}
}
