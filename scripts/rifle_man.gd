extends Area2D

const SHOT_VFX = preload("uid://covenruuqmtv4")

const TEXTURE_WIDTH: int = 64;
const TEXTURE_HEIGHT: int = 64;

signal name_tag(name_s: String, healthp: float, moralp:float);
signal no_name_tag;

var direction;
var rotating: bool = false;
var firing_mode = 0; #None is 0, increase by each attack this troop has
#Determined by the order which the skills are put in to active_skills, 1-based index
#Rifle man only has 1 attack skill

#Stats
const MAX_HEALTH: float = 100.0;
const MAX_MORAL: float = 100.0;

@export var speed = 2;

var health = MAX_HEALTH;
var moral = MAX_MORAL;

var rotate_speed = 5;

func _ready() -> void:
	add_to_group("Troops");

func _process(delta: float) -> void:
	if (rotating):
		$Sprite.rotation = lerp_angle(
			$Sprite.rotation,
			direction.angle(),
			rotate_speed * delta
		);
		
		#Stop rotate
		if (abs($Sprite.rotation - direction.angle()) < 0.01):
			rotating = false;
			if (firing_mode == 0): return;
			
			var dir = Vector2.RIGHT.rotated($Sprite.rotation);
			var bullet;
			if (get_parent().bullet_avail.size() == 0):
				bullet = SHOT_VFX.instantiate();
			else: bullet = get_parent().bullet_avail.pop_back();
			get_parent().add_child(bullet);
			var bullet_offset = 30;
			bullet.global_rotation = dir.angle();
			bullet.global_position = $Sprite.global_position + dir * bullet_offset;
			print(bullet.global_position);
			bullet.show();
			bullet.shot();

func _input_event(viewport: Viewport, event: InputEvent, shape_idx: int) -> void:
	if (event is InputEventMouseButton and event.pressed):
		if (event.button_index == MOUSE_BUTTON_LEFT):
			print("Clicked: ", self);
			#Toggle selection
			
			#Move select tile
			var select_tile = get_parent().get_node("Select Tile");
			if (not select_tile.visible):
				select_tile.show();
			elif (select_tile.global_position == global_position):
				select_tile.hide();
			select_tile.global_position = global_position;
			
			#Skills
			#Multiple troops of same type problem taken care of
			var rifle_attack = get_parent().get_node("Rifle Attack");
			if (not rifle_attack.visible):
				get_parent().active_skills.append(rifle_attack);
				rifle_attack.owner_of_action = self;
				rifle_attack.show();
			elif (rifle_attack.owner_of_action == self):
				rifle_attack.deselect();
				get_parent().active_skills.pop_front();
				rifle_attack.hide();
			rifle_attack.deselect();
			rifle_attack.owner_of_action = self;
			
			var move_skill = get_parent().get_node("Move");
			if (not move_skill.visible):
				get_parent().active_skills.append(move_skill);
				move_skill.owner_of_action = self;
				move_skill.show();
			elif (move_skill.owner_of_action == self):
				move_skill.deselect();
				get_parent().active_skills.pop_front();
				move_skill.hide();
			move_skill.deselect();
			move_skill.owner_of_action = self;

func _on_mouse_entered() -> void:
	name_tag.emit("Rifle Man", health / MAX_HEALTH, moral / MAX_MORAL);
	#print("Nametag required");

func _on_mouse_exited() -> void:
	no_name_tag.emit();
	
	
	
	
	
