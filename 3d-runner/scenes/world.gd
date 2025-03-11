extends Node3D
class_name World

const NUM_LEVELS:int = 6
const MUSIC_PATH: String = "res://assets/music/"

@onready var world_environment: WorldEnvironment = $WorldEnvironment
@onready var directional_light_3d: DirectionalLight3D = $DirectionalLight3D
@onready var music: AudioStreamPlayer = $Music
@onready var pulse_audio: AudioStreamPlayer3D = $Pulse
@onready var ui: UI = $UI

var pulse: float = 0.0
var pulse_up: bool = true

#Level arrays
var colors: Array = [Color.RED,Color.ORANGE,Color.YELLOW,Color.GREEN,Color.BLUE,Color.INDIGO,Color.VIOLET]
var music_tracks: Array = []

func _ready() -> void:
	_connect_signals()
	_get_music_tracks(MUSIC_PATH)
	_setup_levels()
	_set_level()

func _physics_process(delta: float) -> void:
	var master_bus_volume = (AudioServer.get_bus_peak_volume_left_db(0,0) + AudioServer.get_bus_peak_volume_right_db(0,0)) / 2
	world_environment.environment.background_energy_multiplier = (30 + master_bus_volume) * (delta * 5) -1
	_check_distance_milestones()
	_update_environment()

func _connect_signals() -> void:
	EventBus.retry.connect(retry)
	EventBus.run_end.connect(run_end)
	
func retry() -> void:
	GameStats.distance = 0
	GameStats.terrain_velocity = GameStats.STARTING_SPEED
	GameStats.current_level = 0
	GameStats.player_speed = 5.0
	get_tree().reload_current_scene()

func _pulse(delta: float) -> void:
	world_environment.environment.background_energy_multiplier = pulse
	if pulse_up: 
		pulse +=(GameStats.terrain_velocity * delta) * delta
	else: 
		pulse -= (GameStats.terrain_velocity * delta) * delta
	
	if pulse > 2.5:
		pulse_up = false
		pulse_audio.play()
	elif pulse < 1:
		pulse_up = true

func run_end(reason: String) -> void:
	get_tree().paused = true
	ui.show_end_screen(reason)

func _check_distance_milestones() -> void:
	if GameStats.distance > GameStats.levels[GameStats.current_level].END_DISTANCE:
		GameStats.current_level += 1
		_set_level()

func _set_level() -> void:
		music.stream = load(GameStats.levels[GameStats.current_level].MUSIC)
		music.play()
		GameStats.player_speed += 2.0

func _update_environment() -> void:
	directional_light_3d.light_color = directional_light_3d.light_color.lerp(GameStats.levels[GameStats.current_level].COLOR, 0.01)
	
func _setup_levels() -> void:
	for i in range(NUM_LEVELS):
		var new_level: Dictionary = {
			"COLOR": colors[i],
			"MUSIC": music_tracks[i],
			"END_DISTANCE": 100 + (100*i^2)
			}
		GameStats.levels.append(new_level)	

	
func _get_music_tracks(target_path: String) -> void:
	var dir = DirAccess.open(target_path)
	for scene_path in dir.get_files():
		if ".import" not in scene_path:
			print("Loading music track: " + target_path + "/" + scene_path)
			var new_path: String = target_path + "/" + scene_path
			music_tracks.append(new_path)
