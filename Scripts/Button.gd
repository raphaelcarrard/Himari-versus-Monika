extends StaticBody2D

var button_down = preload("res://Sprites/Level/ButtonDown.png")


func _on_Area2D_body_entered(body):
	if body.is_in_group("player"):
		$Sprite.texture = button_down
		$ButtonParticles.emitting = true
		Global.has_won = true
		Global.good_ending = true
		Global.save_to_file()
