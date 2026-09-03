class_name InputController
extends Node

signal input_up(delta: float);
signal input_back(delta: float);
signal input_left(delta: float);
signal input_right(delta: float);

func _physics_process(delta: float) -> void:
	if (Input.is_action_pressed("move_left")):
		input_left.emit(delta);
	
	elif (Input.is_action_pressed("move_right")):
		input_right.emit(delta);
	
	elif (Input.is_action_pressed("move_up")):
		input_up.emit(delta);
	
	elif (Input.is_action_pressed("move_down")):
		input_back.emit(delta);