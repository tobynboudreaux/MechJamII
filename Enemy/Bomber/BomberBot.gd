extends "res://Enemy/Enemy.gd"

func _physics_process(delta):
	$AnimationTree["parameters/IsAttack/current"] = 0
	$AnimationTree["parameters/IsMove/blend_amount"] = 1
	
	if is_in_range():
		$AnimationTree["parameters/IsAttack/current"] = 1
	if follow_player(delta) == "Pilot":
		$AnimationTree["parameters/IsAlive/current"] = 1

func is_in_range():
	if pilot.get_global_transform().origin.distance_to(self.get_global_transform().origin) < 3:
		return true
