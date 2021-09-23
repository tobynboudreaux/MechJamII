extends Node

# Global variables
var next_level

# Ready variables
onready var current_level = $StartScreen
onready var anim_player = $AnimationPlayer


# Called when the node enters the scene tree for the first time.
func _ready():
	current_level.connect("level_changed", self, "handle_level_changed")

func handle_level_changed(current_level_name: String):
	var next_level_path: String
	
	match current_level_name:
		"menu":
			# Load main game level
			next_level_path = "res://Levels/Level1.tscn"
		"level1":
			# Load menu level
			next_level_path = "res://StartScreen/StartScreen.tscn"
		_:
			return
	
	next_level = load(next_level_path).instance();
	add_child(next_level)
	anim_player.play("Transition_In")
	print("current level: ",current_level)
	print("next level: ",next_level)
	
	next_level.connect("level_changed", self, "handle_level_changed")
	#current_level = next_level
	

func _on_AnimationPlayer_animation_finished(anim_name):
	match anim_name:
		"Transition_In":
			current_level.queue_free()
			current_level = next_level
			next_level = null
			anim_player.play("Transition_Out")
