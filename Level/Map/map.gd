class_name Map
extends Node

@export var map_textures: Array[CompressedTexture2D] = [];
@export var tunnel_warp_scene: PackedScene;

@onready var tile_map_layer: TileMapLayer = $TileMapLayer;

var map_gen: MapGenerator = MapGenerator.new();
var terrain_set_id := 0;
var terrain_id := 0;

signal on_map_generated();

func _ready() -> void:
	Blackboard.set_map(self);
	_set_tile_map_texture();
	_generate_map();

func _set_tile_map_texture() -> void:
	var source: TileSetAtlasSource = tile_map_layer.tile_set.get_source(1);
	var new_texture_idx := randi() % map_textures.size();
	source.texture = map_textures[new_texture_idx];

func _generate_map() -> void:
	map_gen.run();
	var num_tile_rows := map_gen.tile_generator.num_tile_rows;
	var num_tile_columns := map_gen.tile_generator.num_tile_columns;
	var num_full_columns := (num_tile_columns - 2) * 2;

	var wall_tiles: Array[Vector2i] = [];
	var tunnel_tiles: Array[Vector2i] = [];
	var pellet_tiles: Array[Vector2i] = [];
	var energizer_tiles: Array[Vector2i] = [];

	for x in range(num_full_columns):
		for y in range(num_tile_rows):
			var tile_type: TileGenerator.TileType = map_gen.tile_generator.tiles[x][y];
			var tile_pos := Vector2i(x + 1, y + 1);
			match(tile_type):
				TileGenerator.TileType.Wall:
					wall_tiles.append(tile_pos);
				TileGenerator.TileType.Tunnel:
					tunnel_tiles.append(tile_pos);
				TileGenerator.TileType.Pellet:
					pellet_tiles.append(tile_pos);
				TileGenerator.TileType.Energizer:
					energizer_tiles.append(tile_pos);

	tile_map_layer.set_cells_terrain_connect(wall_tiles, terrain_set_id, terrain_id);
	_configure_warp_points(tunnel_tiles);

	on_map_generated.emit();

func _configure_warp_points(tunnel_tiles: Array[Vector2i]) -> void:
	var tunnel_pairs: Array[Array] = [];
	for tile in tunnel_tiles:
		var matching_tunnel_row_tile_idx := tunnel_tiles.find_custom(
			func(t: Vector2i) -> bool:
				return t != tile && t.y == tile.y
		);
		if (matching_tunnel_row_tile_idx != -1):
			var matching_tunnel := tunnel_tiles[matching_tunnel_row_tile_idx];
			var tile_pair := [tile, matching_tunnel];
			if (!tunnel_pairs.has(tile_pair)):
				tile_pair.reverse();
				if(!tunnel_pairs.has(tile_pair)):
					tunnel_pairs.append(tile_pair);

	for pair in tunnel_pairs:
		var tunnel_warp: TunnelWarp = tunnel_warp_scene.instantiate()
		add_child(tunnel_warp);
		var point_1: Vector2i = pair[0];
		var warp_1_pos := get_position_from_tile(point_1);
		var point_2: Vector2i = pair[1];
		var warp_2_pos := get_position_from_tile(point_2);
		if (warp_1_pos.x < warp_2_pos.x):
			tunnel_warp.set_warp_points(warp_1_pos, warp_2_pos);
		else:
			tunnel_warp.set_warp_points(warp_2_pos, warp_1_pos);

func get_tile_from_position(global_pos: Vector2) -> Vector2i:
	var pos := global_pos - _get_half_tile_size();
	return Vector2i(
		roundi(pos.x / tile_map_layer.tile_set.tile_size.x),
		roundi((pos.y) / tile_map_layer.tile_set.tile_size.y)
	)

func get_position_from_tile(tile: Vector2i) -> Vector2:
	return Vector2(tile.x * tile_map_layer.tile_set.tile_size.x, (tile.y) * tile_map_layer.tile_set.tile_size.y) + _get_half_tile_size();

func _get_half_tile_size() -> Vector2:
	return Vector2(tile_map_layer.tile_set.tile_size / 2);
