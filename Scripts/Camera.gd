extends Camera2D

var default_shake_amount := 5.0
var default_shake_speed := 0.00008
var default_shake_decay := 10.0
var default_max_roll := 0.0
var default_max_offset := 10.0

var shake_amount := 0.0
var shake_speed := default_shake_speed
var shake_decay := default_shake_decay
var max_roll := default_max_roll
var max_offset := default_max_offset

onready var noise = OpenSimplexNoise.new()

func _ready():
	randomize()
	noise.seed = randi()
	noise.period = 4
	noise.octaves = 2
	
func _process(delta):
	if shake_amount > 0:
		rotation = (
			max_roll
			* shake_amount
			* noise.get_noise_2d(noise.seed, OS.get_ticks_usec() * shake_speed)
		)
		offset.x = (
			max_offset
			* shake_amount
			* noise.get_noise_2d(noise.seed * 2, OS.get_ticks_usec() * shake_speed)
		)
		offset.y = (
			max_offset
			* shake_amount
			* noise.get_noise_2d(noise.seed * 3, OS.get_ticks_usec() * shake_speed)
		)
		shake_amount -= delta * shake_decay
	else:
		rotation = 0
		offset.x = 0
		offset.y = 0
		
func shake(
	amount := default_shake_amount,
	decay := default_shake_decay,
	speed := default_shake_speed,
	roll := default_max_roll,
	offset := default_max_offset
):
	shake_amount = amount
	shake_decay = decay
	shake_speed = speed
	max_roll = roll
	max_offset = offset
