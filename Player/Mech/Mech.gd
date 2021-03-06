extends "res://Player/Player.gd"

onready var animation_tree = $AnimationTree

export var MAX_SPEED = 15
export var ACCEL = 3

export var DEACCEL = 16
export var MAX_SLOPE_ANGLE = 40
const NUMBER_OF_ROCKETS = 3

var bullet_p = preload("res://Player/Projectile/Projectile.tscn")
var rocket_p = preload("res://Player/Projectile/Rocket/Rocket.tscn")

var input_movement_vector

onready var rotation_helper = $Rotation_Helper

# Timers
onready var fire_timer = get_node("Timers/FireTimer")
onready var reload_timer = get_node("Timers/ReloadTimer")
onready var burst_timer = get_node("Timers/BurstTimer")
onready var rocket_timer = get_node("Timers/RocketTimer")
onready var footstep_timer = get_node("Timers/FootstepTimer")
onready var to_pilot_timer = get_node("Timers/ToPilotTimer")

#onready var health_bar = get_node("MechHUD/HealthBar")
export var max_health = 500
var current_health = max_health
#onready var hud = get_node("MechHUD")

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

onready var ex_sounds = [
	get_node("Rotation_Helper/MechJam_mech/rig/Skeleton/MechBody/Sounds/Ex1"),
	get_node("Rotation_Helper/MechJam_mech/rig/Skeleton/MechBody/Sounds/Ex2"),
	get_node("Rotation_Helper/MechJam_mech/rig/Skeleton/MechBody/Sounds/Ex3"),
	get_node("Rotation_Helper/MechJam_mech/rig/Skeleton/MechBody/Sounds/Ex4")
]

var is_last = false

func _ready():
#	hud.hide()
	animation_tree["parameters/IsShooting/blend_amount"] = 0
	animation_tree["parameters/Transition/current"] = 0
	
func _process(delta):
	if(is_mech):
#		hud.show()
#		health_bar._on_health_updated(health.current_health)
#		health_bar._on_max_health_updated(health.max_hp)
		
		$Timers/DamageTimer.start()
		yield($Timers/DamageTimer, "timeout")
		take_damage(.2)
		
		# ----------------------------------
		# Switch to Pilot
		if current_health <= 0:
			swap_to_pilot()
		# ----------------------------------

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
		if is_last:
			get_parent().get_node("Boss_2").take_damage(10)
			return
		var bullet = bullet_p.instance()
		bullet.set_vars(65, Vector3.DOWN * 10, 15, false, "Mech")
		get_parent().add_child(bullet)
		bullet.transform = $Rotation_Helper/MechJam_mech/rig/Skeleton/BoneAttachment/MechGun/BulletSpawn.global_transform
		bullet.velocity = bullet.transform.basis.z * bullet.muzzle_velocity
		to_pilot_timer.start()
		yield(to_pilot_timer, "timeout")
		bullet.queue_free()
	# ----------------------------------
	
	# ----------------------------------
	# Rocket
	if Input.is_action_just_pressed("secondary") && rocket_timer.time_left == 0:
		rocket_timer.start()
		animation_tree["parameters/IsLaunching/active"] = true
		if is_last:
			return
		for i in NUMBER_OF_ROCKETS:
			yield(get_tree().create_timer(0.3), "timeout")
			var random_sound = randi() % 4
			ex_sounds[random_sound].play()
			var rocket = rocket_p.instance()
			rocket.set_vars(30, Vector3.DOWN * 10, 30, true, "Rocket")
			get_parent().add_child(rocket)
			rocket.transform = $Rotation_Helper/MechJam_mech/rig/Skeleton/MechTurret/RocketSpawn.global_transform
			rocket.velocity = rocket.transform.basis.z * rocket.muzzle_velocity
			to_pilot_timer.start()
			yield(to_pilot_timer, "timeout")
			rocket.queue_free()
#		var random_sound = randi() % 3
#		sword_sounds[random_sound].play()
#		sword_timer.start()
	# ----------------------------------
		
func wait(sec):
	yield(get_tree().create_timer(sec), "timeout")
	
func process_animations():
	if Input.is_action_pressed("fire") && fire_timer.time_left == 0:
		animation_tree["parameters/IsShooting/blend_amount"] = 1
		var random_sound = randi() % 4
		gun_sounds[random_sound].play()
		fire_timer.start()
	elif Input.is_action_just_released("fire"):
		animation_tree["parameters/IsShooting/blend_amount"] = 0
	else:
		animation_tree["parameters/Transition/current"] = 0
		
	if vel != Vector3.ZERO:
		animation_tree["parameters/Transition/current"] = 1
	else:
		animation_tree["parameters/Transition/current"] = 0

	if is_moving_back && footstep_timer.time_left == 0 || is_moving_forward && footstep_timer.time_left == 0 || is_moving_left && footstep_timer.time_left == 0 || is_moving_right && footstep_timer.time_left == 0:
		var random_sound = randi() % 4
		footstep_sounds[random_sound].play()
		footstep_timer.start()
		
func interaction_can_interact(interactionComponentParent : Node) -> bool:
	return interactionComponentParent is Pilot
		
func interaction_interact(interactionComponentParent : Node) -> void:
	var pilot_i = interactionComponentParent.get_node(interactionComponentParent.interact_parent)
	if pilot_i.has_energy:
		pilot_i.swap_to_mech()
		pilot_i.has_energy = false
		
func swap_to_pilot():
		var pilot = get_parent().get_node("Pilot")
		pilot.show()
		pilot.transform.origin = self.transform.origin + Vector3(2,0,0)
		animation_tree["parameters/IsShutdown/blend_amount"] = 1
		camera.set_current_target("pilot")
		set_mech(false)
#		pilot.hud.show()
		pilot.is_mech = false
		pilot.get_node("CollisionShape").disabled = false
		pilot.animation_tree["parameters/Transition/current"] = 0
#		hud.hide()

func take_damage(amount):
	current_health -= amount

func set_health(amount):
	current_health = amount
	
func is_last_boss():
	is_last = true
