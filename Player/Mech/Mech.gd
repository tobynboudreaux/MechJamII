extends KinematicBody

onready var animation_tree = $AnimationTree

onready var to_pilot_timer = get_node("Timers/ToPilotTimer")
var pilot_scene = preload("res://Player/Pilot/Pilot.tscn").instance()

var camera

func _physics_process(delta):
	if Input.is_action_just_pressed("test"):
		camera = get_parent().get_node("Camera")
		var pilot = get_parent().get_node("Pilot")
		pilot.show()
		pilot.transform = self.transform
		animation_tree["parameters/IsShutdown/blend_amount"] = 1
		print("Did you see that??")
		camera.set_current_target("pilot")
