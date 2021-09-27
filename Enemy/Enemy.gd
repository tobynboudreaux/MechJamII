extends KinematicBody

var speed = 4
onready var pilot = get_parent().get_node("Pilot")
onready var mech = get_parent().get_node("Mech")
var dir
var stop_move

func _physics_process(delta):
	follow_player(delta);
	
func follow_player(delta):
	if pilot.is_mech == false:
		dir = (pilot.get_global_transform().origin - self.get_global_transform().origin).normalized()
	if pilot.is_mech == true:
		dir = (mech.get_global_transform().origin - self.get_global_transform().origin).normalized()
	else:
		dir = Vector3(0,0,0)
		
	var collision = move_and_collide(dir * speed * delta)
	if collision:
		return collision.collider.name
