package actors;

import GridState.GridStateTurn;
import GridState.SearchNode;
import GridState.UnitData;
import actors.Weapon.WeaponDef;
import flixel.text.FlxText;
import flixel.tile.FlxBaseTilemap.FlxTilemapDiagonalPolicy;
import flixel.util.FlxPath;

class Unit extends Actor
{
	public var SELECTED:Bool = false;
	public var REALIZING:Bool = false;

	var speed:Int = 0;

	var movement_left:Int = -1;

	var movement_options:Array<FlxPoint> = new Array<FlxPoint>();
	var movement_options_nodes:Array<SearchNode> = new Array<SearchNode>();

	var attack_options:Array<SearchNode> = new Array<SearchNode>();
	var immediate_attack_options:Array<SearchNode> = new Array<SearchNode>();

	var movement_path:Array<FlxPoint> = new Array<FlxPoint>();

	public var u_id:Int = 0;

	var weapons:Array<WeaponDef> = [];

	public function new(?X:Float = 0, ?Y:Float = 0)
	{
		super(X, Y);

		u_id = Utils.get_unused_id();

		PlayState.self.units.add(this);
	}

	override function update(elapsed:Float)
	{
		if (movement_left <= -1)
			new_turn();
		select_position();
		super.update(elapsed);
	}

	function new_turn()
	{
		movement_left = speed;
	}

	public function realize_move(state:GridState, turn:GridStateTurn)
	{
		if (!REALIZING && turn.path.length > 0)
		{
			for (node in turn.path)
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
				x = tile_x - width / 2;
				velocity.y = tile_y < my_y ? -vel : vel;
			}
			else
			{
				tile_position.set(move_tile_position.x / level.tile_size, move_tile_position.y / level.tile_size);
				if (movement_path.length <= 0)
					state.turns.shift();
				if (movement_path.length <= 0)
					REALIZING = false;
				else
					move_tile_position = movement_path.shift();
			}
		}
	}

	public function realize_attack(state:GridState, target_unit:Unit, weapon:WeaponDef)
	{
		state.attack(get_unit_data(), target_unit.get_unit_data(), weapon);
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
		movement_options = get_movement_options(PlayState.self.current_grid_state, tile_position);
	}

	function get_movement_options(state:GridState, start:FlxPoint, auto_highlight:Bool = true):Array<FlxPoint>
	{
		var start_time:Float = Sys.time();

		var valid_moves:Array<FlxPoint> = [];
		var valid_attacks:Array<FlxPoint> = [];

		movement_options_nodes = state.grid.bfs_movement_options(start, start, get_unit_data(), movement_left);
		for (m in movement_options_nodes)
		{
			trace(m.path.length);
		}

		attack_options = state.grid.calculate_all_attack_options(get_unit_data(), movement_options_nodes, speed != movement_left);

		for (n in movement_options_nodes)
			valid_moves.push(new FlxPoint(n.x, n.y));

		for (n in attack_options)
			valid_attacks.push(new FlxPoint(n.x, n.y));

		if (auto_highlight)
		{
			PlayState.self.select_squares.select_squares(valid_moves);
			PlayState.self.select_squares.select_squares(valid_attacks, true);
		}

		trace("TIME: " + (Sys.time() - start_time));

		if (Main.DEBUG_PATH)
		{
			for (n in movement_options_nodes)
				Utils.add_blank_tile_square(new FlxPoint(n.x * level.tile_size, n.y * level.tile_size));
			for (n in movement_options_nodes)
			{
				var text:FlxText = new FlxText(n.x * level.tile_size, n.y * level.tile_size, n.distance + "");
				text.color = FlxColor.BLACK;
				FlxG.state.add(text);
			}
		}

		return valid_moves;
	}

	function teleport(X:Float, Y:Float)
	{
		tile_position.x = Math.floor(X);
		tile_position.y = Math.floor(Y);
		PlayState.self.regenerate_grid();
	}

	public function select_position()
	{
		var SELECT_INPUT:Bool = Ctrl.cursor_select;
		var CURSOR_POSITION:FlxPoint = PlayState.self.cursor.tile_position;
		var selected_pos:FlxPoint;

		if (!SELECT_INPUT || !SELECTED)
			return;

		for (pos in movement_options)
		{
			var CURSOR_MATCH:Bool = CURSOR_POSITION.x == pos.x && CURSOR_POSITION.y == pos.y;
			var SELF_MATCH:Bool = CURSOR_POSITION.x == tile_position.x && CURSOR_POSITION.y == tile_position.y;
			if (CURSOR_MATCH && !SELF_MATCH)
			{
				// teleport(CURSOR_POSITION.x, CURSOR_POSITION.y);
				PlayState.self.current_grid_state.add_move_turn(this, movement_options_nodes[movement_options.indexOf(pos)]);

				movement_left -= movement_options_nodes[movement_options.indexOf(pos)].distance;

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
				var enemy_unit:Unit = PlayState.self.current_grid_state.find_unit_actual_in_units(pos.unit);

				trace(pos.path);
				trace(pos.path.length, pos.path[pos.path.length - 1]);
				trace('attack node path (${pos.x}, ${pos.y}) length: ${pos.path.length}');

				teleport(pos.path[pos.path.length - 1].x, pos.path[pos.path.length - 1].y);
				PlayState.self.current_grid_state.add_attack_turn(this, enemy_unit, pos.weapon, false);

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
			x: Math.floor(tile_position.x),
			y: Math.floor(tile_position.y),
			team: team,
			speed: speed,
			movement_left: movement_left,
			u_id: u_id,
			weapons: weapons,
			health: health
		};
	}

	public function write_from_unit_data(data:UnitData)
	{
		tile_position.x = data.x;
		tile_position.y = data.y;
		snap_to_grid();
	}
}
