extends GridContainer

func _ready():
	refresh_buttons(true)

func refresh_buttons(connect = false):
	var children = get_children()

	for i in children.size():
		if connect:
			children[i].connect("pressed", self, "_on_level_button_click", [i + 1])

		if i < Global.level:
			children[i].disabled = false
		else:
			children[i].disabled = true

func _on_level_button_click(level_to_load: int):
	$"/root/SoundHandler".play_click()
	get_tree().change_scene("res://Scenes/Levels/" + str(level_to_load) + ".tscn")
