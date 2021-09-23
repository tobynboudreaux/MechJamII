extends Spatial

signal level_changed(level_name)

export (String) var level_name = "level1"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
	
func death():
	emit_signal("level_changed", level_name)
