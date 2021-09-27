extends Node

# Global variables
var next_level

# Ready variables
onready var current_level = $StartScreen
onready var anim_player = $AnimationPlayer
onready var world_env = $WorldEnvironment
onready var orig_render_res = get_tree().root.size

# Called when the node enters the scene tree for the first time.
func _ready():
	current_level.connect("level_changed", self, "handle_level_changed")
	current_level.connect("set_options", self, "handle_options")

func handle_level_changed(current_level_name: String):
	var next_level_path: String
	
	match current_level_name:
		"menu":
			# Load main game level
			next_level_path = "res://World/World.tscn"
		"level1":
			# Load menu level
			next_level_path = "res://Core/StartScreen/StartScreen.tscn"
		_:
			return
	
	next_level = load(next_level_path).instance();
	add_child(next_level)
	anim_player.play("Transition_In")
	
	next_level.connect("level_changed", self, "handle_level_changed")
	

func _on_AnimationPlayer_animation_finished(anim_name):
	match anim_name:
		"Transition_In":
			current_level.queue_free()
			current_level = next_level
			next_level = null
			anim_player.play("Transition_Out")
			
func handle_options(key, value):
	if(key == "graphics"):
		if(value == "Good"):
			OS.window_size = orig_render_res
			world_env.environment.dof_blur_far_enabled = true
			world_env.environment.glow_enabled = true
			world_env.environment.ss_reflections_enabled = true
		if(value == "LOL"):
			OS.window_size = Vector2(orig_render_res.x/2,orig_render_res.y/2)
			world_env.environment.dof_blur_far_enabled = false
			world_env.environment.glow_enabled = false
			world_env.environment.ss_reflections_enabled = false
	if(key == "fullscreen"):
		if(value == "on"):
			OS.window_fullscreen = true
		if(value == "off"):
			OS.window_fullscreen = false
