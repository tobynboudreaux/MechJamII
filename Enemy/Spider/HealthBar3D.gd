extends Sprite3D

export (float) var max_health

onready var health2D = $Viewport/HealthBar2D

func _ready():
	self.texture = $Viewport.get_texture()
	health2D.set_max_health(max_health)

func update(value):
	health2D.update_bar(value)
