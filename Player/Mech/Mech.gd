extends "res://Player/Player.gd"

onready var animation_tree = $AnimationTree

export var MAX_SPEED = 15
export var ACCEL = 3

export var DEACCEL = 16
export var MAX_SLOPE_ANGLE = 40

var p = preload("res://Player/Projectile/Rocket/Rocket.tscn").instance()

var input_movement_vector

onready var rotation_helper = $Rotation_Helper

# Timers
onready var fire_timer = get_node("Timers/FireTimer")
onready var reload_timer = get_node("Timers/ReloadTimer")
#onready var dash_timer = get_node("Timers/DashTimer")
#onready var sword_timer = get_node("Timers/SwordTimer")
onready var footstep_timer = get_node("Timers/FootstepTimer")
onready var to_pilot_timer = get_node("Timers/ToPilotTimer")

onready var hud = get_node("HUD")

# Sounds
onready var footstep_sounds = [
	get_node("Rotation_Helper/MechJam_mech/rig/Skeleton/MechBody/Sounds/Footstep1"),
	get_node("Rotation_Helper/MechJam_mech/rig/Skeleton/MechBody/Sounds/Footstep2"),
	get_node("Rotation_Helper/MechJam_mech/rig/Skeleton/MechBody/Sounds/Footstep3"),
	get_node("Rotation_Helper/MechJam_mech/rig/Skeleton/MechBody/Sounds/Footstep4")
]

onready var gun_sounds = [
	get_node("Rotation_Helper/MechJam_mech/rig/Skeleton/MechBody/Sounds/Gun1"),
	get_node("Rotation_Helper/MechJam_mech/rig/Skeleton/MechBody/Sounds/Gun2"),
	get_node("Rotation_Helper/MechJam_mech/rig/Skeleton/MechBody/Sounds/Gun3"),
	get_node("Rotation_Helper/MechJam_mech/rig/Skeleton/MechBody/Sounds/Gun4")
]
func _ready():
	# ----------------------------------
	# Ammunition SET
	p.set_vars(65, Vector3.DOWN * 10)
	$HUD.hide()
	
	to_pilot_timer.start()
	
func _process(delta):
	if(is_mech):
#		$HUD.update_dash_timer(dash_timer.time_left)
#		$HUD.update_reload_timer(reload_timer.time_left)

		if to_pilot_timer.time_left == 0:
			var pilot = get_parent().get_node("Pilot")
			pilot.show()
			pilot.transform = self.transform
			animation_tree["parameters/IsShutdown/blend_amount"] = 1
			print("Did you see that??")
			camera.set_current_target("pilot")
			set_mech(false)
			pilot.hud.show()
			pilot.is_mech = false
			pilot.get_node("CollisionShape").disabled = false
			pilot.animation_tree["parameters/Transition/current"] = 0
			$HUD.hide()

		print(to_pilot_timer.time_left)	

func _physics_process(delta):
	if(is_mech):
		input_movement_vector = process_input()
		process_movement(delta, MAX_SPEED, MAX_SLOPE_ANGLE, ACCEL, DEACCEL)
		process_mech_input()
		process_animations()
		animation_tree["parameters/Walk/blend_position"] = process_camera_rotation(rotation_helper)	

func process_mech_input():
	# ----------------------------------		
	# Shoot
	if Input.is_action_pressed("fire") && fire_timer.time_left == 0:
		get_parent().add_child(p)
		$Rotation_Helper/MechJam_mech/rig/Skeleton/BoneAttachment/MechGun
		p.transform = $Rotation_Helper/MechJam_mech/rig/Skeleton/BoneAttachment/MechGun.global_transform
		p.velocity = p.transform.basis.z * p.muzzle_velocity
	# ----------------------------------
		
func process_animations():
	if Input.is_action_pressed("fire") && fire_timer.time_left == 0:
		animation_tree["parameters/IsShooting/blend_amount"] = 1
		var random_sound = randi() % 4
		gun_sounds[random_sound].play()
		fire_timer.start()
	elif Input.is_action_just_released("fire"):
		animation_tree["parameters/IsShooting/blend_amount"] = 0
	elif vel != Vector3(0,0,0):
		animation_tree["parameters/Transition/current"] = 1
	else:
		animation_tree["parameters/Transition/current"] = 0

	if is_moving_back && footstep_timer.time_left == 0 || is_moving_forward && footstep_timer.time_left == 0 || is_moving_left && footstep_timer.time_left == 0 || is_moving_right && footstep_timer.time_left == 0:
		var random_sound = randi() % 4
		footstep_sounds[random_sound].play()
		footstep_timer.start()
	
