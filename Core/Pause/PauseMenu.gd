extends Control

export (String) var level_name

var is_paused = false

onready var resume_button = self.get_child(0).get_child(0).get_child(0).get_child(1);
onready var ui_view = self.get_child(0).get_child(0)

func _ready():
	print("pause setup")
	resume_button.grab_focus()
	ui_view.hide()

func _on_BackToMenuButton_pressed():
	get_parent().change_level(level_name)

func _on_ResumeButton_pressed():
	ui_view.hide()
	get_tree().paused = false
	
func handle_pause():
	print("Player entered pause script (should be paused right now)")
	if(get_parent().get_tree().paused == true):
		get_parent().get_tree().paused = false
		ui_view.visible = false
	else:
		get_parent().get_tree().paused = true
		ui_view.visible = true


func _on_PauseMenuControl_tree_entered():
	print("pause menu entered tree")
