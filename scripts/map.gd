extends Node2D

const TEXTURE_WIDTH: int = 64;
const TEXTURE_HEIGHT: int = 64;

const BIOME_TILE = preload("uid://wbo055sbx06x");
const RIFLE_MAN = preload("uid://b7a6788cu3t88");

var displayed_name_tag: bool = false;
var name_s: String;
var healthp: float;
var moralp: float;

var mouse_selected: bool = false;
var mouse_focused: bool = false;

var attack_range_avail: Array = [];
var move_range_avail: Array = [];
var active_skills: Array = [];
var bullet_avail: Array = [];

func _ready() -> void:
	load_default_map();
	
	var troop: Area2D = RIFLE_MAN.instantiate();
	add_child(troop);
	troop.global_position = Vector2(256, 256);
	troop = RIFLE_MAN.instantiate();
	add_child(troop);
	troop.global_position = Vector2(256, 192);
	#print(troop.is_in_group("Troops"));
	
	#remember to move these lines to Camera
	for child in get_children():
		if (child.is_in_group("Troops")):
			child.name_tag.connect(_on_name_tag);
			#print("Connected:", child.name_tag.is_connected(_on_name_tag));
			child.no_name_tag.connect(_on_no_name_tag);

func _process(delta: float) -> void:
	var mouse_pos: Vector2 = get_global_mouse_position();
	# Snap the mouse pos to grid and offset
	var snap_pos: Vector2 = Vector2(
		(floor(mouse_pos.x / TEXTURE_WIDTH) + 0.5) * TEXTURE_WIDTH,
		(floor(mouse_pos.y / TEXTURE_HEIGHT) + 0.5) * TEXTURE_HEIGHT
	);
	$MouseHover.global_position = snap_pos;
	#print(snap_pos);
	
	if (displayed_name_tag):
		display_name_tag(name_s, healthp, moralp);
	else: $"Name Tag".hide();

func load_default_map() -> void:
	for i in range(0, 10):
		for j in range(0, 15):
			var tile: Node2D = BIOME_TILE.instantiate();
			add_child(tile);
			tile.global_position = Vector2(
				j * tile.TEXTURE_WIDTH,
				i * tile.TEXTURE_HEIGHT
			);

func _on_name_tag(s, h, m):
	displayed_name_tag = true;
	
	name_s = s;
	healthp = h
	moralp = m;

func display_name_tag(s: String, h: float, m: float):
	var label: Label = $"Name Tag/Label";
	label.text = """ Name: %s
 Health: %.2f%%
 Moral: %.2f%%
""" % [s, h * 100.0, m * 100.0];  
	
	$"Name Tag".global_position = get_global_mouse_position();
	$"Name Tag".show();
	#print("Displayed");
	
func _on_no_name_tag():
	displayed_name_tag = false;
	
func get_object_at_point(point: Vector2):
	var space_state: PhysicsDirectSpaceState2D = get_world_2d().direct_space_state;

	var query: PhysicsPointQueryParameters2D = PhysicsPointQueryParameters2D.new();
	query.position = point;
	query.collide_with_areas = true;
	query.collide_with_bodies = true;

	var result: Array = space_state.intersect_point(query);

	for i in result:
		if (i.collider.is_in_group("Troops")): return i.collider;
	#print("Found nothing");
	return null;
