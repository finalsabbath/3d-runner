extends Control
class_name UI

@onready var pause_screen: Control = $PauseScreen
@onready var end_screen: Panel = $EndScreen

# Top UI
@onready var distance: Label = %Distance
@onready var speed: Label = %Speed
@onready var best: Label = $Best
@onready var multiplier: Label = %Multiplier
@onready var level_label: Label = %Level

func _physics_process(_delta: float) -> void:
	if not ready:
		await ready
	distance.text = "Distance: " + str(snappedi(GameState.distance,1))
	speed.text = "Speed: " + str(snappedi(GameState.terrain_velocity,1))
	level_label.text = "Level: " + str(GameState.current_level+1)
	best.text = "Best: " +  str(snappedi(GameState.best,1))
	multiplier.text = "Multiplier: " +  str(snappedf(GameState.multiplier,0.1))

func _process(_delta: float) -> void:
	if Input.is_action_pressed("ui_cancel") and !GameState.game_paused:
		get_tree().paused = true
		pause_screen.show()
		GameState.game_paused = true
		
