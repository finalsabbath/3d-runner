extends Control
class_name UI

@onready var distance: Label = %Distance
@onready var speed: Label = %Speed
@onready var max_speed: Label = $EndScreen/VBoxContainer/MaxSpeed
@onready var total_distance: Label = $EndScreen/VBoxContainer/TotalDistance
@onready var level: Label = $EndScreen/VBoxContainer/Level
@onready var end_screen: Panel = $EndScreen
@onready var end_reason: Label = %EndReason
@onready var label: Label = $HBoxContainer/Label
@onready var level_label: Label = %Level
@onready var try_again: Button = %TryAgain

func _physics_process(_delta: float) -> void:
	if not ready:
		await ready
	distance.text = "Distance: " + str(snappedi(GameState.distance,1))
	speed.text = "Speed: " + str(snappedi(GameState.terrain_velocity,1))
	level_label.text = "Level: " + str(GameState.current_level+1)


func _on_try_again_pressed() -> void:
	get_tree().paused = false
	end_screen.hide()
	EventBus.retry.emit()

func _on_quit_pressed() -> void:
	get_tree().quit()

func show_end_screen(reason: String) -> void:
	end_reason.text = reason
	max_speed.text = "Max Speed Achieved: " + str(snappedi(GameState.terrain_velocity,1))
	total_distance.text = "Total Distance Travelled: " +  str(snappedi(GameState.distance,1))
	level.text = "Level: " + str(GameState.current_level+1)
	end_screen.show()
	try_again.grab_focus()
	
