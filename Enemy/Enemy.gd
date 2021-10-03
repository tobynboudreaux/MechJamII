extends KinematicBody

# For controlling current action.

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

#func _physics_process(delta):
#	choose_action(delta)
#	follow_player(delta)
	
#
#	if vel != Vector3.ZERO:
#		move_and_collide(vel)
#		look_at(transform.origin - vel.normalized(), Vector3.UP)
	
#func follow_player(delta):
#	if pilot.is_mech == false:
#		dir = (pilot.get_global_transform().origin - self.get_global_transform().origin).normalized()
#	if pilot.is_mech == true:
#		dir = (mech.get_global_transform().origin - self.get_global_transform().origin).normalized()
#	else:
#		dir = Vector3(0,0,0)
		
#	var collision = move_and_collide(dir * speed * delta)
	
#	if collision:
#		if collision.collider.name == "Mech" || collision.collider.name == "Pilot":
#			mech.health.take_damage(5)
