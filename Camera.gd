extends Camera

onready var pilot = get_parent().get_node("Pilot")
onready var mech = get_parent().get_node("Mech")
var speed : float = 10
var current_target

func _ready():
	current_target = "pilot"
	
func _process(delta):
	if current_target == "pilot":
		position_camera(delta, pilot)
	
	if current_target == "mech":
		position_camera(delta, mech)

func position_camera(delta, target):
	global_transform.origin = lerp(global_transform.origin, target.global_transform.origin + Vector3(0,14,10), delta*speed)
	rotation = Vector3(-45, 0, 0)

func set_current_target(target):
	current_target = target
