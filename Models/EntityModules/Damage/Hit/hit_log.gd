class_name HitLog
extends RefCounted

var hit_log: Array = [];

func has_hit(hit_node: Variant) -> bool:
	return hit_log.has(hit_node);

func log_hit(hit_node: Variant) -> void:
	hit_log.append(hit_node);

func reset_log() -> void:
	hit_log.clear();