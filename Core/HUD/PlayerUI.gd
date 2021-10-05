extends Control

signal level_changed(level_name)

onready var mech_hud = $MechHUD
onready var pilot_hud = $PilotHUD
onready var pause_menu = $PauseMenuControl
onready var win_lose_ui = $WinLoseUI
onready var lose_ui = $WinLoseUI/CanvasLayer/GameOverRect
onready var win_ui = $WinLoseUI/CanvasLayer/WinnerRect


func _ready():
	pass #ass
	
func change_level(level_name):
	print("should be changing level")
	emit_signal("level_changed", level_name)
	
# Triggered function by the player.gd script
func handle_pause():
	if(lose_ui.visible == false and win_ui.visible == false):
		pause_menu.handle_pause()
	
func handle_mech_hud():
	mech_hud.visible = !mech_hud.visible
	
func handle_player_lose():
	win_lose_ui.handle_game_over()
