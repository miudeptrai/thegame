extends Label

@onready var troop: Area2D = get_parent();

func shot(dmg: float) -> void:
	text = "%d" % int(dmg);
	position = Vector2(
		randi_range(0, troop.TEXTURE_WIDTH),
		randi_range(0, troop.TEXTURE_HEIGHT)
	);
	scale = Vector2(0.1, 0.1);
	show();
	
	var tween: Tween = create_tween();
	#Appearing
	tween.tween_property(self, "scale", Vector2(2.0, 2.0), 0.3);
	#Fade out
	tween.tween_property(self, "modulate:a", 1.0, 0.5);
	tween.tween_callback(hide);
	modulate.a = 0.0;
