extends Area2D

@onready var map: Node2D = get_parent();

var owner_of_action: Area2D;

func _input_event(viewport: Viewport, event: InputEvent, shape_idx: int) -> void:
	if (event is InputEventMouseButton and event.pressed):
		if (event.button_index == MOUSE_BUTTON_LEFT):
			#Pathfind
			#print("Troop pos:", owner_of_action.global_position);
			#print("Tile pos:", global_position);
			var target: Area2D = map.get_object_at_point(global_position);
			target.captured = true;
			target.faction = owner_of_action.faction;
			print("Captured");
			
			#Deselect
			map.get_node("Move").deselect(true);
