extends Control

signal level_changed(level_name)

export (String) var level_name = "menu"

func _on_StartButton_pressed():
	emit_signal("level_changed", level_name)
