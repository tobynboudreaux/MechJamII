extends Node

onready var bgm = $LoseUIBGM
onready var focus_sfx = $WinLoseFocusSFX
onready var select_sfx = $WinLoseSelectSFX

func _ready():
	bgm.play()

# -------------
# Focus
# -------------
func _on_RetryLevelButton_focus_entered():
	focus_sfx.pitch_scale = ((randf()*1.5)+0.5)
	focus_sfx.play()

func _on_BackToMenuButton_focus_entered():
	focus_sfx.pitch_scale = ((randf()*1.5)+0.5)
	focus_sfx.play()

# -------------
# Select
# -------------
func _on_RetryLevelButton_pressed():
	select_sfx.play()

func _on_BackToMenuButton_pressed():
	select_sfx.play()
