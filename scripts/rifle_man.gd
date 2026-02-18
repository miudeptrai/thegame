extends Area2D

@onready var sprite: Sprite2D = $Sprite;
@onready var map: Node2D = get_parent();
@onready var move_skill: Area2D = map.get_node("Move");

@export var stats: Stats;

const SHOT_VFX: PackedScene = preload("uid://covenruuqmtv4");

const TEXTURE_WIDTH: int = 64;
const TEXTURE_HEIGHT: int = 64;

signal name_tag(name_s: String, healthp: float, moralp:float);
signal no_name_tag;

var direction: Vector2;
var rotating: bool = false;
var skill_in_use: String;
var target: Area2D;

func _ready() -> void:
	add_to_group("Troops");

func _process(delta: float) -> void:
	if (rotating):
		sprite.rotation = lerp_angle(
			sprite.rotation,
			direction.angle(),
			stats.rotate_speed * delta
		);
		
		#Stop rotate/ firing
		if (abs(sprite.rotation - direction.angle()) < 0.01):
			rotating = false;
			if (skill_in_use == ""): return; #Move logic here
			
			var curr_skill: Area2D = map.get_node(skill_in_use);
			
			#Stop the range indicator
			curr_skill.deselect();
			
			# Firing
			var dir: Vector2 = Vector2.RIGHT.rotated(sprite.rotation);
			var bullet: Sprite2D;
			if (map.bullet_avail.size() == 0):
				bullet = SHOT_VFX.instantiate();
			else: bullet = map.bullet_avail.pop_back();
			map.add_child(bullet);
			bullet.global_rotation = dir.angle();
			bullet.global_position = sprite.global_position\
			 						 + dir * stats.bullet_offset[skill_in_use];
			#print(bullet.global_position);
			bullet.show();
			bullet.shot();
			#Calculate dmg and health
			var dmg: float = (stats.curr_power + curr_skill.stats.attack) * stats.moral;
			dmg /= target.stats.curr_defense;
			dmg += randf_range(0.0, 5.0);
			target.stats.health -= dmg;
			target.stats.moral -= dmg / target.stats.health;
			target.get_node("Dmg Tag").shot(dmg);
			print(target.stats.health);
			
			var tween: Tween = create_tween();
			#Recoil
			tween.tween_property(sprite, 
								 "position", 
								 -dir * stats.bullet_offset[skill_in_use], 
								 0.4)\
				.as_relative()\
				.set_trans(Tween.TRANS_QUAD)\
				.set_ease(Tween.EASE_OUT);
			#Get back
			tween.tween_property(sprite, 
								 "position", 
								 dir * stats.bullet_offset[skill_in_use], 
								 0.4)\
				.as_relative()\
				.set_trans(Tween.TRANS_QUAD)\
				.set_ease(Tween.EASE_OUT);

func _input_event(viewport: Viewport, event: InputEvent, shape_idx: int) -> void:
	if (event is InputEventMouseButton and event.pressed):
		if (event.button_index == MOUSE_BUTTON_LEFT):
			#print("Clicked: ", self);
			#Toggle selection
			
			var select_tile: Sprite2D = map.get_node("Select Tile");
			if (map.mouse_focused and move_skill.owner_of_action != self): return;
			
			#Move select tile
			if (not select_tile.visible):
				select_tile.show();
			elif (select_tile.global_position == global_position):
				select_tile.hide();
			select_tile.global_position = global_position;
			
			#Skills
			for skill_name in stats.skills:
				var skill = map.get_node(skill_name);
				if (not skill.visible):
					map.active_skills.append(skill);
					skill.show();
				elif (skill.owner_of_action == self):
					map.active_skills.pop_front();
					skill.hide();
				skill.deselect();
				skill.owner_of_action = self;
			
			#Move skill
			if (not move_skill.visible):
				map.active_skills.append(move_skill);
				move_skill.show();
			elif (move_skill.owner_of_action == self):
				map.active_skills.pop_front();
				move_skill.hide();
			move_skill.deselect();
			move_skill.owner_of_action = self;

func _on_mouse_entered() -> void:
	name_tag.emit("Rifle Man", stats.health / stats.max_health,
				  stats.moral / stats.curr_max_moral);
	#print("Nametag required");

func _on_mouse_exited() -> void:
	no_name_tag.emit();
	
	
	
	
	
