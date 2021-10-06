extends Control

onready var ani_player = $CreditsUIAnimationPlayer

func _ready():
	ani_player.play("credits_text_scroll")

func _on_CreditsUIAnimationPlayer_animation_finished(anim_name):
	if(anim_name == "credits_text_scroll"):
		get_tree().change_scene("res://Core/U WIN LOL/U WIN LOL.tscn")
