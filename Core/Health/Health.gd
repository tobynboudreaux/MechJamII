extends Node

var max_hp
var current_health
	
func set_health(max_health):
	max_hp = max_health
	current_health = max_health
	
func take_damage(amount):
	current_health -= amount
	if current_health < 0:
		current_health = 0

func heal(amount):
	current_health += amount
	if current_health > max_hp:
		current_health = max_hp
