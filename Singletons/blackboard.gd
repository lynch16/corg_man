extends Node

var map: Map;
func set_map(p_map: Map) -> void:
	map = p_map;
	blackboard_updated.emit();
func get_map() -> Map:
	return map;
	
var player: Player;
func set_player(p_player: Player) -> void:
	player = p_player;
	blackboard_updated.emit();
func get_player() -> Player:
	return player;

signal blackboard_updated();