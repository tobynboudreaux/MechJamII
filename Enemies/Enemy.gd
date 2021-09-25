extends KinematicBody

const GRAVITY = -24.8
var vel = Vector3()
const MAX_SPEED = 20
const JUMP_SPEED = 18
const ACCEL = 4.5

var dir = Vector3()

const DEACCEL = 16
const MAX_SLOPE_ANGLE = 40

var camera
var rotation_helper

var MOUSE_SENS = 0.05

func _ready():
	camera = $Camera
	rotation_helper = $Rotation_Helper
	
func _physics_process(delta):
	ai_movement(delta)
	process_movement(delta)
	
func ai_movement(delta):
	pass # Replace with function body.
	# Basic vectors are already normalized
	#dir += -cam_xform.basis.z * input_movement_vector.y
	#dir += cam_xform.basis.x * input_movement_vector.x
	# ----------------------------------
	
		
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
