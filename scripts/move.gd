extends Area2D

const MOVE_RANGE_TILE: PackedScene = preload("uid://boklfdbjlhr1q");
const CAPTURE_TILE = preload("uid://cdq4bty6pmmxm");

@onready var map: Node2D = get_parent();

var owner_of_action: Area2D;
var active_move_range_tile: Array = [];
var active_capture_tile: Array = [];
var pressed: bool = false;

func _ready() -> void:
	add_to_group("Skills");

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
			var queue: Array = [];
			queue.append({
				"pos": Vector2i(0, 0),
				"dist": 0
			});
			
			while (not queue.is_empty()):
				var curr: Dictionary = queue.pop_front();
				
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
			map.mouse_focused = true;

func load_range(pos: Vector2i) -> void:
	#Setting up attack range tile and deploying it
	#Preventing the troop pos
	if (pos == Vector2i(0, 0)): return;
	
	#Getting new pos and obj in that pos
	var new_pos = Vector2(
		owner_of_action.global_position.x + pos.x * owner_of_action.TEXTURE_WIDTH,
		owner_of_action.global_position.y + pos.y * owner_of_action.TEXTURE_HEIGHT
	);
	var obj: Area2D = map.get_object_at_point(new_pos);
	
	var curr: Area2D;
	var avail_move_arr: Array = map.move_range_avail;
	var avail_capture_arr: Array = map.capture_tile_avail;
	if (obj == null or obj.stats.morale != 0):
		if (not avail_move_arr.is_empty()):
			curr = avail_move_arr.pop_back();
		else:
			curr = MOVE_RANGE_TILE.instantiate();
			map.add_child(curr);
		active_move_range_tile.append(curr);
	else:
		if (not avail_capture_arr.is_empty()):
			curr = avail_capture_arr.pop_back();
		else:
			curr = CAPTURE_TILE.instantiate();
			map.add_child(curr);
		active_capture_tile.append(curr);
	curr.owner_of_action = owner_of_action;
	
	curr.global_position = new_pos;
	#print(map.astar.get_point_ids());
	#Check if there're any units
	if (obj == null):
		var id: int = map.astar.get_closest_point(new_pos, true);
		#print("Turned on point", id);
		map.astar.set_point_disabled(id, false);
	
	curr.show();
	
	#print("Loaded successfully");

func deselect(is_action: bool) -> void:
	pressed = false;
	if (not is_action):
		map.mouse_focused = false;
	#Moving all borrowed tiles to its owner and hiding it
	var avail_arr: Array = map.move_range_avail;
	for i in range(active_move_range_tile.size()):
		avail_arr.append(active_move_range_tile.pop_back());
		avail_arr[avail_arr.size() - 1].hide();
		var id: int = map.astar.get_closest_point(avail_arr[avail_arr.size() - 1].\
												  global_position, true);
		#print("Turned off point", id);
		map.astar.set_point_disabled(id, true);
	
	avail_arr = map.capture_tile_avail;
	for i in range(active_capture_tile.size()):
		avail_arr.append(active_capture_tile.pop_back());
		avail_arr[avail_arr.size() - 1].hide();
		var id: int = map.astar.get_closest_point(avail_arr[avail_arr.size() - 1].\
												  global_position, true);
		#print("Turned off point", id);
		map.astar.set_point_disabled(id, true);

func deselect_all_but_self() -> void:
	for i in map.active_skills:
		if (i == self): continue;
		
		i.deselect(false);
		
		
		
