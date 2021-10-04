extends KinematicBody

enum phases {IDLE, PHASE1, PHASE2, PHASE3, DEAD}
var phase = phases.IDLE

signal phase_2
signal phase_3
signal dead
signal enter

var player = null

onready var pilot = get_parent().get_node("Pilot")
onready var mech = get_parent().get_node("Mech")

onready var animation_player = get_node("Boss_2/AnimationPlayer")

var max_health = 1000
var current_health = max_health
var phase_2_health = max_health * 0.6
var phase_3_health = max_health * 0.25

var p_s = preload("res://Player/Projectile/Projectile.tscn")

# Timers
onready var phase_1_fly = get_node("Timers/Phase1Fly")
onready var phase_2_fly = get_node("Timers/Phase2Fly")
onready var phase_3_fly = get_node("Timers/Phase3Fly")
onready var fire_primary = get_node("Timers/FireP")
onready var fire_secondary = get_node("Timers/FireS")
onready var fire_rockets = get_node("Timers/FireR")

var fly_points_p1 
var fly_points_p2 
var fly_points_p3
var fly_ind = 0

var vel

var phase_1_speed = 10
var phase_2_speed = 15
var phase_3_speed = 20

func _ready():
	animation_player.play("00_Idle")
	emit_signal("enter")
	
func _process(delta):
	_on_health(current_health)
	
func _physics_process(delta):
	choose_action(delta)
	
	if vel != Vector3.ZERO:
		move_and_collide(vel)
		look_at(pilot.global_transform.origin, Vector3.UP)
		self.rotate_object_local(Vector3.UP, PI)

func choose_action(delta):
	vel = Vector3.ZERO
	
	var target
	match phase:
		phases.DEAD:
			$Timers/DeathTimer.start()
			yield($Timers/DeathTimer, "timeout")
			set_physics_process(false)
			self.queue_free()	
		
		phases.PHASE1:
			var fly_points = fly_points_p1
			if !fly_points:
				return
			target = fly_points[fly_ind].global_transform.origin
			if global_transform.origin.distance_to(target) < 1:
				fly_ind = wrapi(fly_ind + 1, 0, fly_points.size())
				target = fly_points[fly_ind].global_transform.origin
			vel = (target - global_transform.origin).normalized() * phase_1_speed * delta
			if fire_primary.time_left == 0:
					animation_player.play("01_Firing Primary")
					var p = p_s.instance()
					p.set_vars(50, Vector3.DOWN, 10, false, "Boss_2")
					get_parent().add_child(p)
					p.transform = $Boss_2/Armature/Skeleton/Boss2/Position3D.global_transform
					p.velocity = -p.transform.basis.z * p.muzzle_velocity
					fire_primary.start()
					
		phases.PHASE2:
			var fly_points = fly_points_p1 + fly_points_p2
			if !fly_points:
				return
			target = fly_points[fly_ind].global_transform.origin
			if global_transform.origin.distance_to(target) < 1:
				fly_ind = wrapi(fly_ind + 1, 0, fly_points.size())
				target = fly_points[fly_ind].global_transform.origin
			vel = (target - global_transform.origin).normalized() * phase_2_speed * delta
			if fire_primary.time_left == 0:
					animation_player.play("01_Firing Primary")
					var p = p_s.instance()
					p.set_vars(50, Vector3.DOWN, 10, false, "Boss_2")
					get_parent().add_child(p)
					p.transform = $Boss_2/Armature/Skeleton/Boss2/Position3D.global_transform
					p.velocity = -p.transform.basis.z * p.muzzle_velocity
					fire_primary.start()
			
		phases.PHASE3:
			var fly_points = fly_points_p1 + fly_points_p2 + fly_points_p3
			if !fly_points:
				return
			target = fly_points[fly_ind].global_transform.origin
			if global_transform.origin.distance_to(target) < 1:
				fly_ind = wrapi(fly_ind + 1, 1, fly_points.size())
				target = fly_points[fly_ind].global_transform.origin
			vel = (target - global_transform.origin).normalized() * phase_3_speed * delta
			if fire_primary.time_left == 0:
					animation_player.play("01_Firing Primary")
					var p = p_s.instance()
					p.set_vars(50, Vector3.DOWN, 10, false, "Boss_2")
					get_parent().add_child(p)
					p.transform = $Boss_2/Armature/Skeleton/Boss2/Position3D.global_transform
					p.velocity = -p.transform.basis.z * p.muzzle_velocity
					fire_primary.start()
			
			
		phases.IDLE:
			pass
	
func _on_health(amount):
	if amount < phase_2_health:
		emit_signal("phase_2")
		
	if amount < phase_3_health:
		emit_signal("phase_3")
		
	if amount == 0:
		emit_signal("dead")
		
func take_damage(amount):
	current_health -= amount
	if current_health < 0:
		current_health = 0
	
func _on_Boss_2_dead():
	phase = phases.DEAD
	get_tree().change_scene("res://Core/U WIN LOL/U WIN LOL.tscn")

func _on_Boss_2_phase_2():
	phase = phases.PHASE2

func _on_Boss_2_phase_3():
	phase = phases.PHASE3
	
func _on_Boss_2_enter():
	fly_points_p1 = [
		get_parent().get_node("FlyPoints/FlyPoint1P1"),
		get_parent().get_node("FlyPoints/FlyPoint2P1"),
		get_parent().get_node("FlyPoints/FlyPoint3P1"),
		get_parent().get_node("FlyPoints/FlyPoint4P1")
	]

	fly_points_p2 = [
		get_parent().get_node("FlyPoints/FlyPoint1P2"),
		get_parent().get_node("FlyPoints/FlyPoint2P2"),
		get_parent().get_node("FlyPoints/FlyPoint3P2"),
		get_parent().get_node("FlyPoints/FlyPoint4P2")
	]

	fly_points_p3 = [
		get_parent().get_node("FlyPoints/FlyPoint1P3"),
		get_parent().get_node("FlyPoints/FlyPoint2P3"),
	]
	
	player = pilot
	
	phase = phases.PHASE1
	
	mech.is_last = true
