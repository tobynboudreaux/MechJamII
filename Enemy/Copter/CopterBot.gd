extends "res://Enemy/Enemy.gd"

onready var health = get_node("Health")

#onready var ex_sounds = [
#	get_node("BomberBot/MechJam_BomberBot/Armature/Skeleton/BomberBot/Sounds/Ex1"),
#	get_node("BomberBot/MechJam_BomberBot/Armature/Skeleton/BomberBot/Sounds/Ex2"),
#	get_node("BomberBot/MechJam_BomberBot/Armature/Skeleton/BomberBot/Sounds/Ex3"),
#	get_node("BomberBot/MechJam_BomberBot/Armature/Skeleton/BomberBot/Sounds/Ex4")
#]

func _ready():
	health.set_health(50)
#	$AnimationTree["parameters/IsAlive/current"] = 0
#	$AnimationTree["parameters/IsMove/blend_amount"] = 0
	
func _process(delta):
	if health.current_health == 0:
		state = states.DEAD
	
func _physics_process(delta):
	if state == states.CHASE:
		pass
#		$AnimationTree["parameters/IsMove/blend_amount"] = 1
		
	if state == states.ATTACK:
#		$AnimationTree["parameters/IsExplode/current"] = 1
		yield(get_tree().create_timer(1), "timeout")
		self.queue_free()
		
	if state == states.DEAD:
#		$AnimationTree["parameters/IsAlive/current"] = 1
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
			player.health.take_damage(30)
			
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
