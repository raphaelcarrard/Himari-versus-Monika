extends Node2D

export var speed = 1000
export var direction = 1

func _ready():
	$PowerBullet.flip_h = direction < 0
	
func _physics_process(delta):
	position.x += delta * speed * direction
	
func _on_Area2D_body_entered(body):
	if body.has_method("hit"):
		body.hit(speed / abs(speed))
		
	queue_free()
