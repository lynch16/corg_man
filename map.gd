class_name Map
extends Node

# TODO: Draw target and current tiles for debugging

@export var map_textures: Array[CompressedTexture2D] = [];
@onready var tile_map_layer: TileMapLayer = $TileMapLayer;

var map_gen: MapGenerator = MapGenerator.new();
var terrain_set_id := 0;
var terrain_id := 0;

signal on_map_generated();

func _ready() -> void:
	_set_tile_map_texture();
	_generate_map();
	Blackboard.set_map(self);

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

	for x in range(num_full_columns):
		for y in range(num_tile_rows):
			var tile_type: TileGenerator.TileType = map_gen.tile_generator.tiles[x][y];
			if (tile_type == TileGenerator.TileType.Wall):
				wall_tiles.append(Vector2i(x + 1, y + 1));

	tile_map_layer.set_cells_terrain_connect(wall_tiles, terrain_set_id, terrain_id);
	on_map_generated.emit();

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
