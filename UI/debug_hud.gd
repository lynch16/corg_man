extends Node

@onready var fps_value: Label = get_node("VBoxContainer/HBoxContainer/FPS_Value");
@onready var mouse_position_label: Label = get_node("VBoxContainer/HBoxContainer/MousePosition");

func _process(_delta: float) -> void:
	fps_value.text = str(Engine.get_frames_per_second());
	var mouse_down_position := get_viewport().get_mouse_position();
	mouse_position_label.text = str(mouse_down_position);
