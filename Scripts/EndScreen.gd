extends Control

func _ready():
	$MenuButton.grab_focus()
	
	if Global.good_ending:
		$Label3.text = "You pressed the delete button on Monika and saved everyone"
		$TextureRectWin.visible = true
		$TextureRectLose.visible = false
	else:
		$Label3.text = "But you don't pressed the delete button... so Just Monika!"
		$TextureRectWin.visible = false
		$TextureRectLose.visible = true
		
func _on_MenuButton_pressed():
	get_tree().change_scene("res://Scenes/MainMenu.tscn")
