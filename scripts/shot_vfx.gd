extends Sprite2D

func shot():
	var tween = create_tween();
	show();
	tween.tween_property(self, "modulate:a", 0.0, 0.5);
	tween.tween_callback(hide);
	modulate.a = 1.0;
