extends Control
class_name UI

@onready var distance: Label = %Distance
@onready var speed: Label = %Speed


func _physics_process(_delta: float) -> void:
	if not ready:
		await ready
	distance.text = "Distance: " + str(snappedi(GameStats.distance,1))
	speed.text = "Speed: " + str(snappedi(GameStats.terrain_velocity,1))
