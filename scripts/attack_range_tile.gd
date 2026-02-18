extends Area2D

var owner_of_action;

func _input_event(viewport: Viewport, event: InputEvent, shape_idx: int) -> void:
	if (event is InputEventMouseButton and event.pressed):
		if (event.button_index == MOUSE_BUTTON_LEFT):
			var target = get_parent().get_object_at_point(global_position);
			if (target == null):
				return;
			
			#Prepare var for rotate in troop's _process
			var sprite_a = owner_of_action.get_node("Sprite");
			var sprite_b = target.get_node("Sprite");
			var direction = sprite_b.global_position - sprite_a.global_position;
			owner_of_action.direction = direction;
			owner_of_action.rotating = true;
			owner_of_action.firing_mode = 1; #Fix this
