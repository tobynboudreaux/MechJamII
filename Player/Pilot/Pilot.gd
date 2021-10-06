extends "res://Player/Player.gd"
class_name Pilot

signal set_lose()

export var MAX_SPEED = 15
export var ACCEL = 3
export var DASH_SPEED = 50

export var DEACCEL = 16
export var MAX_SLOPE_ANGLE = 40

var rotation_helper

var p_s = preload("res://Player/Projectile/Projectile.tscn")
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

var is_last = false

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
#onready var hud = get_node("PilotHUD")
#onready var health_bar = get_node("PilotHUD/HealthBar")
var max_health = 100
var current_health = max_health

var has_energy = false
var can_interact_mech = true

func _ready():
	rotation_helper = $Rotation_Helper
#	hud.hide()
	self.hide()
	$CollisionShape.disabled = true
	
	# ----------------------------------
	# Ammunition SET
	mag_size = DEFAULT_MAG_SIZE
	
func _process(delta):
	if(!is_mech):
		pass
#		hud.show()
#		hud.update_dash_timer(dash_timer.time_left)
#		hud.update_reload_timer(reload_timer.time_left)
#		health_bar._on_health_updated(health.current_health)
#		health_bar._on_max_health_updated(health.max_hp)
			
	if(is_mech):
		var mech = get_parent().get_node("Mech")
		self.global_transform.origin = mech.get_global_transform().origin
		
		if current_health < max_health:
			current_health = max_health

func _physics_process(delta):
	if(!is_mech):
		process_ui_input()
		input_movement_vector = process_input()
		process_movement(delta, MAX_SPEED, MAX_SLOPE_ANGLE, ACCEL, DEACCEL)
		process_pilot_input()
		process_animations()
		animation_tree["parameters/Walk/blend_position"] = process_camera_rotation(rotation_helper)
		
	if global_transform.origin.y < -4:
		emit_signal("set_lose")
	
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
	if Input.is_action_just_pressed("secondary") && sword_timer.time_left == 0:
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
#		hud.update_ammo_val(str(mag_size) + "/" + str(DEFAULT_MAG_SIZE))
	# ----------------------------------
	
	# ----------------------------------		
	# Shoot
	if Input.is_action_pressed("fire") && mag_size > 0 && fire_timer.time_left == 0 && is_reloading != true:
		var p = p_s.instance()
		p.set_vars(65, Vector3.DOWN * 10, 10, false, "Pilot")
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
#		hud.update_ammo_val(str(mag_size) + "/" + str(DEFAULT_MAG_SIZE))
		fire_timer.start()
	elif Input.is_action_pressed("fire") && mag_size == 0 && fire_timer.time_left == 0 && is_reloading != true:
		animation_tree["parameters/IsItShooting/blend_amount"] = 1
		$Rotation_Helper/MechJam_Player/rig/Skeleton/Player/Sounds/PistolDry.play()
		fire_timer.start()
	elif Input.is_action_just_released("fire") || is_reloading == true:
		animation_tree["parameters/IsItShooting/blend_amount"] = 0
	elif vel != Vector3.ZERO:
		animation_tree["parameters/Transition/current"] = 1
	else:
		animation_tree["parameters/Transition/current"] = 0

	if is_moving_back && footstep_timer.time_left == 0 || is_moving_forward && footstep_timer.time_left == 0 || is_moving_left && footstep_timer.time_left == 0 || is_moving_right && footstep_timer.time_left == 0:
		var random_sound = randi() % 4
		footstep_sounds[random_sound].play()
		footstep_timer.start()

func swap_to_mech():
		var mech = get_parent().get_node("Mech")
		mech.transform = self.transform
		self.hide()
		self.get_node("CollisionShape").disabled = true
		if is_last:
			camera.set_current_target("boss_battle_2")
		else:
			camera.set_current_target("mech")
		set_mech(true)
		mech.to_pilot_timer.start()
#		mech.hud.show()
		mech.is_mech = true
		mech.animation_tree["parameters/Transition/current"] = 0
		mech.animation_tree["parameters/IsShutdown/blend_amount"] = 0
		mech.set_health(mech.max_health)
#		hud.hide()

func take_damage(amount):
	current_health -= amount
	if current_health < 0:
		current_health = 0
		emit_signal("set_lose")
