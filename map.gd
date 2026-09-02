extends Node2D

@export var map_textures: Array[CompressedTexture2D] = [];

var map_gen: MapGenerator = MapGenerator.new();

@onready var tile_map_layer: TileMapLayer = $TileMapLayer;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var source: TileSetAtlasSource = tile_map_layer.tile_set.get_source(1);
	
	var new_texture_idx := randi() % map_textures.size();

	source.texture = map_textures[new_texture_idx];
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

	tile_map_layer.set_cells_terrain_connect(wall_tiles, 0, 0);

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
