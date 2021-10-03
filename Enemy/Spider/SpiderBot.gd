extends KinematicBody

onready var health = get_node("Health")

#onready var ex_sounds = [
#	get_node("BomberBot/MechJam_BomberBot/Armature/Skeleton/BomberBot/Sounds/Ex1"),
#	get_node("BomberBot/MechJam_BomberBot/Armature/Skeleton/BomberBot/Sounds/Ex2"),
#	get_node("BomberBot/MechJam_BomberBot/Armature/Skeleton/BomberBot/Sounds/Ex3"),
#	get_node("BomberBot/MechJam_BomberBot/Armature/Skeleton/BomberBot/Sounds/Ex4")
#]

enum states {PATROL, CHASE, ATTACK, DEAD}
var state = states.PATROL

# For path following.

export (NodePath) var patrol_path
var patrol_points
var patrol_index = 0

# Target for chase mode.

var player = null

var speed = 4
onready var pilot = get_parent().get_node("Pilot")
onready var mech = get_parent().get_node("Mech")
var vel
var stop_move
onready var attack_timer = get_node("AttackTimer")
var p_s = preload("res://Player/Projectile/Projectile.tscn")

func _ready():
	health.set_health(50)
	
	$AnimationTree["parameters/Transition/current"] = 0
	$AnimationTree["parameters/Blend3/blend_amount"] = 0
	
func _process(delta):
	if health.current_health == 0:
		state = states.DEAD
	
func _physics_process(delta):
	if state == states.CHASE:
		var target
		target = player.get_global_transform().origin - Vector3(rand_range(5,10), 0, 0)
		vel = (target - global_transform.origin).normalized() * speed * delta
		
		if vel != Vector3.ZERO:
			look_at(transform.origin - vel.normalized(), Vector3.UP)
			
		$AnimationTree["parameters/Blend3/blend_amount"] = 1
		
	if state == states.ATTACK:
		get_node("SpiderBot").look_at(player.get_global_transform().origin, Vector3(0,1,0))
		if attack_timer.time_left == 0:
			attack_player()
			attack_timer.start()
		
	if state == states.DEAD:
		$AnimationTree["parameters/Transition/current"] = 1
		yield(get_tree().create_timer(1), "timeout")
		self.queue_free()
	
#	if is_in_range():
#		$AnimationTree["parameters/IsAttack/current"] = 1
#	if follow_player(delta) == "Pilot":
#		$AnimationTree["parameters/IsAlive/current"] = 1

func _on_AttackRadius_body_entered(body):
	if state != states.DEAD:
		if body.name == "Mech" || body.name == "Pilot":
			state = states.ATTACK
			player = body
#			var random_sound = randi() % 4
#			ex_sounds[random_sound].play()
			
func _on_AttackRadius_body_exited(body):
	if state != states.DEAD:
		if body.name == "Mech" || body.name == "Pilot":
			state = states.PATROL
			player = body

func _on_DetectRadius_body_entered(body):
	if body.name == "Mech" || body.name == "Pilot":
		state = states.CHASE
		player = body

func _on_DetectRadius_body_exited(body):
	state = states.PATROL
	player = null
	
func attack_player():
	var p = p_s.instance()
	p.set_vars(65, Vector3.DOWN * 10, 10, false, "Pilot")
	get_parent().add_child(p)

	p.transform = $SpiderBot/MechJam_SpiderBot/rig/Skeleton/BoneAttachment2/Barrel_shield/Muzzle.global_transform
	p.velocity = -p.transform.basis.z * p.muzzle_velocity
	$AnimationTree["parameters/OneShot/active"] = true
	player.health.take_damage(20)
