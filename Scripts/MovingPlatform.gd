extends Node2D

export var pause_amount := 2.0
export var speed := 150.0

onready var pos1 := $MovePos1
onready var pos2 := $MovePos2

onready var platform = $Platform

onready var target = pos1

var paused_time := 0.0

func _ready():
	platform.position = target.position
	_set_track()

func _physics_process(delta):
	if platform.position != target.position:
		var diff = target.position - platform.position
		
		if diff.length() > speed * delta:	
			var prev_position = platform.position
			
			var velocity = diff.normalized() * speed * delta
			
			platform.move_and_collide(velocity)
			
			platform.position = prev_position + velocity
		else:
			platform.position = target.position
	else:
		paused_time += delta
		
		if paused_time > pause_amount:
			paused_time = 0
			target = pos1 if target == pos2 else pos2

func _set_track():
	var diff = pos2.position - pos1.position
	var rotation = diff.angle()
	var length = diff.length()
	$Track.rect_size.x = length
	$Track.rect_rotation = rad2deg(rotation)
	$Track.rect_position = pos1.position + Vector2(0, -32)
	
