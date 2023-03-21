extends CanvasLayer

var can_hide := false

func on_win():
	can_hide = false
	$WinDialog.popup_centered()
	get_tree().paused = true
	
func on_lose():
	can_hide = false
	$LoseDialog.popup_centered()
	get_tree().paused = true
	
func _next_level():
	can_hide = true
	$WinDialog.hide()
	$LoseDialog.hide()
	get_tree().change_scene("res://Scenes/Levels/" + str(Global.level) + ".tscn")
	
func _restart():
	can_hide = true
	$WinDialog.hide()
	$LoseDialog.hide()
	get_tree().reload_current_scene()
	
func _on_WinDialog_popup_hide():
	if can_hide:
		get_tree().paused = false
	else:
		$WinDialog.popup_centered()
		
func _on_LoseDialog_popup_hide():
	if can_hide:
		get_tree().paused = false
	else:
		$LoseDialog.popup_centered()
		
func _on_NextLevelButton_pressed():
	SoundHandler.play_click()
	_next_level()
	
func _on_RestartButton_pressed():
	SoundHandler.play_click()
	_restart()
	
func _on_MenuButton_pressed():
	SoundHandler.play_click()
	can_hide = true
	$WinDialog.hide()
	$LoseDialog.hide()
	get_tree().change_scene("res://Scenes/MainMenu.tscn")
