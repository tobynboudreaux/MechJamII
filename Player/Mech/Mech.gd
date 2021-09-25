extends KinematicBody

func _physics_process(delta):
	if Input.is_action_just_pressed("interact"):
		var player_parent = self.get_parent()
		var pilot_scene = load("res://Player/Pilot/Pilot.tscn")
		var pilot = pilot_scene.instance()
		player_parent.add_child(pilot)
		pilot.transform = self.transform
		self.queue_free()
		print("Did you see that??")
