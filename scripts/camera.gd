extends CharacterBody2D

@export var speed: float = 600.0;

func _process(delta: float) -> void:
	var dir: Vector2 = Input.get_vector("move_left", "move_right", "move_up", "move_down");
	
	velocity = dir * speed;
	move_and_slide();
