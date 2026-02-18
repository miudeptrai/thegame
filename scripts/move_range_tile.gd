extends Area2D

@onready var map: Node2D = get_parent();

var owner_of_action: Area2D;

func _input_event(viewport: Viewport, event: InputEvent, shape_idx: int) -> void:
	if (event is InputEventMouseButton and event.pressed):
		if (event.button_index == MOUSE_BUTTON_LEFT):
			#Pathfind
			print("Troop pos:", owner_of_action.global_position);
			print("Tile pos:", global_position);
			var start_id: int = map.astar.get_closest_point(owner_of_action.global_position);
			var end_id: int = map.astar.get_closest_point(global_position);
			print("Start id:", start_id);
			print("End id:", end_id);
			var path: PackedVector2Array = map.astar.get_point_path(start_id, end_id);
			
			map.astar.set_point_disabled(start_id, false);
			map.astar.set_point_disabled(end_id, true);
			
			#Signal to move
			owner_of_action.start_move_sequence = true;
			owner_of_action.path = path;
			#print(owner_of_action.stats.display_name);
			
			map.get_node("Move").deselect();
			map.mouse_focused = false;
			map.get_node("Select Tile").global_position = global_position;
