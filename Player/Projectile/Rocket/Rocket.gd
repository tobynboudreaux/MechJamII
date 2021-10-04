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
onready var projectile_body = get_node("ProjectileMesh")
var has_gravity = false
var projectile_damage = 5

var current_player

func _physics_process(delta):
	if has_gravity():
		velocity += g * delta
	look_at(transform.origin + velocity.normalized(), Vector3.UP)
	transform.origin += velocity * delta
	
	if global_transform.origin.y < -4:
		queue_free()
		
func has_gravity():
	has_gravity = true
	
func set_vars(vel, g_val, dmg, h_g, name):
	muzzle_velocity = vel
	g = g_val
	projectile_damage = dmg
	if h_g:
		has_gravity()
	current_player = name
	
func _on_Rocket_body_entered(body):
	print(body)
	if current_player in body.name:
		return
	if "Bomber" in body.name || "Copter" in body.name || "Spider" in body.name || "Boss" in body.name || "Mech" in body.name || "Pilot" in body.name:
		self.queue_free()
		var random_sound = randi() % 3
		ex_sounds[random_sound].play()
		body.take_damage(projectile_damage)
