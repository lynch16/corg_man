class_name Hurtbox2D
extends Area2D

@export var health_stats: HealthStats;
@export var shape: Shape2D;
@export var owner_node: Node;

var damageable: Damageable;
var collision_shape: CollisionShape2D;

func _init(
	p_health_stats: HealthStats = HealthStats.new(),
	p_shape: Shape2D = null,
	p_owner_node: Node = null,
) -> void:
	health_stats = p_health_stats;
	shape = p_shape;
	owner_node = p_owner_node;

func _ready() -> void:
	monitoring = false;

	var damage_results: Array[DamageResult] = [];
	for child in get_children():
		if (child is DamageResult):
			damage_results.append(child);

	damageable = Damageable.new(   
		health_stats,
		damage_results,
		owner_node,
	);
	add_child(damageable);

	if (shape != null):
		collision_shape = CollisionShape2D.new();
		collision_shape.shape = shape;
		add_child(collision_shape);
	
	set_collision_layer_value(1, false);
	set_collision_mask_value(1, false);

	match health_stats.faction:
		FactionStats.Faction.PLAYER:
			set_collision_layer_value(1, true);
		FactionStats.Faction.ENEMY:
			set_collision_layer_value(2, true);
		FactionStats.Faction.ENVIRONMENT:
			set_collision_layer_value(1, true);
			set_collision_layer_value(2, true);

func get_colliders() -> Array[CollisionShape2D]:
	return [collision_shape];
