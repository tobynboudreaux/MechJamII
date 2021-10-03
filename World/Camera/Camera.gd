extends Camera

onready var pilot = get_parent().get_node("Pilot")
onready var mech = get_parent().get_node("Mech")
onready var boss1 = get_parent().get_node("Level 1/Boss/Cone001")
onready var boss2 = get_parent().get_node("MechJam_Boss2")
var speed : float = 10
var current_target = "mech"

export var y_def = 10
export var z_def = 6.5

export var boss_1_y = 14
export var boss_1_z = 10.5

export var boss_2_y = 30
export var boss_2_z = 26.5
	
func _process(delta):
	if current_target == "pilot":
		position_camera(delta, pilot, y_def, z_def)
	
	if current_target == "mech":
		position_camera(delta, mech, y_def, z_def)
		
	if current_target == "boss_1":
		position_camera(delta, boss1, y_def, z_def)
		
	if current_target == "boss_2":
		position_camera(delta, boss2, y_def, z_def)
		
	if current_target == "boss_battle_1":
		position_camera(delta, pilot, boss_1_y, boss_1_z)
		
	if current_target == "boss_battle_2":
		position_camera(delta, pilot, boss_2_y, boss_2_z)

func position_camera(delta, target, y, z):
	global_transform.origin = lerp(global_transform.origin, target.global_transform.origin + Vector3(0,y,z), delta*speed)
	rotation = Vector3(-45, 0, 0)

func set_current_target(target):
	current_target = target
