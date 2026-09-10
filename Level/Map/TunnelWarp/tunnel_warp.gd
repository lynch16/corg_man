class_name TunnelWarp extends Node2D

# Enter warp point, add body
# Exit warp point, warp body if exiting outside the map

@onready var warp_point1: Area2D = $Warp1;
@onready var warp_point2: Area2D = $Warp2;

var warp_1_body: CharacterBody2D;
var warp_2_body: CharacterBody2D;

func _ready() -> void:
	warp_point1.body_entered.connect(_on_warp_1_entered);
	warp_point2.body_entered.connect(_on_warp_2_entered);

func _process(_delta: float) -> void:
	queue_redraw();

func set_warp_points(warp_1: Vector2, warp_2: Vector2) -> void:
	var map := Blackboard.get_map();
	var tile_size := map.tile_map_layer.tile_set.tile_size;
	warp_point1.global_position = warp_1;
	var warp_1_collider: CollisionShape2D = warp_point1.get_node("CollisionShape2D");
	warp_1_collider.global_position = Vector2(warp_1.x - tile_size.x, warp_1.y);

	warp_point2.global_position = warp_2;
	var warp_2_collider: CollisionShape2D = warp_point2.get_node("CollisionShape2D");
	warp_2_collider.global_position = Vector2(warp_2.x + tile_size.x, warp_2.y);

func _on_warp_1_entered(body: Node2D) -> void:
	_on_warp_entered(body, warp_point2)

func _on_warp_2_entered(body: Node2D) -> void:
	_on_warp_entered(body, warp_point1)
   
func _on_warp_entered(body: Node2D, next_warp_point: Area2D) -> void:
	if (body is CharacterBody2D):
		body.global_position = next_warp_point.global_position

func _draw() -> void:
	var map := Blackboard.get_map();
	if (!map): return;

	var tile_size := map.tile_map_layer.tile_set.tile_size;
	var half_tile_size := tile_size/2;
	draw_rect(Rect2(warp_point1.global_position.x - half_tile_size.x, warp_point1.global_position.y - half_tile_size.y, tile_size.x, tile_size.y), Color.RED);
	draw_rect(Rect2(warp_point2.global_position.x - half_tile_size.x, warp_point2.global_position.y - half_tile_size.y, tile_size.x, tile_size.y), Color.BLUE)
