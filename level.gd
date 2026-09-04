class_name Level
extends Node2D

@onready var player_spawn: PlayerSpawn = $PlayerSpawn;
@onready var map: Map = $Map;
@onready var enemy: Enemy = $Enemy;

func _ready() -> void:
	_set_enemy_spawn_position();
	_set_player_spawn_position();
	player_spawn.spawn_player(_on_player_die);

func _on_player_die() -> void:
	pass;

func _set_player_spawn_position() -> void:
	# TODO: Parameterize
	var start_row := map.map_gen.tile_generator.num_tile_rows - 8 - TileGenerator.ROW_RAISE_OFFSET + 1; 
	var start_column := map.map_gen.tile_generator.num_mid_columns + 1;
	var new_position := map.get_position_from_tile(Vector2i(start_column, start_row));

	player_spawn.global_position = (global_position + new_position);

func _set_enemy_spawn_position() -> void:
	# TODO: Parameterize
	var start_row := map.map_gen.tile_generator.num_tile_rows - 16 - TileGenerator.ROW_RAISE_OFFSET + 1; 
	var start_column := map.map_gen.tile_generator.num_mid_columns + 1;
	var new_position := map.get_position_from_tile(Vector2i(start_column, start_row));

	enemy.global_position = global_position + new_position;