extends Node3D
class_name World

@onready var world_environment: WorldEnvironment = $WorldEnvironment
@onready var directional_light_3d: DirectionalLight3D = $DirectionalLight3D
@onready var music: AudioStreamPlayer = $Music
@onready var ui: UI = $UI

var spectrum

func _ready() -> void:
	_connect_signals()
	_set_level()
	#_setup_music_analyser()

func _physics_process(delta: float) -> void:
	if not ready:
		await ready
	var master_bus_volume = (AudioServer.get_bus_peak_volume_left_db(0,0) + AudioServer.get_bus_peak_volume_right_db(0,0)) / 2
	#world_environment.environment.background_energy_multiplier = (30 + master_bus_volume) * (delta * 5) -1
	world_environment.environment.glow_bloom = ((30 + master_bus_volume) * (delta * 5))/4
	#print(spectrum.get_magnitude_for_frequency_range(0,1000,1))
	_check_distance_milestones()
	_update_environment()

#Might use this later if time allows
func _setup_music_analyser() -> void:
	spectrum = AudioServer.get_bus_effect_instance(2, 0)

func _connect_signals() -> void:
	EventBus.retry.connect(retry)
	EventBus.run_end.connect(run_end)
	
func retry() -> void:
	GameState.distance = 0
	GameState.terrain_velocity = GameState.STARTING_SPEED
	GameState.current_level = 0
	GameState.player_speed = 5.0
	GameState.multiplier = 0
	get_tree().reload_current_scene()

func run_end(reason: String) -> void:
	get_tree().paused = true
	ui.show_end_screen(reason)

func _check_distance_milestones() -> void:
	var end_distance = 100 + ( 100* (GameState.current_level * GameState.current_level))
	if GameState.distance > end_distance and GameState.current_level < GameState.MAX_LEVEL:
		GameState.current_level += 1
		_set_level()

func _set_level() -> void:
		music.stream = load(GameState.music_tracks[GameState.current_level])
		music.play()
		GameState.player_speed += 2.0

func _update_environment() -> void:
	directional_light_3d.light_color = directional_light_3d.light_color.lerp(GameState.colors[GameState.current_level], 0.01)
