extends Spatial

onready var enemies = [
	preload ("res://Enemy/Bomber/BomberBot.tscn"),
	preload ("res://Enemy/Copter/CopterBot.tscn"),
	preload ("res://Enemy/Spider/SpiderBot.tscn")
]

var enemy = preload ("res://Enemy/Bomber/BomberBot.tscn")

func _on_EnemySpawnTime_timeout():
	var mech = get_node("Mech")
	var e = enemy.instance()
	var pos = mech.get_global_transform().origin
	
	if randf() < 0.5:
		pos.x -= rand_range(10.0, 14.0)
	else:
		pos.x += rand_range(10.0, 14.0)

	e.global_transform.origin = pos
	add_child(e)
