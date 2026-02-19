extends Area2D

@onready var pivot: Node2D = $Pivot;
@onready var map: Node2D = get_parent();
@onready var move_skill: Area2D = map.get_node("Move");

@export var stats: Stats;

const SHOT_VFX: PackedScene = preload("uid://covenruuqmtv4");

const TEXTURE_WIDTH: int = 64;
const TEXTURE_HEIGHT: int = 64;

signal name_tag(name_s: String, healthp: float, moralp:float);
signal no_name_tag;

func _ready() -> void:
	add_to_group("Troops");

func fire_process(target: Area2D, skill_name: String) -> void:
	var skill: Area2D = map.get_node(skill_name);
	
	await rotate_to(target.global_position + Vector2(TEXTURE_WIDTH, TEXTURE_HEIGHT) / 2);
	
	fire(target, skill);
	
	await recoil(skill_name);

func follow_path(path: PackedVector2Array) -> void:
	for i in range(1, path.size()):
		#Get destination
		var next_point: Vector2 = path[i];
		
		#Rotate
		await rotate_to(next_point + Vector2(TEXTURE_WIDTH, TEXTURE_HEIGHT) / 2);
		
		#Move
		await move_to(next_point);

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

func recoil(skill_name: String) -> void:
	var dir: Vector2 = Vector2.RIGHT.rotated(pivot.rotation);
	var tween: Tween = create_tween();
	#Recoil
	tween.tween_property(
		pivot, 
		"position", 
		-dir * stats.recoil_offset[skill_name], 
		0.4)\
	.as_relative()\
	.set_trans(Tween.TRANS_QUAD)\
	.set_ease(Tween.EASE_OUT);
	#Get back
	tween.tween_property(
		pivot, 
		"position", 
		dir * stats.recoil_offset[skill_name], 
		0.4)\
	.as_relative()\
	.set_trans(Tween.TRANS_QUAD)\
	.set_ease(Tween.EASE_OUT);
	
	await tween.finished;

func fire(target: Area2D, skill: Area2D) -> void:
	#Calculate vars
	var dmg: float = stats.calculate_damage(skill.stats, target);
	
	var moral_decrease: float = dmg;
	if (target.stats.health != 0): moral_decrease /= target.stats.health;
	
	#Edit stats
	target.stats.health -= dmg;
	target.stats.moral -= moral_decrease;
	#Dmg indicator
	target.get_node("Indicator").shot(dmg);
	
	#Bullet tracer
	$Pivot/ShotVfx.shot();

func rotate_to(point: Vector2) -> void:
	var direction: Vector2 = point + Vector2(TEXTURE_WIDTH, TEXTURE_HEIGHT) / 2;
	direction += pivot.global_position;
	direction.normalized();
	
	var tween: Tween = create_tween();
	tween.tween_property(
		$Pivot,
		"rotation",
		direction.angle(),
		stats.rotate_speed
	);
	
	await tween.finished;

func move_to(point: Vector2) -> void:
	var tween: Tween = create_tween();
	tween.tween_property(
		self,
		"global_position",
		point,
		stats.speed / 2
	);
	
	await tween.finished;

func _on_mouse_entered() -> void:
	name_tag.emit("Rifle Man", stats.health / stats.max_health,
				  stats.moral / stats.curr_max_moral);
	#print("Nametag required");

func _on_mouse_exited() -> void:
	no_name_tag.emit();
	
	
	
	
	
