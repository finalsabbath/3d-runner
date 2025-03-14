extends Node

# Default values
const STARTING_SPEED: float = 5.0

# Max values
const MAX_LEVEL: int = 6
const NUM_LEVELS:int = 6

# Paths
const MUSIC_PATH = "res://assets/music/levels"
const WORLD_SCENE = "res://scenes/world.tscn"
const MAIN_MENU_SCENE = "res://scenes/main_menu.tscn"
const TERRAIN_BLOCKS_PATH = "res://scenes/prefabs/terrain_blocks"
const OBSTACLES_PATH = "res://scenes/prefabs/obstacles"
const SAVE_PATH = "user://player_data.cfg"

# Set up configfile
@onready var config = ConfigFile.new()

# Current run values
var current_level:int = 0
var levels: Array
var distance: float = 0
var multiplier: float = 0
var score: int = 0
var player_speed: float = 5.0
var terrain_velocity: float = 5.0
var game_paused: bool = false

# Persistant values
var player_name: String
var best: float = 0
var best_id: String
var setup_complete: bool = false
var welcome_seen: bool = true

# Terrain generation arrays
var terrainBlocks: Array = []
var obstacles: Array = []
var obstacles_no_barrier: Array = []

# Level arrays
var colors: Array = [Color.RED,Color.ORANGE,Color.YELLOW,Color.GREEN,Color.BLUE,Color.INDIGO,Color.VIOLET]
var music_tracks: Array = []

# Debug mode
# Prevents obstacles/pits and disables saving run data
var debug_enabled: bool = false

func setup_game() -> void:
	_load_music_tracks(MUSIC_PATH)
	_load_terrain(TERRAIN_BLOCKS_PATH)
	_load_obstacles(OBSTACLES_PATH)
	configure_leaderboard()
	setup_complete = true

func _load_music_tracks(target_path: String) -> void:
	var dir = DirAccess.open(target_path)
	for scene_path in dir.get_files():
		if ".import" in scene_path:
			scene_path = scene_path.trim_suffix(".import")
			print("Loading music track: " + target_path + "/" + scene_path)
			var new_path: String = target_path + "/" + scene_path
			music_tracks.append(new_path)

func _load_terrain(target_path: String) -> void:
	var dir = DirAccess.open(target_path)
	for scene_path in dir.get_files():
		if ".remap" in scene_path:
			scene_path = scene_path.trim_suffix('.remap')
		print("Loading terrian block scene: " + target_path + "/" + scene_path)
		terrainBlocks.append(load(target_path + "/" + scene_path))

func _load_obstacles(target_path: String) -> void:
	var dir = DirAccess.open(target_path)
	for scene_path in dir.get_files():
		if ".remap" in scene_path:
			scene_path = scene_path.trim_suffix('.remap')
		print("Loading obstacle scene: " + target_path + "/" + scene_path)
		obstacles.append(load(target_path + "/" + scene_path))
		if "barrier" not in scene_path:
			obstacles_no_barrier.append(load(target_path + "/" + scene_path))


func configure_leaderboard() -> void:
	var file = "res://addons/silent_wolf/.env"
	var env_content = FileAccess.get_file_as_string(file)
	var env_dict = JSON.parse_string(env_content)
	
	SilentWolf.configure({
		"api_key": env_dict["API_KEY"],
		"game_id": env_dict["GAME_ID"],	
		"log_level": 0
	})

	SilentWolf.configure_scores({
		"open_scene_on_close": "res://scenes/main_menu.tscn"
	})
	
# Saving and loading
func set_and_save() -> void:
	set_data()
	save_data()

func set_data() -> void:
	config.set_value("Player","name",player_name)
	config.set_value("Player","best",best)
	config.set_value("Player","best_id",best_id)

func save_data() -> void:
	config.save(SAVE_PATH)

func load_data():
	if config.load(SAVE_PATH) != OK:
		set_and_save()
		welcome_seen = false
	
	player_name = config.get_value("Player","name", 1000)
	best = config.get_value("Player","best", 1000)
	best_id = config.get_value("Player","best_id", 1000)
