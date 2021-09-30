extends Spatial

onready var enemies = [
	preload ("res://Enemy/Bomber/BomberBot.tscn"),
	preload ("res://Enemy/Copter/CopterBot.tscn"),
	preload ("res://Enemy/Spider/SpiderBot.tscn")
]

onready var resources = [
	preload ("res://Pickups/Energy/Energy.tscn"),
	preload ("res://Pickups/HealthKit/HealthKit.tscn")
]

var enemy = preload ("res://Enemy/Bomber/BomberBot.tscn")

func _on_EnemySpawnTime_timeout():
	var pilot = get_node("Pilot")
	var random_num = randi() % 3
	var e = enemies[random_num].instance()
	var pos = pilot.get_global_transform().origin
	
	if randf() < 0.5:
		pos.x -= rand_range(10.0, 14.0)
	else:
		pos.x += rand_range(10.0, 14.0)

	e.global_transform.origin = pos
	add_child(e)

func _on_ResourceSpawnTime_timeout():
	var pilot = get_node("Pilot")
	var random_num = randi() % 2
	var r = resources[random_num].instance()
	var pos = pilot.get_global_transform().origin
	
	if randf() < 0.5:
		pos.x -= rand_range(10.0, 20.0)
	else:
		pos.x += rand_range(10.0, 20.0)
		
	r.global_transform.origin = pos
	add_child(r)
