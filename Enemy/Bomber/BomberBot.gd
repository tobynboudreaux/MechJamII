extends KinematicBody

onready var ex_sounds = [
	get_node("BomberBot/MechJam_BomberBot/Armature/Skeleton/BomberBot/Sounds/Ex1"),
	get_node("BomberBot/MechJam_BomberBot/Armature/Skeleton/BomberBot/Sounds/Ex2"),
	get_node("BomberBot/MechJam_BomberBot/Armature/Skeleton/BomberBot/Sounds/Ex3"),
	get_node("BomberBot/MechJam_BomberBot/Armature/Skeleton/BomberBot/Sounds/Ex4")
]

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
var p_s = preload("res://Player/Projectile/Projectile.tscn")

export var max_health = 50
var current_health = max_health

func _ready():
	$AnimationTree["parameters/IsAlive/current"] = 0
	$AnimationTree["parameters/IsMove/blend_amount"] = 0
	
func _process(delta):
	if current_health <= 0:
		state = states.DEAD
	
func _physics_process(delta):
	choose_action(delta)
	
	if vel != Vector3.ZERO:
		move_and_collide(vel)
		look_at(transform.origin - vel.normalized(), Vector3.UP)

func choose_action(delta):
	vel = Vector3.ZERO
	
	var target
	match state:
		states.DEAD:
			$AnimationTree["parameters/IsAlive/current"] = 1
			$Timers/DeathTimer.start()
			yield($Timers/DeathTimer, "timeout")
			set_physics_process(false)
			self.queue_free()

		# Move along assigned path.

		states.PATROL:
			if !patrol_points:
				return
			target = patrol_points[patrol_index].transform.origin
			if transform.origin.distance_to(target) < 1:
				patrol_index = wrapi(patrol_index + 1, 0, patrol_points.size())
				target = patrol_points[patrol_index].transform.origin
			vel = (target - global_transform.origin).normalized() * speed * delta

		# Move towards player.

		states.CHASE:
			target = player.get_global_transform().origin - Vector3(rand_range(5,10), 0, 0)
			vel = (target - global_transform.origin).normalized() * speed * delta
		
			if vel != Vector3.ZERO:
				look_at(transform.origin - vel.normalized(), Vector3.UP)
			
			$AnimationTree["parameters/IsMove/blend_amount"] = 1

		# Make an attack.

		states.ATTACK:
			$AnimationTree["parameters/IsExplode/current"] = 1
			yield(get_tree().create_timer(1), "timeout")
			self.queue_free()

func _on_AttackRadius_body_entered(body):
	if state != states.DEAD:
		if body.name == "Mech" || body.name == "Pilot":
			state = states.ATTACK
			player = body
			var random_sound = randi() % 4
			ex_sounds[random_sound].play()
			player.take_damage(30)
			
func _on_AttackRadius_body_exited(body):
	if state!= states.DEAD:
		if state != states.ATTACK:
			if body.name == "Mech" || body.name == "Pilot":
				state = states.CHASE
				player = body

func _on_DetectRadius_body_entered(body):
	if body.name == "Mech" || body.name == "Pilot":
		state = states.CHASE
		player = body

func _on_DetectRadius_body_exited(body):
	state = states.PATROL
	
func take_damage(amount):
	current_health -= amount
