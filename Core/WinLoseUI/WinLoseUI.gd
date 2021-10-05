extends Control

onready var lose_ui = get_child(0).get_child(0)
onready var win_ui = get_child(0).get_child(1)
onready var win_lose_ani_player = get_child(0).get_child(2)

func _ready():
	lose_ui.hide()
	win_ui.hide()

func handle_game_over():
	if(lose_ui.visible == false):
		get_parent().get_tree().paused = true
		lose_ui.show()
		lose_ui.get_child(0).get_child(1).grab_focus()
		win_lose_ani_player.play("game_over_intro")
		
func handle_win():
	if(win_ui.visible == false):
		get_parent().get_tree().paused = true
		win_ui.show()
		win_ui.get_child(0).get_child(1).grab_focus()

func _on_RetryLevelButton_pressed():
	print(get_parent())
	get_parent().change_level("menu")

func _on_BackToMenuButton_pressed():
	print(get_parent().get_parent().get_parent())
	get_parent().change_level("level1")
