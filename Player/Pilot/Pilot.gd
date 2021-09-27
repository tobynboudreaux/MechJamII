extends "res://Player/Player.gd"

export var MAX_SPEED = 15
export var ACCEL = 3
export var DASH_SPEED = 50

export var DEACCEL = 16
export var MAX_SLOPE_ANGLE = 40

var rotation_helper

var p = preload("res://Player/Projectile/Projectile.tscn").instance()
export var DEFAULT_MAG_SIZE = 7
var mag_size

onready var animation_tree = $AnimationTree

# Timers
onready var fire_timer = get_node("Timers/FireTimer")
onready var reload_timer = get_node("Timers/ReloadTimer")
onready var dash_timer = get_node("Timers/DashTimer")
onready var sword_timer = get_node("Timers/SwordTimer")
onready var footstep_timer = get_node("Timers/FootstepTimer")
onready var to_mech_timer = get_node("Timers/ToMechTimer")

# Sounds
onready var sword_sounds = [
	get_node("Rotation_Helper/MechJam_Player/rig/Skeleton/Player/Sounds/Sword1"),
	get_node("Rotation_Helper/MechJam_Player/rig/Skeleton/Player/Sounds/Sword2"),
	get_node("Rotation_Helper/MechJam_Player/rig/Skeleton/Player/Sounds/Sword3")
]
onready var pistol_sounds = [
	get_node("Rotation_Helper/MechJam_Player/rig/Skeleton/Player/Sounds/Pistol1"),
	get_node("Rotation_Helper/MechJam_Player/rig/Skeleton/Player/Sounds/Pistol2"),
	get_node("Rotation_Helper/MechJam_Player/rig/Skeleton/Player/Sounds/Pistol3"),
	get_node("Rotation_Helper/MechJam_Player/rig/Skeleton/Player/Sounds/Pistol4")
]

onready var pistol_reload_sounds = [
	get_node("Rotation_Helper/MechJam_Player/rig/Skeleton/Player/Sounds/PistolReload1"),
	get_node("Rotation_Helper/MechJam_Player/rig/Skeleton/Player/Sounds/PistolReload2"),
	get_node("Rotation_Helper/MechJam_Player/rig/Skeleton/Player/Sounds/PistolReload3")
]

onready var dash_sounds = [
	get_node("Rotation_Helper/MechJam_Player/rig/Skeleton/Player/Sounds/Dash1"),
	get_node("Rotation_Helper/MechJam_Player/rig/Skeleton/Player/Sounds/Dash2"),
	get_node("Rotation_Helper/MechJam_Player/rig/Skeleton/Player/Sounds/Dash3")
]

onready var footstep_sounds = [
	get_node("Rotation_Helper/MechJam_Player/rig/Skeleton/Player/Sounds/Footstep1"),
	get_node("Rotation_Helper/MechJam_Player/rig/Skeleton/Player/Sounds/Footstep2"),
	get_node("Rotation_Helper/MechJam_Player/rig/Skeleton/Player/Sounds/Footstep3"),
	get_node("Rotation_Helper/MechJam_Player/rig/Skeleton/Player/Sounds/Footstep4")
]

var input_movement_vector
onready var hud = get_node("HUD")

func _ready():
	rotation_helper = $Rotation_Helper
	$HUD.hide()
	$CollisionShape.disabled = true
	
	# ----------------------------------
	# Ammunition SET
	mag_size = DEFAULT_MAG_SIZE
	p.set_vars(65, Vector3.DOWN * 10)
	
func _process(delta):
	if(!is_mech):
		$HUD.show()
		$HUD.update_dash_timer(dash_timer.time_left)
		$HUD.update_reload_timer(reload_timer.time_left)
			
		if Input.is_action_just_released("interact"):
			var mech = get_parent().get_node("Mech")
			mech.transform = self.transform
			print("Did you see that??")
			self.hide()
			self.get_node("CollisionShape").disabled = true
			camera.set_current_target("mech")
			set_mech(true)
			mech.to_pilot_timer.start()
			mech.hud.show()
			mech.is_mech = true
			mech.animation_tree["parameters/Transition/current"] = 0
			mech.animation_tree["parameters/IsShutdown/blend_amount"] = 0
			$HUD.hide()

