class_name MovementController
extends Node2D
## Move in grid like pattern
## Checks that can move before doing so

@export var movement_stats: MovementStats;
@export var moveable_character: CharacterBody2D;

# Track state of inputs given
var direction: Vector2 = Vector2.RIGHT;
var current_velocity := Vector2.ZERO;

var tween: Tween;

func _move_direction(delta: float) -> void:
	moveable_character.rotation = direction.angle();
	moveable_character.velocity = direction * movement_stats.current_speed * delta;
	moveable_character.move_and_slide();
	
func move_up(delta: float) -> void:
	direction = Vector2.UP;
	_move_direction(delta);

func move_down(delta: float) -> void:
	direction = Vector2.DOWN;
	_move_direction(delta);

func move_left(delta: float) -> void:
	direction = Vector2.LEFT;
	_move_direction(delta);

func move_right(delta: float) -> void:
	direction = Vector2.RIGHT;
	_move_direction(delta);
