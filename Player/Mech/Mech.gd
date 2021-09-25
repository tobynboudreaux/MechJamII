extends "res://Player/Player.gd"
#
onready var animation_tree = $AnimationTree
#
#onready var to_pilot_timer = get_node("Timers/ToPilotTimer")
#var pilot_scene = preload("res://Player/Pilot/Pilot.tscn").instance()
#
##var camera
#
#func _physics_process(delta):
#	if Input.is_action_just_pressed("test"):
#		camera = get_parent().get_node("Camera")
#		var pilot = get_parent().get_node("Pilot")
#		pilot.show()
#		pilot.transform = self.transform
#		animation_tree["parameters/IsShutdown/blend_amount"] = 1
#		print("Did you see that??")
#		camera.set_current_target("pilot")

export var MAX_SPEED = 15
export var ACCEL = 3

export var DEACCEL = 16
export var MAX_SLOPE_ANGLE = 40

var p = preload("res://Player/Projectile/Projectile.tscn").instance()
export var DEFAULT_MAG_SIZE = 7
var mag_size 

var input_movement_vector

onready var rotation_helper = $Rotation_Helper

# Timers
onready var fire_timer = get_node("Timers/FireTimer")
onready var reload_timer = get_node("Timers/ReloadTimer")
#onready var dash_timer = get_node("Timers/DashTimer")
#onready var sword_timer = get_node("Timers/SwordTimer")
#onready var footstep_timer = get_node("Timers/FootstepTimer")
onready var to_pilot_timer = get_node("Timers/ToPilotTimer")

onready var hud = get_node("HUD")

func _ready():
	animation_tree["parameters/IsShutdown/blend_amount"] = 1
	
	# ----------------------------------
	# Ammunition SET
	mag_size = DEFAULT_MAG_SIZE
	p.set_vars(65, Vector3.DOWN * 10)
	$HUD.hide()
	
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
			pilot.animation_tree["parameters/Transition/current"] = 0
			$HUD.hide()

		print(to_pilot_timer.time_left)	

func _physics_process(delta):
	if(is_mech):
		input_movement_vector = process_input()
		process_movement(delta, MAX_SPEED, MAX_SLOPE_ANGLE, ACCEL, DEACCEL)
		process_mech_input()
		process_animations()
		process_reload()
		animation_tree["parameters/Walk/blend_position"] = process_camera_rotation(rotation_helper)	

func process_mech_input():
	pass
	
func process_reload():
	if Input.is_action_just_pressed("reload") && is_reloading == false && mag_size < DEFAULT_MAG_SIZE:
		reload(DEFAULT_MAG_SIZE, mag_size, reload_timer)
#		var random_sound = randi() % 3
#		pistol_reload_sounds[random_sound].play()
	
func process_fire():
	if Input.is_action_pressed("fire") && mag_size > 0 && fire_timer.time_left == 0 && is_reloading != true:
		get_parent().add_child(p)
		p.transform = $Rotation_Helper/MechJam_Player/rig/Skeleton/Pistol/WeaponMuzzle.global_transform
		p.velocity = -p.transform.basis.z * p.muzzle_velocity
		
func process_animations():
	if Input.is_action_pressed("fire") && mag_size > 0 && fire_timer.time_left == 0 && is_reloading != true:
		animation_tree["parameters/IsShooting/blend_amount"] = 1
#		var random_sound = randi() % 4
#		pistol_sounds[random_sound].play()
		mag_size -= 1
		$HUD.update_ammo_val(str(mag_size) + "/" + str(DEFAULT_MAG_SIZE))
		fire_timer.start()
	elif Input.is_action_pressed("fire") && mag_size == 0 && fire_timer.time_left == 0 && is_reloading != true:
		animation_tree["parameters/IsShooting/blend_amount"] = 1
#		$Rotation_Helper/MechJam_Player/rig/Skeleton/Player/Sounds/PistolDry.play()
		fire_timer.start()
	elif Input.is_action_just_released("fire") || is_reloading == true:
		animation_tree["parameters/IsShooting/blend_amount"] = 0
	elif vel != Vector3(0,0,0):
		animation_tree["parameters/Transition/current"] = 1
	else:
		animation_tree["parameters/Transition/current"] = 0

#	if is_moving_back && footstep_timer.time_left == 0 || is_moving_forward && footstep_timer.time_left == 0 || is_moving_left && footstep_timer.time_left == 0 || is_moving_right && footstep_timer.time_left == 0:
#		var random_sound = randi() % 4
#		footstep_sounds[random_sound].play()
#		footstep_timer.start()
	
