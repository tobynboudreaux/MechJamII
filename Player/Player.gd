extends KinematicBody
class_name Player

signal set_pause()

# Movement vars
const GRAVITY = -24.8
var dir = Vector3()
var vel = Vector3()
var scene_switcher

# Status check vars
var is_reloading = false
var is_moving_forward = false
var is_moving_back = false
var is_moving_right = false
var is_moving_left = false
var is_mech = true

onready var camera = get_parent().get_node("Camera")

var joystick_dir = Vector3()

func _ready():
	if is_mech:
		camera.current_target = "mech"
	if !is_mech:
		camera.current_target = "pilot"
		
	# Connects the Player object with the UI (so you can pause the game)
	scene_switcher = get_node("/root/SceneSwitcher")
	print("attempt to connect player to pause ui")
	scene_switcher.connect_player(self)
		
func set_mech(value):
	is_mech = value
	
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
	return input_movement_vector
	
func process_joystick_input(rotation_helper):
	joystick_dir = Vector3()
	var cam_xform = camera.get_global_transform()
	var input_rotation_vector = Vector2()
	if Input.get_action_strength("look_left"):
		input_rotation_vector.x -= 1
	if Input.get_action_strength("look_right"):
		input_rotation_vector.x += 1
	if Input.get_action_strength("look_up"):
		input_rotation_vector.y += 1
	if Input.get_action_strength("look_down"):
		input_rotation_vector.y -= 1
		
	input_rotation_vector = input_rotation_vector.normalized()
	
	# Basic vectors are already normalized
	#joystick_dir += -cam_xform.basis.z * input_rotation_vector.y
	#joystick_dir += cam_xform.basis.x * input_rotation_vector.x
#	rotation_helper.look_at(rotation_helper.global_transform.origin + joystick_dir, Vector3.UP)
	return input_rotation_vector
	
func process_ui_input():
	if Input.is_action_just_pressed("pause"):
		print("PAUSED PRESSED!")
		emit_signal("set_pause")
	
func process_camera_rotation(rotation_helper):
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
	return Vector2(blend_x, blend_y)
		
func process_movement(delta, MAX_SPEED, MAX_SLOPE_ANGLE, ACCEL, DEACCEL):
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
