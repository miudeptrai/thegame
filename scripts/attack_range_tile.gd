extends Area2D

var owner_of_action: Area2D;
var skill: Area2D;

func _input_event(viewport: Viewport, event: InputEvent, shape_idx: int) -> void:
	if (event is InputEventMouseButton and event.pressed):
		if (event.button_index == MOUSE_BUTTON_LEFT):
			var target: Area2D = get_parent().get_object_at_point(global_position);
			if (target == null):
				return;
			
			#Prepare var for rotate in troop's _process
			var sprite_a: Sprite2D = owner_of_action.get_node("Sprite");
			var sprite_b: Sprite2D = target.get_node("Sprite");
			var direction: Vector2 = sprite_b.global_position - sprite_a.global_position;
			owner_of_action.direction = direction;
			owner_of_action.firing = true;
			owner_of_action.skill_in_use = skill.stats.source_name;
			owner_of_action.target = target;
