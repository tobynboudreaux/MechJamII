extends Control

onready var mission_info_text = $InfoUICanvasLayer/CenterContainer/MissionInfo
onready var mission_info_ani_player = $MenuInfoAnimationPlayer

# Variables for loading data on startup
var path = "res://data.json"
var default_data = {
	"options" : {
		"graphics" : "Good",
		"fullscreen" : "off",
		"resolution" : 100.0,
		"aa" : "Off",
		"vsync" : "off"
	},
	"levels_completed" : [],
	"levels_best_time" : [],
	"current_level": 0
}
var data = {}

func _ready():
	load_data()
	if(data["current_level"] == 1):
		mission_info_text.text = "Mission 1: ERASE the alien drill bot!"
	if(data["current_level"] == 2):
		mission_info_text.text = "Mission 2: ERASE the evil alien aircraft!"
	mission_info_ani_player.play("mission_text_blink")
	
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
