class_name DealDamage
extends Node

@export var combat_stats: CombatStats;
@export var owner_node: Node;
var hit_log: HitLog;

func _init(
	p_combat_stats: CombatStats,
	p_owner_node: Node = null,
	p_hit_log: HitLog = null,
) -> void:
	combat_stats = p_combat_stats;
	owner_node = p_owner_node;
	hit_log = p_hit_log;

func damage(target_node: Node2D, hit_position: Vector2, hit_angle: float) -> void:
	var damageable := Damageable.get_damageable(target_node);
	if (damageable):
		if (hit_log != null):
			if (hit_log.has_hit(damageable)):
				return;
			else:
				hit_log.log_hit(damageable);

		damageable.on_damage(combat_stats.get_damage(), owner_node, hit_position, hit_angle);