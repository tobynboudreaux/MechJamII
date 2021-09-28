extends Control

signal level_changed(level_name)
signal set_options(key, value)

export (String) var level_name = "menu"

# Needed for animations and focus
onready var menu_container = self.get_child(0)
onready var levels_container = self.get_child(1)
onready var options_container = self.get_child(2)
onready var start_button = menu_container.get_child(1)
onready var continue_button = menu_container.get_child(2)
onready var prev_levels_button = menu_container.get_child(3)

onready var anim_player = get_node("3DMenuWorld/MenuAnimationPlayer")
onready var pilot_anim_player = get_node("3DMenuWorld/PilotNode/MechJam_Player/AnimationPlayer")

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

var is_fullscreen = false

func _ready():
	load_data()
	setup_options()
	
	if(data["levels_completed"] == []):
		start_button.grab_focus()
	else:
		start_button.visible = false
		continue_button.visible = true
		prev_levels_button.visible = true
		continue_button.grab_focus()
	
	levels_container.visible = false
	anim_player.play("Camera_Pan")
	pilot_anim_player.play("01_Idle")

# Main menu code
func _on_StartButton_pressed():
	emit_signal("level_changed", level_name)

func _on_QuitButton_pressed():
	get_tree().quit()

func _on_ContinueButton_pressed():
	var levels_completed = data["levels_completed"].size()
	if(levels_completed == 1):
		emit_signal("level_changed", level_name)
	
# Previous level menu code
func _on_PrevLevelsButton_pressed():
	menu_container.visible = false
	levels_container.visible = true
	levels_container.get_child(0).grab_focus()
	
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
	emit_signal("set_options", "resolution", resolution_slider.value)
	
	var res_label = options_container.get_child(0)
	res_label.text = "Resolution Scale (" + str(resolution_slider.value) + "%)"
	
	var graphics_dropdown = options_container.get_child(3)
	graphics_dropdown.add_item("Good")
	graphics_dropdown.add_item("LOL")
	if(data["options"]["graphics"] == "Good"):
		graphics_dropdown.select(0)
		emit_signal("set_options", "graphics", "Good")
	if(data["options"]["graphics"] == "LOL"):
		graphics_dropdown.select(1)
		emit_signal("set_options", "graphics", "LOL")
	
	var aa_dropdown = options_container.get_child(5)
	aa_dropdown.add_item("Off")
	aa_dropdown.add_item("FXAA")
	aa_dropdown.add_item("MSAA x4")
	if(data["options"]["aa"] == "Off"):
		graphics_dropdown.select(0)
		emit_signal("set_options", "aa", "Off")
	if(data["options"]["aa"] == "FXAA"):
		graphics_dropdown.select(1)
		emit_signal("set_options", "aa", "FXAA")
	if(data["options"]["aa"] == "MSAA x4"):
		graphics_dropdown.select(2)
		emit_signal("set_options", "aa", "MSAA x4")
		
	var fullscreen_button = options_container.get_child(6)
	if(data["options"]["fullscreen"] == "on"):
		emit_signal("set_options", "fullscreen", "on")
		fullscreen_button.pressed = true
		is_fullscreen = true
	if(data["options"]["fullscreen"] == "off"):
		emit_signal("set_options", "fullscreen", "off")
		fullscreen_button.pressed = false
		is_fullscreen = false
	
	var vsync_button = options_container.get_child(7)
	if(is_fullscreen):
		vsync_button.disabled = false
		if(data["options"]["vsync"] == "on"):
			emit_signal("set_options", "vsync", "on")
		if(data["options"]["vsync"] == "off"):
			emit_signal("set_options", "vsync", "off")
	else:
		vsync_button.disabled = true
	
func _on_ResolutionHSlider_value_changed(value):
	var new_val
	if (value < 50):
		new_val = 50
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
