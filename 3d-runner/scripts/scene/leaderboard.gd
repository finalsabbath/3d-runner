extends Control

const DEFAULT_THEME = preload("res://assets/themes/default_theme.tres")

@onready var players_container: VBoxContainer = %PlayersContainer
@onready var scores_container: VBoxContainer = %ScoresContainer
@onready var return_menu: Button = $ReturnMenu

var sw_result: Dictionary

func _ready() -> void:
	pass

func _on_return_menu_pressed() -> void:
	hide()

func _clear_scoreboard() -> void:
	var old_scores = get_tree().get_nodes_in_group("scores")
	for old_score in old_scores:
		old_score.queue_free()

func populate_scores()-> void:
	_clear_scoreboard()
	sw_result = await SilentWolf.Scores.get_scores().sw_get_scores_complete
	for score in sw_result.scores:
		var new_score_label = Label.new()
		var new_player_label = Label.new()
		new_score_label.text =  str(score.player_name)
		new_player_label.text = str(score.score)
		new_player_label.theme = DEFAULT_THEME
		new_score_label.theme = DEFAULT_THEME
		if score.player_name == GameState.player_name:
			new_player_label.add_theme_color_override("font_color",Color.ORANGE)
			new_score_label.add_theme_color_override("font_color",Color.ORANGE)
		new_score_label.add_to_group("scores")
		new_player_label.add_to_group("scores")
		scores_container.add_child(new_score_label)
		players_container.add_child(new_player_label)
