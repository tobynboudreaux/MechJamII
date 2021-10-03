extends Node

# Variables for loading data on startup
var path = "res://data.json"
var default_data = {
	"options" : {
		"graphics" : "Good",
		"fullscreen" : "off",
		"resolution" : 100,
		"aa" : "fxaa",
		"vsync" : "off"
	},
	"levels_completed" : [],
	"levels_best_time" : []
}
var data = {}

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
	
func save_options_data(key, new_value):
	var file = File.new()
	
	file.open(path, File.WRITE)
	
	data["options"][key] = new_value
	
	file.store_line(to_json(data))
	
	file.close()
	
func save_level_data(level_number, level_time):
	var file = File.new()
	
	file.open(path, File.WRITE)
	
	if(not data["levels_completed"].has(level_number)):
		data["levels_completed"].push_back(level_number)
	
	var current_level_index = data["levels_completed"].find(level_number)
	if(data["levels_best_time"][current_level_index] < level_time):
		data["levels_best_time"][current_level_index] = level_time
	
	file.store_line(to_json(data))
	
	file.close()
