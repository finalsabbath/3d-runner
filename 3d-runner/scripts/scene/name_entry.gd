extends Control

@onready var name_entry: LineEdit = $Panel/NameEntry

func _on_ok_pressed() -> void:
	if _validate_name(name_entry.text):
		GameState.player_name = name_entry.text
		GameState.set_and_save()
		hide()

func _validate_name(name_entered: String) -> bool:
	# do something here to try to weed out inapproprate language
	return true
