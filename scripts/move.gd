extends Area2D

const MOVE_RANGE_TILE = preload("uid://boklfdbjlhr1q");

var owner_of_action;
var active_move_range_tile: Array = [];
var pressed: bool = false;

func _input_event(viewport: Viewport, event: InputEvent, shape_idx: int) -> void:
	if (event is InputEventMouseButton and event.pressed):
		if (event.button_index == MOUSE_BUTTON_LEFT):
			if (pressed): return;
			deselect_all_but_self();
			
			#print("Clicked");
			#BFS
			
			#clock-wise
			var neighbours = [
				Vector2i(0, -1),
				Vector2i(1, 0),
				Vector2i(0, 1),
				Vector2i(-1, 0)
			]
			var visited: Dictionary = {};
			var queue = [];
			queue.append({
				"pos": Vector2i(0, 0),
				"dist": 0
			});
			
			while (not queue.is_empty()):
				var curr = queue.pop_front();
				
				if (visited.has(curr["pos"])):
					continue;
				
				visited[curr["pos"]] = true;
				if (curr["dist"] > owner_of_action.stats.speed): continue;
				
				load_range(curr["pos"]);
				
				for i in neighbours:
					#print("Adding new neighbours");
					queue.append({
						"pos": curr["pos"] + i,
						"dist": curr["dist"] + 1
					});
			
			pressed = true;

func load_range(pos: Vector2i) -> void:
	#Setting up attack range tile and deploying it
	if (pos == Vector2i(0, 0)): return;
	
	var curr;
	var avail_arr = get_parent().move_range_avail;
	if (not avail_arr.is_empty()):
		curr = avail_arr.pop_back();
	else:
		curr = MOVE_RANGE_TILE.instantiate();
		get_parent().add_child(curr);
	active_move_range_tile.append(curr);
	
	var new_pos = Vector2(
		owner_of_action.global_position.x + pos.x * owner_of_action.TEXTURE_WIDTH,
		owner_of_action.global_position.y + pos.y * owner_of_action.TEXTURE_HEIGHT
	);
		
	curr.global_position = new_pos;
	curr.show();
	
	#print("Loaded successfully");

func deselect() -> void:
	pressed = false;
	#Moving all borrowed tiles to its owner and hiding it
	var avail_arr = get_parent().move_range_avail;
	for i in range(active_move_range_tile.size()):
		avail_arr.append(active_move_range_tile.pop_back());
		avail_arr[avail_arr.size() - 1].hide();

func deselect_all_but_self() -> void:
	for i in get_parent().active_skills:
		if (i == self): continue;
		
		i.deselect();
		
		
		
