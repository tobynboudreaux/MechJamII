extends Spatial

onready var anim_player = $MenuAnimationPlayer
onready var pilot_anim_player = $PilotNode/MechJam_Player/AnimationPlayer

func _ready():
	anim_player.play("Camera_Pan")
	pilot_anim_player.play("01_Idle")
