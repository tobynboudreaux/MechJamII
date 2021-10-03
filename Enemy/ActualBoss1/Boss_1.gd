extends KinematicBody

enum phases {IDLE, PHASE1, PHASE2, PHASE3, DEAD}
var phase

signal phase_2
signal phase_3
signal dead

var player = null

onready var pilot = get_parent().get_node("Pilot")
onready var mech = get_parent().get_node("Mech")

onready var animation_player = get_node("Boss_1/AnimationPlayer")

var max_health = 1000
var current_health = max_health
var phase_2_health = max_health * 0.6
var phase_3_health = max_health * 0.25

var p_s = preload("res://Player/Projectile/Projectile.tscn")

onready var phase_1_timer = get_node("Timers/Phase1Shot")
onready var phase_2_timer = get_node("Timers/Phase2Shot")
onready var phase_3_timer = get_node("Timers/Phase3Shot")

var middle_guns = [
	get_node("Boss_1/Body/Middle/Cone010/Position3D"),
	get_node("Boss_1/Body/Middle/Cone011/Position3D"),
	get_node("Boss_1/Body/Middle/middle_gun/Position3D")
]

func _ready():
	animation_player.play("Idle")
	
func _process(delta):
	_on_health(current_health)
	
func _physics_process(delta):
	_on_health(current_health)
	
	match phase:
		phases.DEAD:
			$Timers/DeathTimer.start()
			yield($Timers/DeathTimer, "timeout")
			set_physics_process(false)
			self.queue_free()	
		
		phases.PHASE1:
			animation_player.play("Stage1")
			if phase_1_timer.time_left == 0:
				_fire_middle_guns()
				phase_1_timer.start()
			
		phases.PHASE2:
			animation_player.play("Stage2")
			if phase_2_timer.time_left == 0:
				_fire_middle_guns()
				_fire_top_gun()
				phase_2_timer.start()
			
		phases.PHASE3:
			animation_player.play("Stage3")
			if phase_3_timer.time_left == 0:
				_fire_middle_guns()
				_fire_top_gun()
				phase_3_timer.start()
			
		phases.IDLE:
			animation_player.play("Idle")

func _on_health(amount):
	if amount < phase_2_health:
		emit_signal("phase_2")
		
	if amount < phase_3_health:
		emit_signal("phase_3")
		
	if amount <= 0:
		emit_signal("dead")
		
func take_damage(amount):
	current_health -= amount
	print(current_health)
	
func _fire_middle_guns():
	var p0 = p_s.instance()
	p0.set_vars(30, Vector3.DOWN, 10, false, "Boss_1")
	get_parent().add_child(p0)
	p0.transform = $Boss_1/Body/Middle/Cone010/Position3D.global_transform
	p0.velocity = -p0.transform.basis.z * p0.muzzle_velocity
	
	var p1 = p_s.instance()
	p1.set_vars(30, Vector3.DOWN, 10, false, "Boss_1")
	get_parent().add_child(p1)
	p1.transform = $Boss_1/Body/Middle/Cone011/Position3D.global_transform
	p1.velocity = -p1.transform.basis.z * p1.muzzle_velocity
	
	var p2 = p_s.instance()
	p2.set_vars(30, Vector3.DOWN, 10, false, "Boss_1")
	get_parent().add_child(p2)
	p2.transform = $Boss_1/Body/Middle/middle_gun/Position3D.global_transform
	p2.velocity = -p2.transform.basis.z * p2.muzzle_velocity
				
func _fire_top_gun():
	var p = p_s.instance()
	p.set_vars(50, Vector3.DOWN, 10, false, "Boss_1")
	get_parent().add_child(p)
	p.transform = $Boss_1/Body/Top/Top_gun/Position3D.global_transform
	p.velocity = -p.transform.basis.z * p.muzzle_velocity

func _on_AttackRadius_body_entered(body):
	player = body
	
	phase = phases.PHASE1

func _on_AttackRadius_body_exited(body):
	player = null
	
	phase = phases.IDLE

func _on_Boss_1_dead():
	phase = phases.DEAD
	get_tree().change_scene("res://World/World2/World2.tscn")

func _on_Boss_1_phase_2():
	phase = phases.PHASE2


func _on_Boss_1_phase_3():
	phase = phases.PHASE3
