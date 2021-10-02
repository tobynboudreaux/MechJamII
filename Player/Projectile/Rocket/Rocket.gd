extends "res://Player/Projectile/Projectile.gd"

onready var ex_sounds = [
	get_node("Rocket/Sounds/Ex1"),
	get_node("Rocket/Sounds/Ex2"),
	get_node("Rocket/Sounds/Ex3"),
	get_node("Rocket/Sounds/Ex4")
]

func _on_Rocket_body_entered(body):
	print(body)
	
	if "Bomber" in body.name || "Copter" in body.name || "Spider" in body.name || "Boss" in body.name:
		print("yeeet")
		self.queue_free()
		var random_sound = randi() % 3
		ex_sounds[random_sound].play()
		body.health.take_damage(projectile_damage)
