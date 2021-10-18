extends Control

var current_level_number

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
	"levels_best_time" : [],
	"current_level" : 0
}
var data = {}

# onready variablessss...
onready var lose_ui = get_child(0).get_child(0)
onready var win_ui = get_child(0).get_child(1)
onready var win_lose_ani_player = get_child(0).get_child(2)
onready var audio_manager = $WinLoseAudioNode

func _ready():
	load_data()
	lose_ui.hide()
	win_ui.hide()

func handle_game_over():
	if(lose_ui.visible == false):
		get_parent().get_tree().paused = true
		audio_manager.play_death_bgm()
		lose_ui.show()
		lose_ui.get_child(0).get_child(1).grab_focus()
		win_lose_ani_player.play("game_over_intro")
		
func handle_win():
	load_data()
	current_level_number = data["current_level"]
	save_level_data(current_level_number)
	if(win_ui.visible == false):
		get_parent().get_tree().paused = true
		win_ui.show()
		win_ui.get_child(0).get_child(1).grab_focus()
		win_lose_ani_player.play("victory_bounce")

func _on_RetryLevelButton_pressed():
	load_data()
	current_level_number = data["current_level"]
	if(current_level_number == 1):
		save_current_level(1)
		get_parent().change_level("level1")
	if(current_level_number == 2):
		save_current_level(2)
		get_parent().change_level("level2")

func _on_BackToMenuButton_pressed():
	get_parent().change_level("menu")

func _on_NextLevelButton_pressed():
	load_data()
	current_level_number = data["current_level"]
	if(current_level_number == 1):
		save_current_level(2)
		get_parent().change_level("level2")
	if(current_level_number == 2):
		save_current_level(0)
		get_parent().change_level("credits")
	
# File related functions
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
	
func save_level_data(level_number):
	print("current level num: " + str(current_level_number))
	var levels_array = data["levels_completed"]
	var array = []
	for value in data["levels_completed"]:
		print("current val: " + str(value))
		array.push_back(value)
	print("array: " + str(array))
		
	print("is current level inside array?: " + str(array.has(level_number)))
	if(not array.has(level_number)):
		var file = File.new()
		
		file.open(path, File.WRITE)
		
		array.push_back(level_number)
		data["levels_completed"] = array
	
		file.store_line(to_json(data))
	
		file.close()
	
func save_current_level(current_level_number):
	var file = File.new()
	
	file.open(path, File.WRITE)
	
	data["current_level"] = current_level_number
	
	file.store_line(to_json(data))
	
	file.close()
