class_name MovementStats
extends Resource

## Minimum speed the character can go
@export var min_speed: float:
	set(val):
		# TODO: https://github.com/godotengine/godot/pull/115649
		min_speed = val;
		prints("val", val);
		prints("MAX", max_speed);
		prints("min_speed", min_speed);
		current_speed = current_speed;
		prints("current_speed", current_speed);
## Max speed the character can go
@export var max_speed: float:
	set(val):
		max_speed = val;
		current_speed = current_speed;
## How fast the character can accelerate
@export var acceleration := 100.0;

var current_speed := 0.0:
	set(val):
		current_speed = clampf(val, min_speed, max_speed);

@export var boost_ratio := 4.0;

## How fast the Character2D will rotate when turning
@export var rotation_speed := 5.0;
## Phyisics body mass calculation
@export var mass := 2.0;

func _init(
	p_min_speed: float = 10.0,
	p_max_speed: float = 100.0,
	p_acceleration: float = 100.0,
	p_rotation_speed: float = 5.0,
	p_mass: float = 2.0,
) -> void:
	min_speed = p_min_speed;
	max_speed = p_max_speed;
	acceleration = p_acceleration;
	rotation_speed = p_rotation_speed;
	mass = p_mass;