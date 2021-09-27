extends Node

var max_health = 100
var current_health

func _ready():
	current_health = max_health
	
func take_damage(amount):
	current_health -= amount

func heal(amount):
	current_health += amount