func _physics_process(delta):
	if(!is_mech):
		input_movement_vector = process_input()
		process_movement(delta, MAX_SPEED, MAX_SLOPE_ANGLE, ACCEL, DEACCEL)
		process_pilot_input()
		process_animations()
		animation_tree["parameters/Walk/blend_position"] = process_camera_rotation(rotation_helper)
	
func process_pilot_input():
	# ----------------------------------
	# Dash
	if Input.is_action_just_pressed("dash") && dash_timer.time_left == 0:
		vel.x = input_movement_vector.x * DASH_SPEED
		vel.z = -input_movement_vector.y * DASH_SPEED
		vel.y = 2
		animation_tree["parameters/IsItDashing/active"] = true
		dash_timer.start()
		var random_sound = randi() % 3
		dash_sounds[random_sound].play()
	# ----------------------------------
	
	# ----------------------------------
	# Melee
	if Input.is_action_just_pressed("melee") && sword_timer.time_left == 0:
		print("SWING")
		animation_tree["parameters/IsItSlicing/active"] = true
		var random_sound = randi() % 3
		sword_sounds[random_sound].play()
		sword_timer.start()
	# ----------------------------------
	
	
	if Input.is_action_just_pressed("reload") && is_reloading == false && mag_size < DEFAULT_MAG_SIZE:
		is_reloading = true
		mag_size = DEFAULT_MAG_SIZE
		reload_timer.start()
		var random_sound = randi() % 3
		pistol_reload_sounds[random_sound].play()
			
	if reload_timer.time_left == 0:
		is_reloading = false
		$HUD.update_ammo_val(str(mag_size) + "/" + str(DEFAULT_MAG_SIZE))
	# ----------------------------------
	
	# ----------------------------------		
	# Shoot
	if Input.is_action_pressed("fire") && mag_size > 0 && fire_timer.time_left == 0 && is_reloading != true:
		get_parent().add_child(p)
		p.transform = $Rotation_Helper/MechJam_Player/rig/Skeleton/Pistol/WeaponMuzzle.global_transform
		p.velocity = -p.transform.basis.z * p.muzzle_velocity
	# ----------------------------------
			
func process_animations():
	if Input.is_action_pressed("fire") && mag_size > 0 && fire_timer.time_left == 0 && is_reloading != true:
		animation_tree["parameters/IsItShooting/blend_amount"] = 1
		var random_sound = randi() % 4
		pistol_sounds[random_sound].play()
		mag_size -= 1
		$HUD.update_ammo_val(str(mag_size) + "/" + str(DEFAULT_MAG_SIZE))
		fire_timer.start()
	elif Input.is_action_pressed("fire") && mag_size == 0 && fire_timer.time_left == 0 && is_reloading != true:
		animation_tree["parameters/IsItShooting/blend_amount"] = 1
		$Rotation_Helper/MechJam_Player/rig/Skeleton/Player/Sounds/PistolDry.play()
		fire_timer.start()
	elif Input.is_action_just_released("fire") || is_reloading == true:
		animation_tree["parameters/IsItShooting/blend_amount"] = 0
	elif vel != Vector3(0,0,0):
		animation_tree["parameters/Transition/current"] = 1
	else:
		animation_tree["parameters/Transition/current"] = 0

	if is_moving_back && footstep_timer.time_left == 0 || is_moving_forward && footstep_timer.time_left == 0 || is_moving_left && footstep_timer.time_left == 0 || is_moving_right && footstep_timer.time_left == 0:
		var random_sound = randi() % 4
		footstep_sounds[random_sound].play()
		footstep_timer.start()
