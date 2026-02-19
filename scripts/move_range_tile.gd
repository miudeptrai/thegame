extends Area2D

@onready var map: Node2D = get_parent();

var owner_of_action: Area2D;

func _input_event(viewport: Viewport, event: InputEvent, shape_idx: int) -> void:
	if (event is InputEventMouseButton and event.pressed):
		if (event.button_index == MOUSE_BUTTON_LEFT):
			#Pathfind
			#print("Troop pos:", owner_of_action.global_position);
			#print("Tile pos:", global_position);
			var start_id: int = map.astar.get_closest_point(
				owner_of_action.global_position, 
				true
			);
			#Turn off for pathfinding
			map.astar.set_point_disabled(start_id, false);
			
			var end_id: int = map.astar.get_closest_point(global_position, true);
			
			var path: PackedVector2Array = map.astar.get_point_path(start_id, end_id);
			if (path.is_empty()):
				print("Invalid path");
				return;
			print("Path: ", path);
			
			#Reset obstacle
			map.astar.set_point_disabled(end_id, true);
			
			#Move
			owner_of_action.follow_path(path);
			
			#Move select tile
			map.get_node("Move").deselect(true);
			map.get_node("Select Tile").global_position = global_position;
