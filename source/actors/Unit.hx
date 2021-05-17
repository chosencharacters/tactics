package actors;

import actors.Weapon.WeaponDef;
import flixel.text.FlxText;
import flixel.tile.FlxBaseTilemap.FlxTilemapDiagonalPolicy;
import flixel.util.FlxPath;

class Unit extends Actor
{
	public var SELECTED:Bool = false;
	public var REALIZING:Bool = false;

	var speed:Int = 0;
	var max_health:Int = 50;

	public var movement_left:Int = -1;

	var name:String = "";

	var movement_path:Array<FlxPoint> = new Array<FlxPoint>();

	public var uid:Int = 0;

	var weapons:Array<WeaponDef> = [];

	var movement_options:Array<SearchNode>;
	var attack_options:Array<SearchNode>;

	public function new(?X:Float = 0, ?Y:Float = 0)
	{
		super(X, Y);

		uid = Utils.get_unused_id();
		new_turn();

		PlayState.self.units.add(this);
	}

	override function update(elapsed:Float)
	{
		select_position();
		super.update(elapsed);
	}

	function new_turn()
	{
		trace("NEW TURN");
		movement_left = speed;
	}

	public function realize_move(state:GridState, turn:GridStateTurn)
	{
		if (!REALIZING && turn.path.length > 0)
		{
			for (node in state.grid.get_path_as_nodes(turn.path))
				movement_path.push(FlxPoint.weak(node.x * level.tile_size, node.y * level.tile_size));

			move_tile_position = movement_path.shift();
			REALIZING = true;
		}

		if (!REALIZING)
			return;

		if (move_tile_position.x != -1 && move_tile_position.y != -1)
		{
			anim("move");
			var vel:Int = 300;

			velocity.set(0, 0);
			var tile_x:Int = Math.floor(move_tile_position.x + level.tile_size / 2);
			var my_x:Int = Math.floor(x + width / 2);

			var tile_y:Int = Math.floor(move_tile_position.y + level.tile_size - height);
			var my_y:Int = Math.floor(y);

			var NOT_ON_X:Bool = tile_x < my_x - 4 || tile_x > my_x + 4;
			var NOT_ON_Y:Bool = tile_y < my_y - 4 || tile_y > my_y + 4;
			if (NOT_ON_X)
			{
				velocity.x = tile_x < my_x + 4 ? -vel : vel;
				flipX = velocity.x < 0;
			}
			else if (NOT_ON_Y)
			{
				trace("PRE", x);
				x = tile_x - width / 2;
				velocity.y = tile_y < my_y ? -vel : vel;
				trace("POST:", x);
			}
			else
			{
				tile_position.set(move_tile_position.x / level.tile_size, move_tile_position.y / level.tile_size);
				if (movement_path.length <= 0)
					REALIZING = false;
				else
					move_tile_position = movement_path.shift();
				if (!REALIZING)
					PlayState.self.cursor.unselect();
			}
		}
	}

	public function realize_attack(state:GridState, target_unit:UnitData, weapon:WeaponDef)
	{
		state.attack(state.grid.units.get(uid), target_unit, weapon);
	}

	function snap_to_grid()
	{
		if (REALIZING)
			return;
		var cords:FlxPoint = FlxPoint.weak(tile_position.x * level.tile_size, tile_position.y * level.tile_size);
		cords.x += PlayState.self.level.tile_size / 2 - width / 2;
		cords.y += PlayState.self.level.tile_size - height;
		setPosition(cords.x, cords.y);
	}

	public function select()
	{
		SELECTED = true;
		PlayState.self.selected_unit = this;
		get_movement_options(PlayState.self.current_grid_state, tile_position);
	}

	function get_movement_options(state:GridState, start:FlxPoint, auto_highlight:Bool = true):Array<SearchNode>
	{
		#if !html5
		var start_time:Float = Sys.time();
		#end

		state.grid.bfs_movement_options(start, state.grid.units.get(uid));

		movement_options = state.grid.movement_options.get(uid);
		attack_options = state.grid.attack_options.get(uid);

		if (auto_highlight)
		{
			PlayState.self.select_squares.select_squares(movement_options);
			PlayState.self.select_squares.select_squares(attack_options, true);
		}

		#if !html5
		trace("TIME: " + (Sys.time() - start_time));
		#end

		if (Main.DEBUG_PATH)
		{
			for (n in movement_options)
				Utils.add_blank_tile_square(new FlxPoint(n.x * level.tile_size, n.y * level.tile_size));
			for (n in movement_options)
			{
				var text:FlxText = new FlxText(n.x * level.tile_size, n.y * level.tile_size, n.distance + "");
				text.color = FlxColor.BLACK;
				FlxG.state.add(text);
			}
		}

		return movement_options;
	}

	function teleport(X:Float, Y:Float)
	{
		tile_position.x = Math.floor(X);
		tile_position.y = Math.floor(Y);
		PlayState.self.regenerate_state();
	}

	public function select_position()
	{
		var state:GridState = PlayState.self.current_grid_state;
		var SELECT_INPUT:Bool = Ctrl.cursor_select;
		var CURSOR_POSITION:FlxPoint = PlayState.self.cursor.tile_position;

		if (!SELECT_INPUT || !SELECTED)
			return;

		for (pos in movement_options)
		{
			var CURSOR_MATCH:Bool = CURSOR_POSITION.x == pos.x && CURSOR_POSITION.y == pos.y;
			var SELF_MATCH:Bool = CURSOR_POSITION.x == tile_position.x && CURSOR_POSITION.y == tile_position.y;
			if (CURSOR_MATCH && !SELF_MATCH)
			{
				PlayState.self.current_grid_state.add_move_turn(state.grid.units.get(uid), pos);

				SELECTED = false;
				Ctrl.cursor_select = false;
				PlayState.self.select_squares.select_squares([]);
				return;
			}
		}
		for (pos in attack_options)
		{
			var CURSOR_MATCH:Bool = CURSOR_POSITION.x == pos.x && CURSOR_POSITION.y == pos.y;
			var SELF_MATCH:Bool = CURSOR_POSITION.x == tile_position.x && CURSOR_POSITION.y == tile_position.y;
			if (CURSOR_MATCH && !SELF_MATCH)
			{
				var enemy_unit:UnitData = pos.unit;
				var path_nodes:Array<SearchNode> = PlayState.self.current_grid_state.grid.get_path_as_nodes(pos.path);

				PlayState.self.current_grid_state.add_move_turn(state.grid.units.get(uid), path_nodes[path_nodes.length - 1], false);
				PlayState.self.current_grid_state.add_attack_turn(state.grid.units.get(uid), enemy_unit, pos.weapon, true);

				movement_left = 0;

				SELECTED = false;
				Ctrl.cursor_select = false;
				PlayState.self.select_squares.select_squares([]);
				return;
			}
		}
	}

	public function get_unit_data():UnitData
	{
		return {
			name: name,
			types: [],
			x: Math.floor(tile_position.x),
			y: Math.floor(tile_position.y),
			team: team,
			max_health: max_health,
			speed: speed,
			movement_left: movement_left,
			uid: uid,
			weapons: weapons,
			health: health,
			moved_already: speed != movement_left
		};
	}

	public function write_from_unit_data(data:UnitData)
	{
		tile_position.x = data.x;
		tile_position.y = data.y;
		health = data.health;
		max_health = data.max_health;
		snap_to_grid();
	}
}
