extends Control
class_name UI

@onready var distance: Label = %Distance
@onready var speed: Label = %Speed
@onready var max_speed: Label = $EndScreen/VBoxContainer/MaxSpeed
@onready var total_distance: Label = $EndScreen/VBoxContainer/TotalDistance
@onready var end_screen: Panel = $EndScreen


func _physics_process(_delta: float) -> void:
	if not ready:
		await ready
	distance.text = "Distance: " + str(snappedi(GameStats.distance,1))
	speed.text = "Speed: " + str(snappedi(GameStats.terrain_velocity,1))


func _on_try_again_pressed() -> void:
	print("retry button")
	get_tree().paused = false
	end_screen.hide()
	EventBus.retry.emit()

func _on_quit_pressed() -> void:
	get_tree().quit()

func show_end_screen() -> void:
	max_speed.text = "Max Speed Achieved: " + str(snappedi(GameStats.terrain_velocity,1))
	total_distance.text = "Total Distance Travelled: " +  str(snappedi(GameStats.distance,1))
	end_screen.show()
	
