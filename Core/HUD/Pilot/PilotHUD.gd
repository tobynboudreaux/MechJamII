extends Control

func update_ammo_val(ammo_left):
	$Ammo.text = ammo_left
	
func update_dash_timer(timer_val):
	$DashBar.value = -timer_val

func update_reload_timer(reload_val):
	$ReloadBar.value = reload_val
