extends Control

var current_level_number = 1

# Variables for loading data on startup
var path = "res://data.json"
var default_data = {
	"options" : {
		"graphics" : "Good",
		"fullscreen" : "off",
		"resolution" : 100.0,
		"aa" : "FXAA",
		"vsync" : "off"
	},
	"levels_completed" : [],
	"levels_best_time" : []
}
var data = {}

# onready variablessss...
onready var lose_ui = get_child(0).get_child(0)
onready var win_ui = get_child(0).get_child(1)
onready var win_lose_ani_player = get_child(0).get_child(2)
onready var audio_manager = $WinLoseAudioNode

func _ready():
	lose_ui.hide()
	win_ui.hide()

func handle_game_over():
	if(lose_ui.visible == false):
		get_parent().get_tree().paused = true
		audio_manager.play_death_bgm()
		lose_ui.show()
		lose_ui.get_child(0).get_child(1).grab_focus()
		win_lose_ani_player.play("game_over_intro")
		
func handle_win(current_level_from_player_ui):
	if(win_ui.visible == false):
		current_level_number = current_level_from_player_ui
		get_parent().get_tree().paused = true
		win_ui.show()
		win_ui.get_child(0).get_child(1).grab_focus()

func _on_RetryLevelButton_pressed():
	get_parent().change_level("level1")

func _on_BackToMenuButton_pressed():
	get_parent().change_level("menu")

func _on_NextLevelButton_pressed():
	if(current_level_number == 1):
		save_level_data(1, 100)
		get_parent().change_level("level2")
	if(current_level_number == 2):
		save_level_data(2, 100)
		get_parent().change_level("menu") #TODO: should send to credits screen -> menu
	
func save_level_data(level_number, level_time):
	var file = File.new()
	
	file.open(path, File.WRITE)
	
	if(data["levels_completed"].size() > 0):
		if(not data["levels_completed"].has(level_number)):
			data["levels_completed"].push_back(level_number)
	else:
		data["levels_completed"].push_back(level_number)
	
	var current_level_index = data["levels_completed"].find(level_number)
	if(data["levels_best_time"][current_level_index] < level_time):
		data["levels_best_time"][current_level_index] = level_time
	
	file.store_line(to_json(data))
	
	file.close()
