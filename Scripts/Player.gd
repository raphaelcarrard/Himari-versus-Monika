extends KinematicBody2D

signal die

export(Texture) var full_heart
export(Texture) var empty_heart

export var move_speed_reg := 7500.0
export var move_speed_run := 15000.0
export var friction := 0.5
export var air_speed_reg := 2500.0
export var air_speed_run := 5000.0
export var jump_speed := 750.0
export var air_resistance := 0.8
export var gravity := 1700.0

export var invincibility_duration := 1.25

export var x_hurt_bounce_speed := 650.0
export var y_hurt_bounce_speed := 500.0

export var x_attack_bounce_speed := 0.0
export var y_attack_bounce_speed := 500.0

export var time_between_invincibility_blinks := 100000

export var health := 3

export var jump_continue_limit := 0.25

export var coyote_time = 75000

var can_jump_until = -1

var jump_continue := 0.0

var power_count := 0

onready var passthrough_raycast_down_left = $PassthroughRaycastDownLeft
onready var passthrough_raycast_down_right = $PassthroughRaycastDownRight
onready var passthrough_raycast_up_left = $PassthroughRaycastUpLeft
onready var passthrough_raycast_up_right = $PassthroughRaycastUpRight

var bullet = preload("res://Scenes/Bullet.tscn")

var air_speed
var move_speed
var velocity := Vector2.ZERO
var snapping := Vector2.DOWN * 15
var invincible_until := -1.0

var bounce := Vector2.ZERO

var next_shoot_time := -1
export var time_between_shots := 250000

onready var pause = preload("res://Scenes/Pause.tscn")

var dead = false

var on_floor_last_frame = true

var has_landed = false

func _ready():
	add_to_group("player")
	
	var pause_instance = pause.instance()
	$UI.add_child(pause_instance)
	
	power_count = Global.power_count
	_update_power_count()
	
	$Crown.visible = Global.has_won
	
func _process(_delta: float) -> void:
	if(
		Input.is_action_pressed("shoot")
		and next_shoot_time < OS.get_ticks_usec()
		and power_count > 0
	):
		SoundHandler.play_shoot()
		power_count -= 1
		_update_power_count()
		
		next_shoot_time = OS.get_ticks_usec() + time_between_shots
		var bullet_instance = bullet.instance()
		bullet_instance.direction = -1 if $AnimatedSprite.flip_h else 1
		bullet_instance.position = position + Vector2(bullet_instance.direction * 10, 0)
		get_parent().add_child(bullet_instance)
	change_animation()
	
	if invincible_until > OS.get_ticks_usec():
		var time_left = invincible_until - OS.get_ticks_usec()
		visible = (
			int (time_left) % time_between_invincibility_blinks
			< time_between_invincibility_blinks / 2
		)
		
func _physics_process(delta: float) -> void:
	_move(delta)
	_collide()
	
func change_animation():
	if velocity.x > 0:
		$AnimatedSprite.flip_h = false
	elif velocity.x < 0:
		$AnimatedSprite.flip_h = true
		
	if !is_on_floor():
		if velocity.y <= 0:
			$AnimatedSprite.play("jump")
		else:
			$AnimatedSprite.play("fall")
	elif abs(velocity.x) > 0.2:
			$AnimatedSprite.play("run")
	else:
			$AnimatedSprite.play("idle")
			
func _move(delta):
	if not on_floor_last_frame and is_on_floor() and has_landed:
		SoundHandler.play_land()
	has_landed = true if is_on_floor() and has_landed else false
	on_floor_last_frame = is_on_floor()
	
	if(
		not Input.is_action_pressed("down")
		and(
			passthrough_raycast_down_left.is_colliding()
			or passthrough_raycast_down_right.is_colliding()
		)
		and not(
			passthrough_raycast_up_left.is_colliding()
			or passthrough_raycast_up_right.is_colliding()
		)
	):
		set_collision_mask_bit(1, true)
	else:
		set_collision_mask_bit(1, false)
		
	if Input.is_action_pressed("run"):
		move_speed = move_speed_run
		air_speed = air_speed_run
	else:
		move_speed = move_speed_reg
		air_speed = air_speed_reg
		
	if is_on_floor():
		can_jump_until = OS.get_ticks_usec() + coyote_time
		velocity.x *= friction
		
		var input_speed = ((Input.get_action_strength("right") - Input.get_action_strength("left")) 
				* move_speed * delta)
		
		velocity.x += input_speed
		
		if input_speed > 0:
			SoundHandler.play_walk()
			
	else:
		velocity.x *= air_resistance
		velocity.x += (
			(Input.get_action_strength("right") - Input.get_action_strength("left"))
			* air_speed
			* delta
		)
		
	if Input.is_action_just_pressed("jump") and can_jump_until > OS.get_ticks_usec():
		SoundHandler.play_jump()
		jump_continue += delta
		velocity.y = -jump_speed
		snapping = Vector2.ZERO
		can_jump_until = -1
	elif(
		Input.is_action_just_pressed("jump")
		and jump_continue > 0
		and jump_continue < jump_continue_limit
	):
		jump_continue += delta
		velocity.y = -jump_speed
	else:
		jump_continue = 0
		snapping = Vector2.DOWN * 5
		
	if is_on_ceiling():
		jump_continue = 0
		
	if bounce.length_squared() > 0:
		velocity += bounce
		bounce = Vector2.ZERO
		snapping = Vector2.ZERO
		
	velocity.y += gravity * delta
	
	velocity = move_and_slide_with_snap(velocity, snapping, Vector2.UP, true)
	
func _collide():
	for i in get_slide_count():
		var collision = get_slide_collision(i)
		
		if collision.collider.is_in_group("enemy"):
			var direction = -1 if collision.normal.x < 0 else 1
			_hit(direction)
			
		if collision.collider.is_in_group("greenliquid"):
			_die(1)
			
func hit(direction):
	_hit(direction)
	
func _hit(direction):
	if invincible_until < OS.get_ticks_usec():
		SoundHandler.play_player_hit()
		invincible_until = OS.get_ticks_usec() + invincibility_duration * 1000000
		health -= 1
		if health == 0:
			_die()
		bounce.y = -y_hurt_bounce_speed
		bounce.x = direction * x_hurt_bounce_speed
		$Camera.shake()
		_update_health()
		
func _update_health():
	$UI/Heart3.texture = full_heart if health >= 3 else empty_heart
	$UI/Heart2.texture = full_heart if health >= 2 else empty_heart
	$UI/Heart1.texture = full_heart if health >= 1 else empty_heart
		

func _die(cause = 0):
	if not dead:
		match cause:
			0:
				SoundHandler.play_lose()
			1:
				SoundHandler.play_greenliquid_lose()
		emit_signal("die")
		power_count = 0
		Global.power_count = 0
		Global.save_to_file()
		dead = true
		
func collect(type):
	match type:
		1:
			_collect_drop()
			
func _collect_drop():
	SoundHandler.play_drop()
	power_count += 1
	_update_power_count()

func _update_power_count():
	$UI/PowerDropCount.text = str(power_count)
	Global.power_count = power_count
	
func _on_DeathPlane_body_entered(body):
	if body == self:
		health = 0
		_update_health()
		_die()
