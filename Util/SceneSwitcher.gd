extends Node

# Global variables
var next_level_3d
var next_level_ui
var next_level_3d_path
var next_level_ui_path
#var player_ui #needs to be preloaded in order for player to connect to it
var player_ui_current_instance

# Ready variables
onready var current_level_ui = $MainMenuUI
onready var current_level_3d = $ViewportContainer3D/Viewport3D/MenuWorld3D
onready var anim_player = $AnimationPlayer
onready var viewport_container_3d = $ViewportContainer3D
onready var viewport_3d = $ViewportContainer3D/Viewport3D
onready var world_env = $ViewportContainer3D/Viewport3D/WorldEnvironment
onready var fullscreen_max_res = OS.get_screen_size()
onready var window_max_res = OS.window_size
onready var is_fullscreen = false
onready var current_max_res = fullscreen_max_res

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

# Called when the node enters the scene tree for the first time.
func _ready():
	# Gather resource packs
	ProjectSettings.load_resource_pack("res://graphics.pck")
	ProjectSettings.load_resource_pack("res://audio.pck")
#	player_ui = preload("res://Core/HUD/PlayerUI.tscn")
	
	current_level_ui.connect("level_changed", self, "handle_level_changed")
	current_level_ui.connect("set_options", self, "handle_options")

	# Load from data.json to set the graphics options
	load_data()
	
	if(data["options"]["graphics"] == "Good"):
		handle_options("graphics","Good")
	if(data["options"]["graphics"] == "LOL"):
		handle_options("graphics","LOL")
	
	if(data["options"]["aa"] == "Off"):
		handle_options("aa","Off")
	if(data["options"]["aa"] == "FXAA"):
		handle_options("aa","FXAA")
	if(data["options"]["aa"] == "MSAA x4"):
		handle_options("aa","MSAA x4")
		
	if(data["options"]["fullscreen"] == "on"):
		is_fullscreen = true
		handle_options("fullscreen","on")
	if(data["options"]["fullscreen"] == "off"):
		is_fullscreen = false
		handle_options("fullscreen","off")
	
	if(data["options"]["vsync"] == "on"):
		handle_options("vsync", "on")
	if(data["options"]["vsync"] == "off"):
		handle_options("vsync", "off")
		
	set_screen_max_resolution()
	handle_options("resolution", data["options"]["resolution"])
	
func connect_player(player_instance):
	print("player connected to player UI")
#	player_instance.connect("set_pause", player_ui_current_instance, "handle_pause")
#	player_instance.connect("set_mech_hud", player_ui_current_instance, "handle_mech_hud")
	
func set_screen_max_resolution():
	if(is_fullscreen):
		get_viewport().size = fullscreen_max_res
		current_max_res = fullscreen_max_res
	else:
		get_viewport().size = window_max_res
		current_max_res = window_max_res
		
func set_environment_for_level():
	world_env.environment.dof_blur_far_distance = 19
	world_env.environment.dof_blur_far_transition = 8.67
	
func set_environment_for_menu():
	world_env.environment.dof_blur_far_distance = 1.4
	world_env.environment.dof_blur_far_transition = 5
	
func handle_level_changed(current_level_name: String):
	
	match current_level_name:
		"menu":
			# Load main game level
			next_level_3d_path = "res://World/World1/World1.tscn"
			next_level_ui_path = "res://Core/Pause/PauseMenu.tscn"
			
		"level1":
			# Load menu level
			next_level_3d_path = "res://Core/StartScreen/MenuWorld3D.tscn"
			next_level_ui_path = "res://Core/StartScreen/MainMenuUI.tscn"
		"level2":
			# Load next level
			next_level_3d_path = "res://World/World2/World2.tscn"
			next_level_ui_path = "res://Core/Pause/PauseMenu.tscn"
		_:
			return
	
	anim_player.play("Transition_In")

func _on_AnimationPlayer_animation_finished(anim_name):
	match anim_name:
		"Transition_In":
			next_level_3d = load(next_level_3d_path).instance()
			if(next_level_ui_path != "res://Core/Pause/PauseMenu.tscn"):
				next_level_ui = load(next_level_ui_path).instance()
#				player_ui_current_instance = null
				next_level_ui.connect("set_options", self, "handle_options")
			else:
				pass
#				player_ui_current_instance = player_ui.instance()
#				next_level_ui = player_ui_current_instance
				
			next_level_ui.connect("level_changed", self, "handle_level_changed")
			
			viewport_3d.add_child(next_level_3d)
			self.add_child(next_level_ui)
			
			if(next_level_3d_path == "res://World/World1/World1.tscn"):
				set_environment_for_level()
			if(next_level_3d_path == "res://Core/StartScreen/MenuWorld3D.tscn"):
				set_environment_for_menu()
			if(next_level_3d_path == "res://World/World2/World2.tscn"):
				set_environment_for_level()
				
			get_tree().paused = false
			current_level_ui.queue_free()
			current_level_3d.queue_free()
			current_level_ui = next_level_ui
			current_level_3d = next_level_3d
			next_level_ui = null
			next_level_3d = null
			next_level_3d_path = ""
			next_level_ui_path = ""
			anim_player.play("Transition_Out")
			
func handle_options(key, value):
	if(key == "resolution"):
		if(value < 10):
			viewport_3d.size = current_max_res*0.1
			viewport_3d.get_texture().flags = 0
		if(value >= 10 and value < 110):
			viewport_3d.size = current_max_res*(value*0.01)
			viewport_3d.get_texture().flags = 0
		else:
			viewport_3d.size = current_max_res*1.2
			viewport_3d.get_texture().flags = Texture.FLAG_FILTER
	if(key == "graphics"):
		if(value == "Good"):
			world_env.environment.dof_blur_far_enabled = true
			world_env.environment.glow_enabled = true
			world_env.environment.ss_reflections_enabled = true
		if(value == "LOL"):
			world_env.environment.dof_blur_far_enabled = false
			world_env.environment.glow_enabled = false
			world_env.environment.ss_reflections_enabled = false
	if(key == "aa"):
		if(value == "Off"):
			viewport_3d.fxaa = false
			viewport_3d.msaa = Viewport.MSAA_DISABLED
		if(value == "FXAA"):
			viewport_3d.fxaa = true
			viewport_3d.msaa = Viewport.MSAA_DISABLED
		if(value == "MSAA x4"):
			viewport_3d.fxaa = false
			viewport_3d.msaa = Viewport.MSAA_4X
	if(key == "fullscreen"):
		if(value == "on"):
			is_fullscreen = true
			OS.set_window_fullscreen(true)
			set_screen_max_resolution()
			rerender_after_fullscreen()
		if(value == "off"):
			is_fullscreen = false
			OS.set_window_fullscreen(false)
			set_screen_max_resolution()
			rerender_after_fullscreen()
	if(key == "vsync"):
		if(value == "on"):
			OS.vsync_enabled = true
		if(value == "off"):
			OS.vsync_enabled = false
			
func rerender_after_fullscreen():
	yield(get_tree().create_timer(0.001), "timeout")
	handle_options("resolution", data["options"]["resolution"])
			
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
