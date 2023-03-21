extends CanvasLayer


func _process(_delta):
		if Global.show_fps:
			$Label.visible = true
			$Label.text = "FPS:" + str(Performance.get_monitor(Performance.TIME_FPS))
		else:
			$Label.visible = false
