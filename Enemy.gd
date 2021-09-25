extends KinematicBody

var speed = 10
onready var pilot = get_parent().get_node("Pilot")
onready var mech = get_parent().get_node("Mech")

#func _physics_process(delta):
#	var dir = (pilot.get_global_transform().origin - self.get_global_transform().origin).normalized()
#	return move_and_collide(dir * speed * delta)
