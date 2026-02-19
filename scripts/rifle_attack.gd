extends Area2D

const ATTACK_RANGE_TILE: PackedScene = preload("uid://dhi2m7yl010fv");

@onready var map = get_parent();

@export var stats: SkillStats;

var owner_of_action: Area2D;
var active_attack_range_tile: Array = [];
var pressed: bool = false;

func _ready() -> void:
	add_to_group("Skills");

func _input_event(viewport: Viewport, event: InputEvent, shape_idx: int) -> void:
	if (event is InputEventMouseButton and event.pressed):
		if (event.button_index == MOUSE_BUTTON_LEFT):
			if (pressed): return;
			deselect_all_but_self();
			
			#print("Clicked");
			#BFS for range
			
			#clock-wise
			var neighbours: Array = [
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
				if (curr["dist"] > stats.attack_range): continue;
				
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
	
	var curr: Area2D;
	var avail_arr: Array = map.attack_range_avail;
	if (not avail_arr.is_empty()):
		curr = avail_arr.pop_back();
	else:
		curr = ATTACK_RANGE_TILE.instantiate();
		map.add_child(curr);
	curr.owner_of_action = owner_of_action;
	curr.skill = self;
	active_attack_range_tile.append(curr);
	
	var new_pos = Vector2(
		owner_of_action.global_position.x + pos.x * owner_of_action.TEXTURE_WIDTH,
		owner_of_action.global_position.y + pos.y * owner_of_action.TEXTURE_HEIGHT
	);
		
	curr.global_position = new_pos;
	curr.show();
	
	#print("Loaded successfully");

func deselect() -> void:
	pressed = false;
	map.mouse_focused = false;
	var avail_arr: Array = map.attack_range_avail;
	for i in range(active_attack_range_tile.size()):
		avail_arr.append(active_attack_range_tile.pop_back());
		avail_arr[avail_arr.size() - 1].hide();
	
func deselect_all_but_self() -> void:
	for i in map.active_skills:
		if (i == self): continue;
		
		i.deselect();
		
	
