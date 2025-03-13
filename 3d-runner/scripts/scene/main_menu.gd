extends Control

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var start: Button = %Start

var color_num: int = 0
var next_color = GameState.colors[0]

func _ready() -> void:
	GameState.setup_game()
	start.grab_focus()

func _on_start_pressed() -> void:
	#GameStats.setup_game()
	get_tree().change_scene_to_file(GameState.WORLD_SCENE)


func _on_quit_pressed() -> void:
	get_tree().quit()

func _physics_process(_delta: float) -> void:
	if not ready:
		await ready
	sprite_2d.modulate = sprite_2d.modulate.lerp(next_color,.01)


func _on_timer_timeout() -> void:
	color_num += 1
	if color_num >= 7:
		color_num = 0
	next_color = GameState.colors[color_num]
