extends Node2D

export var type := 0

func _on_Area2D_body_entered(body):
	if body.is_in_group("player") and $Sprite.visible:
		body.collect(type)
		
		$Particles2D.emitting = true
		
		$Sprite.visible = false
		
		var timer = Timer.new()
		timer.connect("timeout", self, "_on_timer_timeout")
		
		timer.wait_time = 2
		
		add_child(timer)
		
		timer.start()
		
func _on_timer_timeout():
	queue_free()
