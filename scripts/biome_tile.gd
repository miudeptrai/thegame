extends Node2D

const TEXTURE_WIDTH: int = 64;
const TEXTURE_HEIGHT: int = 64;

enum Biomes {GRASS};

@export var current_biome: Biomes = Biomes.GRASS: # curr tile declaration
	set(value): # setter func
		current_biome = value;
		update_tile();

var biome_textures: Dictionary = {
	Biomes.GRASS: preload("res://asset/Biome_tiles/grass.png")
}

func update_tile() -> void:
	$Sprite2D.texture = biome_textures[current_biome];

func _ready() -> void:
	update_tile();
	
	# Offset the sprite for easier editing
	# Note that it moves diagonally downward to the left
	$Sprite2D.offset.x = TEXTURE_WIDTH / 2;
	$Sprite2D.offset.y = TEXTURE_HEIGHT / 2;
