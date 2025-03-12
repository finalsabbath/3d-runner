extends Control


const WORLD = "res://scenes/world.tscn"
@onready var sprite_2d: Sprite2D = $Sprite2D

var colors: Array = [Color.RED,Color.ORANGE,Color.YELLOW,Color.GREEN,Color.BLUE,Color.INDIGO,Color.VIOLET]
var color_num: int = 0
var next_color = colors[0]


func _on_start_pressed() -> void:
	get_tree().change_scene_to_file(WORLD)


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
	next_color = colors[color_num]
