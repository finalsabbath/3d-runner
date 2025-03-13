extends Control
class_name UI

@onready var end_screen: Panel = $EndScreen

# Top UI
@onready var distance: Label = %Distance
@onready var speed: Label = %Speed
@onready var best: Label = $Best
@onready var multiplier: Label = %Multiplier

#End Screen
@onready var end_reason: Label = %EndReason
@onready var max_speed: Label = $EndScreen/VBoxContainer/MaxSpeed
@onready var total_distance: Label = $EndScreen/VBoxContainer/TotalDistance
@onready var level: Label = $EndScreen/VBoxContainer/Level
@onready var score: Label = $EndScreen/VBoxContainer/Score
@onready var level_label: Label = %Level
@onready var try_again: Button = %TryAgain

func _physics_process(_delta: float) -> void:
	if not ready:
		await ready
	distance.text = "Distance: " + str(snappedi(GameState.distance,1))
	speed.text = "Speed: " + str(snappedi(GameState.terrain_velocity,1))
	level_label.text = "Level: " + str(GameState.current_level+1)
	best.text = "Best: " +  str(snappedi(GameState.best,1))
	multiplier.text = "Multiplier: " +  str(snappedf(GameState.multiplier,0.1))


func _on_try_again_pressed() -> void:
	get_tree().paused = false
	end_screen.hide()
	EventBus.retry.emit()

func _on_quit_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file(GameState.MAIN_MENU_SCENE)

func show_end_screen(reason: String) -> void:
	end_reason.text = reason
	max_speed.text = "Max Speed Achieved: " + str(snappedi(GameState.terrain_velocity,1))
	total_distance.text = "Total Distance Travelled: " +  str(snappedi(GameState.distance,1))
	level.text = "Level: " + str(GameState.current_level+1)
	if GameState.multiplier != 0:
		GameState.score = snappedi((GameState.distance * GameState.multiplier),1)
	else:
		GameState.score = snappedi((GameState.distance),1)
	score.text = "Score: " + str(GameState.score)
	if !GameState.debug_enabled:
		if GameState.score > GameState.best:
			var scores = SilentWolf.Scores.save_score(GameState.player_name, GameState.score)
			GameState.best = GameState.score
			GameState.best_id = scores.score_id
	
	GameState.set_and_save()
	end_screen.show()
	try_again.grab_focus()
	
