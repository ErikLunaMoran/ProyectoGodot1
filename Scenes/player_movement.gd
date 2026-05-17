extends CharacterBody2D

@export var movement_speed : float = 150
@export var dash_speed : float = 300
@export var dash_duration : float = 0.3
@export var cooldown : float = 500
var health : float = 100:
	set(value):
		health = value
		%Health.value = value

var last_dash = Time.get_ticks_msec()
var character_direction : Vector2 = Vector2.ZERO
var dash_direction : Vector2 = Vector2.ZERO

func _physics_process(delta):
	var current_speed = movement_speed

	# 🕹️ Dirección
	if not is_dashing():
		character_direction.x = Input.get_axis("move_left", "move_right")
		character_direction.y = Input.get_axis("move_up", "move_down")
		character_direction = character_direction.normalized()
	else:
		character_direction = dash_direction
		current_speed = dash_speed

	# 🚶‍♂️ Movimiento y animaciones
	if is_dashing():
		velocity = dash_direction * dash_speed
		if %sprite.animation != "Dashing":
			%sprite.animation = "Dashing"
	elif character_direction != Vector2.ZERO:
		velocity = character_direction * movement_speed
		if %sprite.animation != "Walking":
			%sprite.animation = "Walking"
	else:
		velocity = velocity.move_toward(Vector2.ZERO, movement_speed)
		if %sprite.animation != "Idle":
			%sprite.animation = "Idle"

	move_and_slide()

	# ↔️ Flip del sprite (funciona para todas las animaciones)
	if character_direction.x > 0:
		%sprite.flip_h = false
	elif character_direction.x < 0:
		%sprite.flip_h = true


# 🔥 Comprueba si está dashing
func is_dashing() -> bool:
	return not $Timer.is_stopped()


# 🚀 Inicia el dash
func start_dash():
	var time_now = Time.get_ticks_msec()
	if (time_now - last_dash) < cooldown:
		return

	last_dash = time_now

	# Guarda la dirección del dash actual o la última dirección válida
	dash_direction = character_direction
	if dash_direction == Vector2.ZERO:
		dash_direction = Vector2.RIGHT if not %sprite.flip_h else Vector2.LEFT

	$Timer.wait_time = dash_duration
	$Timer.start()


# 🎯 Entrada del jugador
func _input(event):
	if Input.is_action_just_pressed("dash"):
		start_dash()


func take_damage(amount):
	health -= amount
	print(amount)

func _on_self_damage_body_entered(body):
	take_damage(body.damage)


func _on_timer_timeout():
	%Collision.set_deferred("disabled", true)
	%Collision.set_deferred("disabled", false)
