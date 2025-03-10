extends Node3D
class_name World

@onready var world_environment: WorldEnvironment = $WorldEnvironment
@onready var music: AudioStreamPlayer = $Music
@onready var pulse_audio: AudioStreamPlayer3D = $Pulse
@onready var ui: UI = $UI


var pulse: float = 0.0
var pulse_up: bool = true

func _ready() -> void:
	_connect_signals()

func _physics_process(delta: float) -> void:
	_pulse(delta)

func _connect_signals() -> void:
	EventBus.retry.connect(retry)
	EventBus.death_block_hit.connect(hit_death_block)
	
func retry() -> void:
	GameStats.distance = 0
	GameStats.terrain_velocity = GameStats.STARTING_SPEED
	get_tree().reload_current_scene()

func _pulse(delta: float) -> void:
	world_environment.environment.background_energy_multiplier = pulse
	if pulse_up: 
		pulse +=(GameStats.terrain_velocity * delta) * delta
	else: 
		pulse -= (GameStats.terrain_velocity * delta) * delta
	
	if pulse > 2:
		pulse_up = false
		pulse_audio.play()
	elif pulse < 1:
		pulse_up = true

func hit_death_block() -> void:
	get_tree().paused = true
	ui.show_end_screen()
