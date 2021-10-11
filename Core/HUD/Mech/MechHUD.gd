extends Control

func _ready():
	self.visible = true
	
func hide_hud(hide_bool):
	self.visible = !hide_bool
	
func set_health_bar(value):
	$HealthBar._on_health_updated(value)
	
func set_health_bar_max(value):
	$HealthBar._on_max_health_updated(value)
