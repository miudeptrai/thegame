extends Area2D

@onready var pivot: Node2D = $Pivot;
@onready var map: Node2D = get_parent();
@onready var move_skill: Area2D = map.get_node("Move");

@export var stats: Stats;
@export var faction: Factions.FactionsType = Factions.FactionsType.DEFAULT;

const SHOT_VFX: PackedScene = preload("uid://covenruuqmtv4");

const TEXTURE_WIDTH: int = 64;
const TEXTURE_HEIGHT: int = 64;

signal name_tag(name_s: String, healthp: float, moralp:float);
signal no_name_tag;

func _ready() -> void:
	add_to_group("Troops");
	stats.health_depleted.connect(_on_health_depleted);
	stats.moral_depleted.connect(_on_moral_depleted);

func fire_process(target: Area2D, skill_name: String) -> void:
	var skill: Area2D = map.get_node(skill_name);
	
	await rotate_to(target.global_position);
	
	fire(target, skill);
	
	await recoil(skill_name);
	
	map.mouse_focused = false;

func follow_path(path: PackedVector2Array) -> void:
	#var id: int = map.astar.get_closest_point(global_position);
	#var connections: Array = map.astar.get_point_connections(id);
	#print(connections);
	
	for i in range(1, path.size()):
		#Get destination
		var next_point: Vector2 = path[i];
		
		#Rotate
		await rotate_to(next_point);
		
		#Move
		await move_to(next_point);
	
	map.mouse_focused = false;

func _input_event(viewport: Viewport, event: InputEvent, shape_idx: int) -> void:
	if (event is InputEventMouseButton and event.pressed):
		if (event.button_index == MOUSE_BUTTON_LEFT):
			#print("Clicked: ", self);
			#Toggle selection
			
			var select_tile: Sprite2D = map.get_node("Select Tile");
			# If mouse is focused on other troops then
			#print(map.mouse_focused);
			if (map.mouse_focused and move_skill.owner_of_action != self):
				return;
			
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
				skill.deselect(false);
				skill.owner_of_action = self;
			
			#Move skill
			if (not move_skill.visible):
				map.active_skills.append(move_skill);
				move_skill.show();
			elif (move_skill.owner_of_action == self):
				map.active_skills.pop_front();
				move_skill.hide();
			move_skill.deselect(false);
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
	#Edit stats
	var dmg = stats.calculate_damage(skill.stats, target);
	target.stats.health -= dmg;
	target.stats.moral -= target.stats.calculate_moral_decrease(dmg);
	#Dmg indicator
	target.get_node("Dmg Indicator").display_text("%d" % dmg);
	
	#Bullet tracer
	$Pivot/ShotVfx.shot();

func rotate_to(point: Vector2) -> void:
	var direction: Vector2 = point - global_position;
	direction = direction.normalized();
	
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
		0.3
	)\
	.set_trans(Tween.TRANS_QUAD)\
	.set_ease(Tween.EASE_OUT);
	
	await tween.finished;

func _on_mouse_entered() -> void:
	name_tag.emit("Rifle Man", stats.health / stats.max_health,
				  stats.moral / stats.curr_max_moral);
	#print("Nametag required");

func _on_mouse_exited() -> void:
	no_name_tag.emit();

func _on_health_depleted():
	print(self, " died");
	$"State Indicator".display_text("Oops☠");

func _on_moral_depleted():
	print(self, " surrendered");
	$"State Indicator".display_text("Surrendered🏳", "#ffffff");
	
	
	
	
	
