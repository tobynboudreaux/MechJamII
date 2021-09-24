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

# Timers
onready var fire_timer = get_node("FireTimer")
onready var reload_timer = get_node("ReloadTimer")
onready var dash_timer = get_node("DashTimer")

func _ready():
	camera = $Camera
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
	if Input.is_action_pressed("back"):
		input_movement_vector.y -= 1
	if Input.is_action_pressed("left"):
		input_movement_vector.x -= 1
	if Input.is_action_pressed("right"):
		input_movement_vector.x += 1
		
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
		$DashTimer.start()
	# ----------------------------------
	
	# ----------------------------------
	# Reload
	if Input.is_action_just_pressed("reload"):
		is_reloading = true
		mag_size = DEFAULT_MAG_SIZE
		$HUD.update_ammo_val(str(mag_size) + "/" + str(DEFAULT_MAG_SIZE))
		$ReloadTimer.start()
		
	if reload_timer.time_left == 0:
		is_reloading = false
	# ----------------------------------
	
	# ----------------------------------
	# Melee
	if Input.is_action_just_pressed("melee"):
		print("SWING")
		animation_tree["parameters/IsItSlicing/active"] = true
		
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
		owner.add_child(p)
		p.transform = $Rotation_Helper/MechJam_Player/rig/Skeleton/Pistol/WeaponMuzzle.global_transform
		p.velocity = -p.transform.basis.z * p.muzzle_velocity
		mag_size -= 1
		$HUD.update_ammo_val(str(mag_size) + "/" + str(DEFAULT_MAG_SIZE))
		fire_timer.start()
		
func process_animations():
	if Input.is_action_pressed("fire") && mag_size > 1 && is_reloading != true:
		animation_tree["parameters/IsItShooting/blend_amount"] = 1
	elif Input.is_action_just_released("fire") || mag_size < 1 || is_reloading == true:
		animation_tree["parameters/IsItShooting/blend_amount"] = 0
	elif vel != Vector3(0,0,0):
		animation_tree["parameters/Transition/current"] = 1
	elif Input.is_action_just_pressed("interact") && is_mech == false:
		var player_parent = self.get_parent()
		var mech_scene = load("res://Player/Mech/Mech.tscn")
		var mech = mech_scene.instance()
		player_parent.add_child(mech)
		mech.transform = self.transform
		self.queue_free()

		print("Did you see that??")
#	elif Input.is_action_just_pressed("interact") && is_mech:
#		var player_parent = self.get_parent()
#		var pilot_scene = load("res://Player/Pilot/Pilot.tscn")
#		var pilot = pilot_scene.instance()
#		player_parent.add_child(pilot)
#		pilot.transform = self.transform
#		self.queue_free()
#		is_mech = false
#		print("Did you see that??")
	else:
		animation_tree["parameters/Transition/current"] = 0
