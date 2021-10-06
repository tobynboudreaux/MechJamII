extends Control

signal level_changed(level_name)

onready var mech_hud = $MechHUD
onready var pilot_hud = $PilotHUD
onready var pause_menu = $PauseMenuControl
onready var win_lose_ui = $WinLoseUI
onready var lose_ui = $WinLoseUI/CanvasLayer/GameOverRect
onready var win_ui = $WinLoseUI/CanvasLayer/WinnerRect
onready var path = "res://data.json"
onready var default_data = {
	"options" : {
		"graphics" : "Good",
		"fullscreen" : "off",
		"resolution" : 100.0,
		"aa" : "FXAA",
		"vsync" : "off"
	},
	"levels_completed" : [],
	"levels_best_time" : [],
	"current_level": 0
}
onready var data
onready var current_level_number

func _ready():
	load_data()
	if(data["current_level"] == 1):
		current_level_number = 1
	if(data["current_level"] == 2):
		current_level_number = 2
	
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
	
func handle_player_win():
	win_lose_ui.handle_win()
	
func load_data():
	var file = File.new()
	
	if not file.file_exists(path):
		file.open(path, File.WRITE)
	
		data = default_data.duplicate(true)
	
		file.store_line(to_json(data))
	
		return data
	
	file.open(path, file.READ)
	
	var text = file.get_as_text()
	
	data = parse_json(text)
	
	file.close()
	
	return data
