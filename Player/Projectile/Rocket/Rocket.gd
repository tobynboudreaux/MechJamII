extends Area

onready var ex_sounds = [
	get_node("Rocket/Sounds/Ex1"),
	get_node("Rocket/Sounds/Ex2"),
	get_node("Rocket/Sounds/Ex3"),
	get_node("Rocket/Sounds/Ex4")
]
export var muzzle_velocity = 200
export var g = Vector3.DOWN * 20

var velocity = Vector3.ZERO
var has_gravity = false
var projectile_damage = 5

func _physics_process(delta):
	if has_gravity:
		velocity += g * delta
	look_at(transform.origin + velocity.normalized(), Vector3.UP)
	transform.origin += velocity * delta
	
	$Timers/DeathTimer.start()
	yield($Timers/DeathTimer, "timeout")
	set_physics_process(false)
	self.queue_free()
	
func set_vars(vel, g_val, dmg, h_g, name):
	muzzle_velocity = vel
	g = g_val
	projectile_damage = dmg

func _on_Rocket_body_entered(body):
	if "Bomber" in body.name || "Copter" in body.name || "Spider" in body.name || "Boss" in body.name:
		self.queue_free()
		var random_sound = randi() % 3
		ex_sounds[random_sound].play()
		body.take_damage(projectile_damage)
