extends Control

const DEFAULT_THEME = preload("res://themes/default_theme.tres")

@onready var players_container: VBoxContainer = %PlayersContainer
@onready var scores_container: VBoxContainer = %ScoresContainer
@onready var return_menu: Button = $ReturnMenu


func _ready() -> void:
	return_menu.grab_focus()
	if not GameState.setup_complete:
		GameState.setup_game()
	var sw_result: Dictionary = await SilentWolf.Scores.get_scores().sw_get_scores_complete
	
	for score in sw_result.scores:
		var new_score_label = Label.new()
		var new_player_label = Label.new()
		new_score_label.text =  str(score.player_name)
		new_player_label.text = str(score.score)
		new_player_label.theme = DEFAULT_THEME
		new_score_label.theme = DEFAULT_THEME
		scores_container.add_child(new_score_label)
		players_container.add_child(new_player_label)


func _on_return_menu_pressed() -> void:
	hide()
