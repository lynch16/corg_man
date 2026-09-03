class_name Level
extends Node2D

@onready var player_spawn: PlayerSpawn = $PlayerSpawn;

func _ready() -> void:
	player_spawn.spawn_player(_on_player_die);

func _on_player_die() -> void:
	pass;