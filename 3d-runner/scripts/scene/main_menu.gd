extends Control

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var start: Button = %Start
@onready var background: TextureRect = $Background
@onready var leaderboard_panel: Control = $LeaderboardPanel
@onready var name_entry: Control = $NameEntry

var color_num: int = 0
var next_color = GameState.colors[0]

func _ready() -> void:
	if !GameState.setup_complete:
		GameState.load_data()
		GameState.setup_game()
	start.grab_focus()
	if GameState.player_name == "":
		name_entry.show()

func _on_start_pressed() -> void:
	get_tree().change_scene_to_file(GameState.WORLD_SCENE)


func _on_quit_pressed() -> void:
	get_tree().quit()

func _physics_process(_delta: float) -> void:
	if not ready:
		await ready
	sprite_2d.modulate = sprite_2d.modulate.lerp(next_color,.01)
	var master_bus_volume = (AudioServer.get_bus_peak_volume_left_db(0,0) + AudioServer.get_bus_peak_volume_right_db(0,0)) / 2
	background.modulate.v = -master_bus_volume /200


func _on_timer_timeout() -> void:
	color_num += 1
	if color_num >= 7:
		color_num = 0
	next_color = GameState.colors[color_num]


func _on_leaderboard_pressed() -> void:
	GameState.configure_leaderboard()
	leaderboard_panel.populate_scores()
	leaderboard_panel.show()
	leaderboard_panel.return_menu.grab_focus()
