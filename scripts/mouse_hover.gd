extends Sprite2D

const TEXTURE_WIDTH: int = 64;
const TEXTURE_HEIGHT: int = 64;

func _ready() -> void:
	offset = Vector2(TEXTURE_WIDTH / 2, TEXTURE_HEIGHT / 2);
