package actors;

import flixel.tile.FlxBaseTilemap.FlxTilemapDiagonalPolicy;

class Unit extends Actor
{
	public var SELECTED:Bool = false;

	var speed:Int = 0;

	var movement_options:Array<FlxPoint> = new Array<FlxPoint>();

	public function new(?X:Float = 0, ?Y:Float = 0)
	{
		super(X, Y);

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

	function bfs(state:GridState, start:FlxPoint, goal:FlxPoint, never_valid:Bool = false):Array<FlxPoint>
	{
		var open_set:Array<FlxPoint> = [start];
		var visited:Array<FlxPoint> = [];
		var current:FlxPoint;

		while (open_set.length > 0)
		{
			current = open_set.pop();
			visited.push(current);
			for (neighbor in get_neighbors(visited, current, state))
			{
				if (!set_contains_point(visited, neighbor) && h(start, neighbor) <= speed)
					open_set.push(neighbor);
			}
		}

		return visited;
	}

	function a_star(state:GridState, start:FlxPoint, goal:FlxPoint, never_valid:Bool = false):Array<FlxPoint>
	{
		var open_set:Array<FlxPoint> = [start];
		var came_from:Map<FlxPoint, FlxPoint> = new Map<FlxPoint, FlxPoint>();
		var visited:Array<FlxPoint> = [];

		var gScore:Map<FlxPoint, Float> = new Map<FlxPoint, Float>();
		gScore[start] = 0;

		var fScore:Map<FlxPoint, Float> = new Map<FlxPoint, Float>();
		fScore[start] = h(start, start);

		while (open_set.length > 0)
		{
			var current:FlxPoint = get_lowest_f(open_set, fScore);

			visited.push(current);

			if (!never_valid && start.x == goal.x && start.y == goal.y)
				return reconstruct_path(came_from, current);

			open_set.remove(current);

			for (neighbor in get_neighbors(open_set, current, state))
			{
				trace(neighbor);

				var tentative_gscore:Float = gScore[current] + Utils.getDistance(current, neighbor);

				// inits for empty
				gScore[neighbor] = gScore[neighbor] != null ? gScore[neighbor] : tentative_gscore;
				fScore[neighbor] = fScore[neighbor] != null ? fScore[neighbor] : h(start, neighbor);
				came_from[neighbor] = came_from[neighbor] != null ? came_from[neighbor] : current;

				trace(tentative_gscore, gScore[neighbor]);

				if (set_contains_point(open_set, neighbor))
				{
					if (tentative_gscore < gScore[neighbor])
					{
						came_from[neighbor] = current;
						gScore[neighbor] = tentative_gscore;
						fScore[neighbor] = gScore[neighbor] + h(start, neighbor);
					}
				}
				else
				{
					open_set.push(neighbor);
				}
			}
		}

		return never_valid ? open_set : visited;
	}

	function get_neighbors(set:Array<FlxPoint>, current:FlxPoint, state:GridState):Array<FlxPoint>
	{
		var neighbors:Array<FlxPoint> = [];

		for (i in 0...4)
		{
			var new_neighbor:FlxPoint = new FlxPoint(current.x, current.y);
			switch (i)
			{
				case 0:
					new_neighbor.add(-1, 0);
				case 1:
					new_neighbor.add(1, 0);
				case 2:
					new_neighbor.add(0, -1);
				case 3:
					new_neighbor.add(0, 1);
			}
			var tile:Int = state.grid.getTile(Math.floor(new_neighbor.x), Math.floor(new_neighbor.y));
			if (tile <= 999 && tile >= 0)
			{
				// TODO: Set to actual collision
				neighbors.push(new_neighbor);
			}
		}

		return neighbors;
	}

	function set_contains_point(set:Array<FlxPoint>, point:FlxPoint):Bool
	{
		// trace(set, point);
		for (p in set)
		{
			if (p.x == point.x && p.y == point.y)
				return true;
		}
		return false;
	}

	/**dumb heuristic**/
	function h(start:FlxPoint, node:FlxPoint):Float
	{
		return Utils.getDistance(start, node);
	}

	function reconstruct_path(came_from:Map<FlxPoint, FlxPoint>, current:FlxPoint)
	{
		// TODO: Implement (lol)
		return [];
	}

	function get_lowest_f(open_set:Array<FlxPoint>, fScore:Map<FlxPoint, Float>):FlxPoint
	{
		var minimum_score:Float = fScore.get(open_set[0]);
		var selected_f:FlxPoint = open_set[0];

		for (f in open_set)
		{
			if (minimum_score < fScore.get(f))
			{
				minimum_score = fScore.get(f);
				selected_f = f;
			}
		}

		return selected_f;
	}

	function teleport(X:Float, Y:Float)
	{
		tile_position.x = Math.floor(X);
		tile_position.y = Math.floor(Y);
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
}
