extends Area

export var muzzle_velocity = 200
export var g = Vector3.DOWN * 20

var velocity = Vector3.ZERO
onready var projectile_body = get_node("ProjectileMesh")
var has_gravity = false
var projectile_damage = 5

onready var mechISounds = [
	get_node("CollisionShape/Sounds/MechI1"),
	get_node("CollisionShape/Sounds/MechI2"),
	get_node("CollisionShape/Sounds/MechI3"),
	get_node("CollisionShape/Sounds/MechI4")
]

onready var pilotISounds = [
	get_node("CollisionShape/Sounds/PilotI1"),
	get_node("CollisionShape/Sounds/PilotI2"),
	get_node("CollisionShape/Sounds/PilotI3"),
	get_node("CollisionShape/Sounds/PilotI4")
]

onready var rocketISounds = [
	get_node("CollisionShape/Sounds/Ex1"),
	get_node("CollisionShape/Sounds/Ex2"),
	get_node("CollisionShape/Sounds/Ex3"),
	get_node("CollisionShape/Sounds/Ex4")
]

var impact_sounds
var current_player
	
func _physics_process(delta):
	if has_gravity:
		velocity += g * delta
	look_at(transform.origin + velocity.normalized(), Vector3.UP)
	transform.origin += velocity * delta
	if current_player == "mech":
		impact_sounds = mechISounds
	if current_player == "pilot":
		impact_sounds = pilotISounds
	if current_player == "rocket":
		impact_sounds = rocketISounds
	
func has_gravity():
	has_gravity = true
	
func set_vars(vel, g_val, dmg, h_g, name):
	muzzle_velocity = vel
	g = g_val
	projectile_damage = dmg
	if h_g:
		has_gravity()
	if name == "Mech":
		current_player = "mech"
	if name == "Pilot":
		current_player = "pilot"
	if name == "Rocket":
		current_player = "rocket"

func _on_Area_body_entered(body):
	print(body)
	
	if "Bomber" in body.name || "Copter" in body.name || "Spider" in body.name || "Boss" in body.name:
		print("yeeet")
		self.queue_free()
		var random_sound = randi() % 4
		impact_sounds[random_sound].play()

		body.health.take_damage(projectile_damage)
	

