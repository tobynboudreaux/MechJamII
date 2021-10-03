extends Control

signal level_changed(level_name)

onready var mech_hud = self.get_child(0)
onready var pilot_hud = self.get_child(1)
onready var pause_menu = self.get_child(2)

func _ready():
	pass #ass
	
func change_level(level_name):
	emit_signal("level_changed", level_name)
	
# Triggered function by the player.gd script
func handle_pause():
	pause_menu.handle_pause()
	
func handle_mech_hud():
	mech_hud.visible = !mech_hud.visible
