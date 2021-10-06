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

signal cutscene_1_triggered
signal cutscene_2_triggered

var enemies_spawn = true
var actual_boss = preload("res://Enemy/ActualBoss1/Boss_1.tscn")
var actual_2_boss = preload("res://Enemy/ActualBoss2/Boss_2.tscn")
onready var animation_player : AnimationPlayer = get_node("Level 1/AnimationPlayer")
onready var scene_switcher = preload("res://Util/SceneSwitcher.tscn")

var level_one_done = false
var level_two_done = false
var is_dead = false
var has_won = false

func _process(delta):
	if level_one_done:
		print("level_one complete")
	
func _on_EnemySpawnTime_timeout():
	if enemies_spawn:
		var pilot = get_node("Pilot")
		var random_num = randi() % 3
		var e = enemies[random_num].instance()
		var pos = pilot.get_global_transform().origin
		
		if randf() < 0.5:
			pos.x -= rand_range(10.0, 20.0)
			pos.z -= rand_range(10.0, 20.0)
		else:
			pos.x += rand_range(10.0, 20.0)
			pos.z += rand_range(10.0, 20.0)

		e.transform.origin = pos
		for i in rand_range(2.0, 5.0):
			e.patrol_points = []
			var ptrl_pt = Position3D.new()
			ptrl_pt.transform.origin = pos + Vector3(rand_range(-10, 10), 0, rand_range(-10, 10))
			e.patrol_points.append(ptrl_pt)
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
		
	r.transform.origin = pos
	add_child(r)

func _on_CutsceneTrigger_body_entered(body):
	if "ech" in body.name:
		enemies_spawn = false
		get_node("Camera").current_target = ("boss_1")
		emit_signal("cutscene_1_triggered")

func _on_CutsceneTrigger_body_exited(body):
	get_node("CutsceneTrigger").queue_free()

func _on_Cutscene2Trigger_body_entered(body):
	if "ech" in body.name:
		enemies_spawn = false
		get_node("Camera").current_target = ("boss_2")
		emit_signal("cutscene_2_triggered")

func _on_Cutscene2Trigger_body_exited(body):
	get_node("Cutscene2Trigger").queue_free()

func _on_World1_cutscene_1_triggered():
	$"Level 1/AnimationPlayer".play("Cutscene")
	yield($"Level 1/AnimationPlayer", "animation_finished")
	var boss = get_node("Level 1/Boss")
	var pos = get_node("Level 1/Boss/Cone001").get_global_transform().origin
	var boss_actual = actual_boss.instance()
	boss_actual.global_transform.origin = pos
	get_node("Camera").set_current_target("mech")
	boss.queue_free()
	add_child(boss_actual)

func _on_World2_cutscene_2_triggered():
	$MechJam_Boss2/AnimationPlayer.play("Cutscene")
	yield($MechJam_Boss2/AnimationPlayer, "animation_finished")
	var boss = get_node("MechJam_Boss2")
	var pos = get_node("MechJam_Boss2/Armature/Skeleton/Boss2").get_global_transform().origin
	var boss_actual = actual_2_boss.instance()
	boss_actual.global_transform.origin = pos
	get_node("Camera").set_current_target("mech")
	boss.queue_free()
	add_child(boss_actual)
