extends Control

signal level_changed(level_name)

export (String) var level_name

onready var resume_button = self.get_child(0).get_child(0).get_child(0).get_child(0).get_child(1);

func _ready():
	resume_button.grab_focus()
	self.get_child(0).hide()

func _on_BackToMenuButton_pressed():
	emit_signal("level_changed", level_name)

func _on_ResumeButton_pressed():
	self.visible = false
