extends KinematicBody

var speed = 10
onready var player = get_parent().get_node("Player")

func _physics_process(delta):
	var dir = (player.get_global_transform().origin - self.get_global_transform().origin).normalized()
	return move_and_collide(dir * speed * delta)
