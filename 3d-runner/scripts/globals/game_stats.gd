extends Node

const STARTING_SPEED: float = 5.0

const NUM_LEVELS:int = 6
@export var music_path = "res://assets/music"
const WORLD = "res://scenes/world.tscn"

var current_level:int = 0
var levels: Array
var distance: float = 0
var terrain_velocity: float = 5.0
var player_speed: float = 5.0

#Level arrays
var colors: Array = [Color.RED,Color.ORANGE,Color.YELLOW,Color.GREEN,Color.BLUE,Color.INDIGO,Color.VIOLET]
var music_tracks: Array = []


func setup_game() -> void:
	_get_music_tracks(music_path)
	#_setup_levels()
	#get_tree().change_scene_to_file(WORLD)
	print("Setup complete")
	
#func _setup_levels() -> void:
	#print("start setting up " + str(NUM_LEVELS) + " levels")
	#for i in range(6):
		#print("Adding level: " + str(i))
		#var new_level: Dictionary = {
			#"COLOR": colors[i],
			#"MUSIC": music_tracks[i],
			#"END_DISTANCE": 100 + (100*(i*i))
			#}
		#print("Adding new level: " + str(new_level))
		#levels.append(new_level)
	#print("Added " + str(GameStats.levels.size()) + " levels")

func _get_music_tracks(target_path: String) -> void:
	var dir = DirAccess.open(target_path)
	for scene_path in dir.get_files():
		if ".import" in scene_path:
			scene_path = scene_path.trim_suffix(".import")
			print("Loading music track: " + target_path + "/" + scene_path)
			var new_path: String = target_path + "/" + scene_path
			music_tracks.append(new_path)
