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

var p = preload("res://Projectile/Projectile.tscn").instance()
onready var fire_timer = get_node("FireTimer")
const DEFAULT_MAG_SIZE = 7
var mag_size

func _ready():
	camera = $Camera
	rotation_helper = $Rotation_Helper
	
	# ----------------------------------
	# Ammunition SET
	mag_size = DEFAULT_MAG_SIZE
	p.set_vars(10, Vector3.DOWN * 20)
	
func _physics_process(delta):
	process_input()
	process_movement(delta)
	process_camera_rotation()
	process_fire()
	
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
	# Jumping
	if is_on_floor():
		if Input.is_action_just_pressed("jump"):
			vel.y = JUMP_SPEED
	# ----------------------------------
	
	# ----------------------------------
	# Reload
	if Input.is_action_just_pressed("reload"):
		mag_size = DEFAULT_MAG_SIZE
		$HUD.update_ammo_val(str(mag_size) + "/" + str(DEFAULT_MAG_SIZE))
		
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
	var offset = -PI * 0.5
	var screen_pos = camera.unproject_position(rotation_helper.global_transform.origin)
	var mouse_pos = get_viewport().get_mouse_position()
	var angle = screen_pos.angle_to_point(mouse_pos)
	rotation_helper.rotation.y = -angle + offset

func process_fire():
	if Input.is_action_just_pressed("fire") && mag_size > 0 && fire_timer.time_left == 0:
		owner.add_child(p)
		p.transform = $Rotation_Helper/Model/MeshInstance/WeaponMuzzle.global_transform
		p.velocity = -p.transform.basis.z * p.muzzle_velocity
		mag_size -= 1
		$HUD.update_ammo_val(str(mag_size) + "/" + str(DEFAULT_MAG_SIZE))
		fire_timer.start()
