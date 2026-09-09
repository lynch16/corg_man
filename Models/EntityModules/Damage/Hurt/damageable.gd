class_name Damageable
extends Node

var health_stats: HealthStats;
var damage_result_states: Array[DamageResult];
var owner_node: Node2D;

var checked_owner_setup: bool = false;

static func get_damageable(_owner: Node2D) -> Damageable:
	var damageable: Damageable;
	var maybe_damageable: Variant = _owner.get("damageable");
	if (maybe_damageable is Damageable):
		damageable = maybe_damageable;
	
	return damageable;

func _init(
	p_health_stats: HealthStats, 
	p_damage_results: Array[DamageResult],
	p_owner_node: Node
) -> void:
	health_stats = p_health_stats;
	damage_result_states = p_damage_results;
	owner_node = p_owner_node;

func _ready() -> void:	
	for damage_result in damage_result_states:
		damage_result.on_init(self);

func _process(_delta: float) -> void:
	if (!checked_owner_setup):
		if (!owner_node.get("damageable")): # Attempt to set damageable reference on owner if it doesn't exist, but throw an error if it does exist and isn't this instance
			owner_node.set("damageable", self);
		assert(owner_node.get("damageable") == self, "Owner " + owner_node.name + " node must have a 'damageable' property set to this node");
		checked_owner_setup = true;

func on_damage(damage_amount: float, damager_node: Node, hit_position: Vector2, hit_angle: float) -> void:
	for damage_result in damage_result_states:
		var check_next_result: bool = damage_result.on_damage(damage_amount, damager_node, hit_position, hit_angle);
		if !check_next_result:
			break;
