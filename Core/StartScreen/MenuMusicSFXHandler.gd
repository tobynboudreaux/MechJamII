extends Node

onready var ui_pressed_sfx = $SelectSFX
onready var ui_focus_sfx = $FocusSFX
onready var audio_player = $MenuBGMusicPlayer

# On focus
func _on_StartButton_focus_entered():
	if(not ui_pressed_sfx.playing):
		ui_focus_sfx.play()

func _on_ContinueButton_focus_entered():
	if(not ui_pressed_sfx.playing):
		ui_focus_sfx.play()

func _on_PrevLevelsButton_focus_entered():
	ui_focus_sfx.play()

func _on_OptionsButton_focus_entered():
	ui_focus_sfx.play()

func _on_QuitButton_focus_entered():
	ui_focus_sfx.play()

func _on_Level1Button_focus_entered():
	if(not ui_pressed_sfx.playing):
		ui_focus_sfx.play()

func _on_Level2Button_focus_entered():
	ui_focus_sfx.play()

func _on_Level3Button_focus_entered():
	ui_focus_sfx.play()
	
func _on_LevelBackButton_focus_entered():
	ui_focus_sfx.play()
	
func _on_ResolutionHSlider_focus_entered():
	if(not ui_pressed_sfx.playing):
		ui_focus_sfx.play()
		
func _on_GraphicsOptionButton_focus_entered():
	ui_focus_sfx.play()
	
func _on_AAOptionButton_focus_entered():
	ui_focus_sfx.play()
	
func _on_FullscreenButton_focus_entered():
	ui_focus_sfx.play()
	
func _on_VsyncButton_focus_entered():
	ui_focus_sfx.play()
	
func _on_OptionsBackButton_focus_entered():
	ui_focus_sfx.play()
	
# ++++++++++++++++++++++++++++++++++++++++++++++++++++
# On pressed
func _on_StartButton_pressed():
	ui_pressed_sfx.play()

func _on_ContinueButton_pressed():
	ui_pressed_sfx.play()

func _on_PrevLevelsButton_pressed():
	ui_pressed_sfx.play()

func _on_OptionsButton_pressed():
	ui_pressed_sfx.play()

func _on_LevelBackButton_pressed():
	ui_pressed_sfx.play()

func _on_ResolutionHSlider_value_changed(_value):
	ui_pressed_sfx.play()

func _on_GraphicsOptionButton_item_selected(_index):
	ui_pressed_sfx.play()

func _on_AAOptionButton_item_selected(_index):
	ui_pressed_sfx.play()

func _on_FullscreenButton_pressed():
	ui_pressed_sfx.play()

func _on_VsyncButton_pressed():
	ui_pressed_sfx.play()

func _on_OptionsBackButton_pressed():
	ui_pressed_sfx.play()
