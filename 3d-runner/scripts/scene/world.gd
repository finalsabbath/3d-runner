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
	_setup_music_analyser()

func _physics_process(delta: float) -> void:
	if not ready:
		await ready
	var master_bus_volume = (AudioServer.get_bus_peak_volume_left_db(0,0) + AudioServer.get_bus_peak_volume_right_db(0,0)) / 2
	#world_environment.environment.background_energy_multiplier = (30 + master_bus_volume) * (delta * 5) -1
	world_environment.environment.glow_bloom = ((30 + master_bus_volume) * (delta * 5))/4
	#print(spectrum.get_magnitude_for_frequency_range(0,1000,1))
	_check_distance_milestones()
	_update_environment()


#Might use this later
func _setup_music_analyser() -> void:
	spectrum = AudioServer.get_bus_effect_instance(2, 0)


func _connect_signals() -> void:
	EventBus.retry.connect(retry)
	EventBus.run_end.connect(run_end)
	
func retry() -> void:
	GameStats.distance = 0
	GameStats.terrain_velocity = GameStats.STARTING_SPEED
	GameStats.current_level = 0
	GameStats.player_speed = 5.0
	get_tree().reload_current_scene()

func run_end(reason: String) -> void:
	get_tree().paused = true
	ui.show_end_screen(reason)

func _check_distance_milestones() -> void:
	var end_distance = 100 + ( 100* (GameStats.current_level * GameStats.current_level))
	if GameStats.distance > end_distance and GameStats.current_level < GameStats.MAX_LEVEL:
		GameStats.current_level += 1
		_set_level()

func _set_level() -> void:
		music.stream = load(GameStats.music_tracks[GameStats.current_level])
		music.play()
		GameStats.player_speed += 2.0

func _update_environment() -> void:
	directional_light_3d.light_color = directional_light_3d.light_color.lerp(GameStats.colors[GameStats.current_level], 0.01)
