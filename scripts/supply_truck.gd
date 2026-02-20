extends Area2D

@onready var pivot: Node2D = $Pivot;
@onready var map: Node2D = get_parent();
@onready var move_skill: Area2D = map.get_node("Move");

@export var stats: Stats;
@export var faction: Factions.FactionsType = Factions.FactionsType.DEFAULT:
	set = _on_faction_change;

var captured: bool = false;
var clickable: bool = true;

const TEXTURE_WIDTH: int = 64;
const TEXTURE_HEIGHT: int = 64;

signal name_tag(name_s: String, healthp: float, moralep:float);
signal no_name_tag;

func _ready() -> void:
	add_to_group("Troops");
	stats.health_depleted.connect(_on_health_depleted);
	stats.morale_depleted.connect(_on_morale_depleted);

func heal_process(target: Area2D, skill_name: String) -> void:
	var skill: Area2D = map.get_node(skill_name);
	
	await rotate_to(target.global_position);
	
	heal(target, skill);
	
	map.mouse_focused = false;

func follow_path(path: PackedVector2Array) -> void:
	#var id: int = map.astar.get_closest_point(global_position);
	#var connections: Array = map.astar.get_point_connections(id);
	#print(connections);
	clickable = false;
	
	for i in range(1, path.size()):
		#Get destination
		var next_point: Vector2 = path[i];
		
		#Rotate
		await rotate_to(next_point);
		
		#Move
		await move_to(next_point);
	
	map.mouse_focused = false;
	clickable = true;

func _input_event(viewport: Viewport, event: InputEvent, shape_idx: int) -> void:
	if (event is InputEventMouseButton and event.pressed):
		if (event.button_index == MOUSE_BUTTON_LEFT and clickable):
			#print("Clicked: ", self);
			#Toggle selection
			if (faction != Factions.FactionsType.DEFAULT):
				#print("Not same")
				#DEFAULT faction is the player
				return;
			
			var select_tile: Sprite2D = map.get_node("Select Tile");
			# Dont redraw everything if its alrady drew
			if (map.mouse_focused and move_skill.owner_of_action != self):
				#print(map.mouse_focused);
				return;
			
			#Move select tile
			if (not select_tile.visible):
				select_tile.show();
			elif (select_tile.global_position == global_position):
				select_tile.hide();
			select_tile.global_position = global_position;
			
			#Skills
			for skill_name in stats.skills:
				print(skill_name)
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

#Fix
func heal(target: Area2D, skill: Area2D) -> void:
	clickable = false;
	#Edit stats
	var amount: float = stats.calculate_heal(skill.stats);
	target.stats.health += amount;
	target.stats.morale += target.stats.calculate_morale_increase(skill.stats);
	#Dmg indicator
	target.get_node("Dmg Indicator").display_text("%d" % amount, "#68ff00");
	
	clickable = true;

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

func die() -> void:
	var tween: Tween = create_tween();
	tween.tween_property(
		self,
		"modulate:a",
		1.0,
		0.3
	);
	tween.tween_callback(queue_free);

func _on_mouse_entered() -> void:
	name_tag.emit(
		stats.display_name, 
		stats.health / stats.max_health,
		stats.morale / stats.curr_max_morale, 
		Factions.allies.has(faction),
		Factions.enemies.has(faction)
	);
	#print("Nametag required");

func _on_mouse_exited() -> void:
	no_name_tag.emit();

func _on_health_depleted() -> void:
	print(self, " died");
	await $"State Indicator".display_text("Oops☠");
	die();

func _on_morale_depleted() -> void:
	if (stats.health == 0): return;
	print(self, " surrendered");
	$"State Indicator".display_text("Surrendered🏳", "#ffffff");
	faction = Factions.FactionsType.NEUTRAL;

func _on_faction_change(value: Factions.FactionsType) -> void:
	faction = value;
	$Pivot/Sprite.texture = stats.textures[faction];
	print(captured);
	if (captured):
		$"State Indicator".display_text("Captured✊", "#ffffff");
		stats.morale += stats.curr_max_morale * stats.morale_recovery;
		captured = false;
	
	
	
	
	
