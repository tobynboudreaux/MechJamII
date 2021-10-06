extends Spatial

onready var ani_player = $Credits3DAnimationPlayer
onready var mech_ani_player = $MechSpin/Mech/AnimationTree

func _ready():
	ani_player.play("mech_spin")
