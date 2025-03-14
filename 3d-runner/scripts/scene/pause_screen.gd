extends Control


func _on_button_pressed() -> void:
	_resume()

func _resume() -> void:
	hide()
	get_tree().paused = false
