extends Control

onready var mission_info_text = $InfoUICanvasLayer/CenterContainer/MissionInfo
onready var mission_info_ani_player = $MenuInfoAnimationPlayer

func _ready():
	mission_info_ani_player.play("mission_text_blink")
