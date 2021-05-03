package actors;

import GridState.SearchNode;
import GridState.UnitData;
import flixel.text.FlxText;
import flixel.tile.FlxBaseTilemap.FlxTilemapDiagonalPolicy;

class Unit extends Actor
{
	public var SELECTED:Bool = false;

	var speed:Int = 0;

	var movement_options:Array<FlxPoint> = new Array<FlxPoint>();

	var u_id:Int = 0;

	static var total_ids:Int = 0;

	public function new(?X:Float = 0, ?Y:Float = 0)
	{
		super(X, Y);

		u_id = total_ids + 1;
		total_ids++;

		PlayState.self.units.add(this);
	}

	override function update(elapsed:Float)
	{
		select_position();
		super.update(elapsed);
	}

	function snap_to_grid()
	{
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

		valid_moves = bfs(state, start, start);

		if (auto_highlight)
			PlayState.self.select_squares.select_squares(valid_moves);

		trace("TIME: " + (Sys.time() - start_time));

		return valid_moves;
	}

	function bfs(state:GridState, start:FlxPoint, goal:FlxPoint):Array<FlxPoint>
	{
		var open_set:Array<SearchNode> = [state.grid.new_node(Math.floor(start.x), Math.floor(start.y))];
		var visited:Array<SearchNode> = [];
		var current:SearchNode;

		while (open_set.length > 0)
		{
			current = open_set.pop();
			visited.push(current);
			for (neighbor in get_neighbors(state, current, team))
				if (!set_contains_node(visited, neighbor) && neighbor.distance <= speed)
				{
					var text:FlxText = new FlxText(neighbor.x * level.tile_size, neighbor.y * level.tile_size, "" + neighbor.distance);
					PlayState.self.add(text);
					open_set.push(neighbor);
				}
		}

		var response_array:Array<FlxPoint> = [];

		for (v in visited)
		{
			var VALID_VISITED:Bool = true;
			for (u in state.grid.units)
				if (u.x == v.x && u.y == v.y)
					VALID_VISITED = false;
			if (VALID_VISITED)
				response_array.push(new FlxPoint(v.x, v.y));
		}

		return response_array;
	}

	function get_neighbors(state:GridState, current:SearchNode, team:Int):Array<SearchNode>
	{
		var neighbors:Array<SearchNode> = [];

		for (i in 0...4)
		{
			var new_neighbor:SearchNode = state.grid.new_node(current.x, current.y);
			switch (i)
			{
				case 0:
					new_neighbor.x += -1;
				case 1:
					new_neighbor.x += 1;
				case 2:
					new_neighbor.y += -1;
				case 3:
					new_neighbor.y += 1;
			}

			new_neighbor.distance = current.distance + 1;

			var tile:Int = state.grid.getTile(Math.floor(new_neighbor.x), Math.floor(new_neighbor.y));
			var tile_team:Int = state.grid.getTileTeam(new_neighbor.x, new_neighbor.y);

			var VALID_TEAM:Bool = tile_team == team || tile_team == 0;

			if (tile >= 0 && tile < 1 && VALID_TEAM)
			{
				neighbors.push(new_neighbor);
			}
		}

		return neighbors;
	}

	function set_contains_node(set:Array<SearchNode>, node:SearchNode):Bool
	{
		for (s in set)
		{
			if (s.x == node.x && s.y == node.y)
				return true;
		}
		return false;
	}

	/**manhatten heuristic**/
	function h(start:FlxPoint, node:FlxPoint):Float
	{
		return Utils.getDistance(start, node);
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
				teleport(CURSOR_POSITION.x, CURSOR_POSITION.y);
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
			u_id: u_id
		};
	}
}
