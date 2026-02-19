extends Resource
class_name Stats;

enum BuffableStats {
	MAX_MORAL,
	DEFENSE,
	POWER
};

const STAT_CURVES: Dictionary = {
	BuffableStats.MAX_MORAL: preload("uid://cupb0cwag4bpi"),
	BuffableStats.DEFENSE: preload("uid://bq0fdxg3pmc2p"),
	BuffableStats.POWER: preload("uid://c54udxsa21bkm")
};

signal health_depleted;
signal moral_depleted;

@export var display_name: String = "Dummy";
@export var skills: Array[String] = [];
@export var max_health: float = 100.0;
@export var base_max_moral: float = 30.0;
@export var base_defense: float = 50.0;
@export var base_power: float = 10.0;
@export var badge: int = 0: set = _on_badge_set;
@export var max_badge: int = 10;
@export var speed: int = 2;

@export var bullet_offset: Dictionary[String, int] = {};
@export var recoil_offset: Dictionary[String, int] = {};
@export var rotate_speed: float = 5.0;

var curr_defense: float = 50.0;
var curr_max_moral: float = 30.0;
var curr_power: float = 10.0;

var health: float = 0: set = _on_health_set;
var moral: float = 0: set = _on_moral_set;

var stat_buffs: Array;

func _init() -> void:
	setup_stats.call_deferred();

func setup_stats() -> void:
	#recalculate curr stats first
	health = max_health;
	moral = curr_max_moral;

func calculate_damage(skill_stats: SkillStats, enemy: Area2D) -> float:
	var dmg: float = (curr_power + skill_stats.attack) * moral;
	var enemy_def: float = enemy.stats.curr_defense * enemy.stats.moral;
	
	var total_dmg: float = dmg / enemy_def;
	
	return total_dmg;

func add_buff(buff: StatBuff) -> void:
	stat_buffs.append(buff);
	recalculate_stats.call_deferred();

func remove_buff(buff: StatBuff) -> void:
	stat_buffs.erase(buff);
	recalculate_stats.call_deferred();

func recalculate_stats() -> void:
	var stat_multipliers: Dictionary = {}; #Amount to multiply included stats by
	var stat_addends: Dictionary = {}; #Amount to add to included stats
	for buff in stat_buffs:
		var stat_name: String = BuffableStats.keys()[buff.stat].to_lower();
		match (buff.buff_type):
			StatBuff.BuffType.ADD:
				if not stat_addends.has(stat_name):
					stat_addends[stat_name] = 0.0;
				stat_addends[stat_name] += buff.buff_amount;
			StatBuff.BuffType.MULTIPLY:
				if not stat_multipliers.has(stat_name):
					stat_multipliers[stat_name] = 1.0;
				stat_multipliers[stat_name] += buff.buff_amount;
				
				if (stat_multipliers[stat_name] < 0.0):
					stat_multipliers[stat_name] = 0.0;
	
	var stat_sample_pos: float = float(badge);
	curr_max_moral = base_max_moral * STAT_CURVES[BuffableStats.MAX_MORAL]\
					.sample(stat_sample_pos);
	curr_defense = base_defense * STAT_CURVES[BuffableStats.DEFENSE]\
					.sample(stat_sample_pos);
	curr_power = base_power * STAT_CURVES[BuffableStats.POWER]\
					.sample(stat_sample_pos);
	
	for stat_name in stat_multipliers:
		var cur_property_name: String = str("current_" + stat_name);
		set(cur_property_name, get(cur_property_name) * stat_multipliers[stat_name]);
	
	for stat_name in stat_addends:
		var cur_property_name: String = str("current_" + stat_name);
		set(cur_property_name, get(cur_property_name) + stat_addends[stat_name]);

func _on_health_set(value: float) -> void:
	health = clampf(value, 0.0, max_health);
	if (health <= 0):
		health_depleted.emit();

func _on_moral_set(value: float) -> void:
	moral = clampf(value, 0.0, curr_max_moral);
	if (moral <= 0):
		moral_depleted.emit();

func _on_badge_set(value: int) -> void:
	var old_badge: int = badge;
	badge = clampi(value, old_badge, max_badge);
	if (badge != old_badge):
		recalculate_stats();





	

	
