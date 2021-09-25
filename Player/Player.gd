extends KinematicBody

const GRAVITY = -24.8
var vel = Vector3()
const MAX_SPEED = 15
const JUMP_SPEED = 18
const ACCEL = 3
const DASH_SPEED = 50

var dir = Vector3()

const DEACCEL = 16
const MAX_SLOPE_ANGLE = 40

var camera
var rotation_helper

var MOUSE_SENS = 0.05

var p = preload("res://Player/Projectile/Projectile.tscn").instance()
const DEFAULT_MAG_SIZE = 7
var mag_size

onready var animation_tree = $AnimationTree

var is_mech = false

# Status check vars
var is_reloading = false
var is_moving_forward = false
var is_moving_back = false
var is_moving_right = false
var is_moving_left = false

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

func _ready():
	camera = get_parent().get_node("Camera")
	rotation_helper = $Rotation_Helper
	
	# ----------------------------------
	# Ammunition SET
	mag_size = DEFAULT_MAG_SIZE
	p.set_vars(65, Vector3.DOWN * 10)
	
func _process(delta):
	$HUD.update_dash_timer(dash_timer.time_left)
	$HUD.update_reload_timer(reload_timer.time_left)
	
func _physics_process(delta):
	process_input()
	process_movement(delta)
	process_camera_rotation()
	process_fire()
	process_animations()
	
func process_input():
	
	# ----------------------------------
	# Walking
	dir = Vector3()
	var cam_xform = camera.get_global_transform()
	
	var input_movement_vector = Vector2()

	if Input.is_action_pressed("forward"):
		input_movement_vector.y += 1
		is_moving_forward = true
	if Input.is_action_pressed("back"):
		input_movement_vector.y -= 1
		is_moving_back = true
	if Input.is_action_pressed("left"):
		input_movement_vector.x -= 1
		is_moving_left = true
	if Input.is_action_pressed("right"):
		input_movement_vector.x += 1
		is_moving_right = true
		
	if Input.is_action_just_released("forward"):
		is_moving_forward = false
	if Input.is_action_just_released("back"):
		is_moving_back = false
	if Input.is_action_just_released("left"):
		is_moving_left = false
	if Input.is_action_just_released("right"):
		is_moving_right = false
			
	input_movement_vector = input_movement_vector.normalized()
	
	# Basic vectors are already normalized
	dir += -cam_xform.basis.z * input_movement_vector.y
	dir += cam_xform.basis.x * input_movement_vector.x
	# ----------------------------------
	
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
	# Reload
	if Input.is_action_just_pressed("reload") && is_reloading == false && mag_size < DEFAULT_MAG_SIZE:
		is_reloading = true
		mag_size = DEFAULT_MAG_SIZE
		$HUD.update_ammo_val(str(mag_size) + "/" + str(DEFAULT_MAG_SIZE))
		reload_timer.start()
		var random_sound = randi() % 3
		pistol_reload_sounds[random_sound].play()
		
	if reload_timer.time_left == 0:
		is_reloading = false
	# ----------------------------------
	
	# ----------------------------------
	# Melee
	if Input.is_action_just_pressed("melee") && sword_timer.time_left == 0:
		print("SWING")
		animation_tree["parameters/IsItSlicing/active"] = true
		var random_sound = randi() % 3
		sword_sounds[random_sound].play()
		sword_timer.start()
		
		
func process_movement(delta):
	dir.y = 0
	dir = dir.normalized()

	vel.y += delta * GRAVITY

	var hvel = vel
	hvel.y = 0

	var target = dir
	target *= MAX_SPEED

	var accel
	if dir.dot(hvel) > 0:
		accel = ACCEL
	else:
		accel = DEACCEL

	hvel = hvel.linear_interpolate(target, accel * delta)
	vel.x = hvel.x
	vel.z = hvel.z
	vel = move_and_slide(vel, Vector3(0, 1, 0), 0.05, 4, deg2rad(MAX_SLOPE_ANGLE))

func process_camera_rotation():
	# sceen_pos is the player global pos
	# mouse_pos is global on screen
	# angle is calculated in -PI - PI
	# offset half of negative PI to get a cleaner angle
	# The players blend position is calculated using the absolute value
		# of the angle of rotation of the player plus PI to stay positive minus the arctangent squared of the movement directions
		# y value - the x value
		# cos is taken for the y
		# sin is taken for the x
	var offset = -PI * 0.5
	var screen_pos = camera.unproject_position(rotation_helper.global_transform.origin)
	var mouse_pos = get_viewport().get_mouse_position()
	var angle = screen_pos.angle_to_point(mouse_pos)
	rotation_helper.rotation.y = -angle + offset
	var angle_to_movement = - abs(angle+(PI) - atan2(dir.z, dir.x))

	var blend_y = cos(angle_to_movement)
	var blend_x = sin(angle_to_movement)
	animation_tree["parameters/Walk/blend_position"] = Vector2(blend_x, blend_y)

func process_fire():
	if Input.is_action_pressed("fire") && mag_size > 0 && fire_timer.time_left == 0 && is_reloading != true:
		get_parent().add_child(p)
		p.transform = $Rotation_Helper/MechJam_Player/rig/Skeleton/Pistol/WeaponMuzzle.global_transform
		p.velocity = -p.transform.basis.z * p.muzzle_velocity
		
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
		
	if Input.is_action_just_released("interact"):
		var mech = get_parent().get_node("Mech")
		mech.transform = self.transform
		self.hide()
		camera.set_current_target("mech")
		print("Did you see that??")
