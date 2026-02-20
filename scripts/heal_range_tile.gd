extends Area2D

@onready var map: Node2D = get_parent();

var owner_of_action: Area2D;
var skill: Area2D;

func _input_event(viewport: Viewport, event: InputEvent, shape_idx: int) -> void:
	if (event is InputEventMouseButton and event.pressed):
		if (event.button_index == MOUSE_BUTTON_LEFT):
			var target: Area2D = get_parent().get_object_at_point(
				global_position,
				true,
				true,
				owner_of_action.faction
			);
			if (target == null):
				return;
			#print(target, " at ", target.global_position);
			
			#Prepare to shoot
			owner_of_action.heal_process(target, skill.stats.source_name);
			
			#Clear
			map.get_node(skill.stats.source_name).deselect(true);
