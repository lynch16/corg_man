class_name Level
extends Node2D

@onready var player_spawn: PlayerSpawn = $PlayerSpawn;
@onready var map: Map = $Map;

func _ready() -> void:
	_set_player_spawn_position();
	player_spawn.spawn_player(_on_player_die);

func _on_player_die() -> void:
	pass;

func _set_player_spawn_position() -> void:
	# TODO: Parameterize
	var start_row := map.map_gen.tile_generator.num_tile_rows - 8 - TileGenerator.ROW_RAISE_OFFSET + 1.5; # Adding 0.5 due to player's pivot point being in center
	var start_column := map.map_gen.tile_generator.num_mid_columns + 1;

	# TODO: This should align to tile size of tile map
	var new_position := Vector2(start_column * 16, start_row * 16);

	player_spawn.global_position = (global_position + new_position);

