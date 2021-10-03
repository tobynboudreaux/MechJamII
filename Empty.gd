extends Spatial

func _ready():
	ProjectSettings.load_resource_pack("res://graphics.pck")
	ProjectSettings.load_resource_pack("res://audio.pck")
	get_tree().change_scene("res://Core/StartScreen/StartScreen.tscn")
