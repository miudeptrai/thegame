extends Area2D

@onready var sprite: Sprite2D = $Sprite;
@onready var map: Node2D = get_parent();
@onready var move_skill: Area2D = map.get_node("Move");
@onready var rifle_attack: Area2D = map.get_node("Rifle Attack");
@onready var skill_refs: Array = [
	rifle_attack, move_skill
];

@export var stats: Stats;

const SHOT_VFX: PackedScene = preload("uid://covenruuqmtv4");

const TEXTURE_WIDTH: int = 64;
const TEXTURE_HEIGHT: int = 64;

const BULLET_OFFSET: int = 30;
const RECOIL_OFFSET: int = 1;

signal name_tag(name_s: String, healthp: float, moralp:float);
signal no_name_tag;

var direction: Vector2;
var rotating: bool = false;
var firing_mode: int = 0; #None is 0, increase by each attack this troop has
#Determined by the order which the skills are put in to active_skills, 1-based index
#Rifle man only has 1 attack skill

#Stats
const MAX_HEALTH: float = 100.0;
const MAX_MORAL: float = 100.0;

@export var speed: int = 2;

var health: float = MAX_HEALTH;
var moral: float = MAX_MORAL;

var rotate_speed: float = 5.0;

func _ready() -> void:
	add_to_group("Troops");

func _process(delta: float) -> void:
	if (rotating):
		sprite.rotation = lerp_angle(
			sprite.rotation,
			direction.angle(),
			rotate_speed * delta
		);
		
		#Stop rotate/ firing
		if (abs(sprite.rotation - direction.angle()) < 0.01):
			rotating = false;
			if (firing_mode == 0): return;
			
			#Stop the range indicator
			skill_refs[firing_mode - 1].deselect();
			
			# Firing
			var dir: Vector2 = Vector2.RIGHT.rotated(sprite.rotation);
			var bullet: Sprite2D;
			if (map.bullet_avail.size() == 0):
				bullet = SHOT_VFX.instantiate();
			else: bullet = map.bullet_avail.pop_back();
			map.add_child(bullet);
			bullet.global_rotation = dir.angle();
			bullet.global_position = sprite.global_position + dir * BULLET_OFFSET;
			#print(bullet.global_position);
			bullet.show();
			bullet.shot();
			
			var tween: Tween = create_tween();
			tween.tween_property(sprite, "position", -dir * BULLET_OFFSET, 0.4)\
				.as_relative()\
				.set_trans(Tween.TRANS_QUAD)\
				.set_ease(Tween.EASE_OUT);
			tween.tween_property(sprite, "position", dir * BULLET_OFFSET, 0.4)\
				.as_relative()\
				.set_trans(Tween.TRANS_QUAD)\
				.set_ease(Tween.EASE_OUT);

func _input_event(viewport: Viewport, event: InputEvent, shape_idx: int) -> void:
	if (event is InputEventMouseButton and event.pressed):
		if (event.button_index == MOUSE_BUTTON_LEFT):
			print("Clicked: ", self);
			#Toggle selection
			
			var map: Node2D = get_parent();
			
			var select_tile: Sprite2D = map.get_node("Select Tile");
			if (map.mouse_focused and move_skill.owner_of_action != self): return;
			
			#Move select tile
			if (not select_tile.visible):
				select_tile.show();
			elif (select_tile.global_position == global_position):
				select_tile.hide();
			select_tile.global_position = global_position;
			
			#Skills
			#"Multiple troops of same type" problem taken care of
			if (not rifle_attack.visible):
				map.active_skills.append(rifle_attack);
				rifle_attack.show();
			elif (rifle_attack.owner_of_action == self):
				map.active_skills.pop_front();
				rifle_attack.hide();
			rifle_attack.deselect();
			rifle_attack.owner_of_action = self;
			rifle_attack.id = 1;
			
			if (not move_skill.visible):
				map.active_skills.append(move_skill);
				move_skill.show();
			elif (move_skill.owner_of_action == self):
				map.active_skills.pop_front();
				move_skill.hide();
			move_skill.deselect();
			move_skill.owner_of_action = self;

func _on_mouse_entered() -> void:
	name_tag.emit("Rifle Man", health / MAX_HEALTH, moral / MAX_MORAL);
	#print("Nametag required");

func _on_mouse_exited() -> void:
	no_name_tag.emit();
	
	
	
	
	
