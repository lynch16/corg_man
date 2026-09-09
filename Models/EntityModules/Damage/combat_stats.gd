class_name CombatStats
extends Resource

@export var base_attack_power := 1.0:
	set(val):
		base_attack_power = val;
		current_attack_power = base_attack_power;
var current_attack_power := 1.0;

@export var base_defense := 1.0:
	set(val):
		base_defense = val;
		current_defense = base_defense;
var current_defense := 1.0;

@export var damage_dealt := 10.0;

@export var faction: FactionStats.Faction;

func _init(
	p_attack_power: float = 1.0,
	p_defense: float = 1.0,
) -> void:
	base_attack_power = p_attack_power;
	base_defense = p_defense;

func get_damage() -> float:
	return _apply_attack_power(damage_dealt);

func _apply_attack_power(attack_dmg: float) -> float:
	return current_attack_power * attack_dmg;

func _apply_defense(attack_dmg: float) -> float:
	return (1.0/current_defense) * attack_dmg;
