extends Control

signal level_changed(level_name)
signal set_options(key, value)

# Needed for animations and focus
onready var menu_container = self.get_child(0)
onready var levels_container = self.get_child(1)
onready var options_container = self.get_child(2)
onready var start_button = menu_container.get_child(1)
onready var continue_button = menu_container.get_child(2)
onready var prev_levels_button = menu_container.get_child(3)

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

var is_fullscreen = false

func _ready():
	load_data()
	setup_options()
	setup_level_select()
	
	if(data["levels_completed"] == []):
		start_button.grab_focus()
	else:
		start_button.visible = false
		continue_button.visible = true
		prev_levels_button.visible = true
		continue_button.grab_focus()

# Main menu code
func _on_StartButton_pressed():
	emit_signal("level_changed", "level1")
	save_current_level(1)
	start_button.disabled = true

func _on_QuitButton_pressed():
	get_tree().quit()

func _on_ContinueButton_pressed():
	var levels_completed = data["levels_completed"].size()
	save_current_level(levels_completed+1)
	continue_button.disabled = true
	if(levels_completed == 1):
		emit_signal("level_changed", "level2")
	if(levels_completed == 2):
		emit_signal("level_changed", "credits")
	
	
# Previous level menu code
func setup_level_select():
	var levels_completed = data["levels_completed"].size()
	if(levels_completed == 1):
		levels_container.get_child(0).disabled = false
	if(levels_completed == 2):
		levels_container.get_child(0).disabled = false
		levels_container.get_child(1).disabled = false

func _on_PrevLevelsButton_pressed():
	menu_container.visible = false
	levels_container.visible = true
	levels_container.get_child(0).grab_focus()
	
func _on_Level1Button_pressed():
	emit_signal("level_changed", "level1")
	save_current_level(1)

func _on_Level2Button_pressed():
	emit_signal("level_changed", "level2")
	save_current_level(2)
	
func _on_LevelBackButton_pressed():
	levels_container.visible = false
	menu_container.visible = true
	if(data["levels_completed"] == []):
		start_button.grab_focus()
	else:
		continue_button.grab_focus()
	
# Options menu code
func _on_OptionsButton_pressed():
	menu_container.visible = false
	options_container.visible = true
	options_container.get_child(1).grab_focus()

func setup_options():
	var resolution_slider = options_container.get_child(1)
	resolution_slider.value = data["options"]["resolution"]
	
	var res_label = options_container.get_child(0)
	res_label.text = "Resolution Scale (" + str(resolution_slider.value) + "%)"
	
	var graphics_dropdown = options_container.get_child(3)
	graphics_dropdown.add_item("Good")
	graphics_dropdown.add_item("LOL")
	if(data["options"]["graphics"] == "Good"):
		graphics_dropdown.select(0)
	if(data["options"]["graphics"] == "LOL"):
		graphics_dropdown.select(1)
	
	var aa_dropdown = options_container.get_child(5)
	aa_dropdown.add_item("Off")
	aa_dropdown.add_item("FXAA")
	aa_dropdown.add_item("MSAA x4")
	if(data["options"]["aa"] == "Off"):
		graphics_dropdown.select(0)
	if(data["options"]["aa"] == "FXAA"):
		graphics_dropdown.select(1)
	if(data["options"]["aa"] == "MSAA x4"):
		graphics_dropdown.select(2)
		
	var fullscreen_button = options_container.get_child(6)
	if(data["options"]["fullscreen"] == "on"):
		fullscreen_button.pressed = true
		is_fullscreen = true
	if(data["options"]["fullscreen"] == "off"):
		fullscreen_button.pressed = false
		is_fullscreen = false
	
	var vsync_button = options_container.get_child(7)
	if(is_fullscreen):
		vsync_button.disabled = false
	else:
		vsync_button.disabled = true
	
func _on_ResolutionHSlider_value_changed(value):
	var new_val
	if (value < 10):
		new_val = 10
	else:
		new_val = value
	save_options_data("resolution", new_val)
	emit_signal("set_options", "resolution", new_val)
	
	var res_label = options_container.get_child(0)
	res_label.text = "Resolution Scale (" + str(new_val) + "%)"
	
func _on_GraphicsOptionButton_item_selected(index):
	if(index == 0):
		save_options_data("graphics", "Good")
		emit_signal("set_options", "graphics", "Good")
	if(index == 1):
		save_options_data("graphics", "LOL")
		emit_signal("set_options", "graphics", "LOL")
	
func _on_AAOptionButton_item_selected(index):
	if(index == 0):
		save_options_data("aa", "Off")
		emit_signal("set_options", "aa", "Off")
	if(index == 1):
		save_options_data("aa", "FXAA")
		emit_signal("set_options", "aa", "FXAA")
	if(index == 2):
		save_options_data("aa", "MSAA x4")
		emit_signal("set_options", "aa", "MSAA x4")
		
func _on_FullscreenButton_toggled(button_pressed):
	var vsync_button = options_container.get_child(7)
	if(button_pressed):
		save_options_data("fullscreen", "on")
		emit_signal("set_options", "fullscreen", "on")
		is_fullscreen = true
		vsync_button.disabled = false
	else:
		save_options_data("fullscreen", "off")
		emit_signal("set_options", "fullscreen", "off")
		is_fullscreen = false
		vsync_button.disabled = true
		
func _on_VsyncButton_toggled(button_pressed):
	if(button_pressed and is_fullscreen):
		save_options_data("vsync", "on")
		emit_signal("set_options", "vsync", "on")
	if(not button_pressed and is_fullscreen):
		save_options_data("vsync", "off")
		emit_signal("set_options", "vsync", "off")

func _on_OptionsBackButton_pressed():
	options_container.visible = false
	menu_container.visible = true
	if(data["levels_completed"] == []):
		start_button.grab_focus()
	else:
		continue_button.grab_focus()
		
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
	
func save_current_level(current_level_number):
	var file = File.new()
	
	file.open(path, File.WRITE)
	
	data["current_level"] = current_level_number
	
	file.store_line(to_json(data))
	
	file.close()


func _on_How2PlayButton_pressed():
	emit_signal("level_changed", "tutorial")
