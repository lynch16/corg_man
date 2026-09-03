class_name PlayerSpawn
extends Node2D

@export var player_scene: PackedScene;
@export var spawn_delay := 1.0;

# @onready var particles: GPUParticles2D = $GPUParticles2D;
# @onready var audio_player: AudioStreamPlayer2D = $AudioStreamPlayer2D;

signal player_spawned(player: Player);

func spawn_player(on_player_die: Callable) -> void:
	var player: Player = player_scene.instantiate();
	player.player_died.connect(on_player_die);
	# particles.emitting = true;
	# audio_player.play();
	get_tree().create_timer(spawn_delay, false).timeout.connect(_add_player.bind(player));
	
func _add_player(player: Player) -> void:
	add_child(player);
	player_spawned.emit(player);
