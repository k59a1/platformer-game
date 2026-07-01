# NOTE, this is edited from stackoverflow, with my addition of coyote time. this isn't directly my code.

extends CharacterBody2D

const SPEED = 300.0
const CROUCH_SPEED_MULTIPLIER = 0.5
const JUMP_VELOCITY = -400.0
const COYOTE_TIME = 0.15

const ACCELERATION = 1800.0  # how fast you speed up
const FRICTION = 600.0       # how fast you slow down (lower = longer slide)

var coyote_timer := 0.0

@onready var sprite := $AnimatedSprite2D

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	if is_on_floor():
		coyote_timer = COYOTE_TIME
	else:
		coyote_timer -= delta

	# Handle jump.
	if (Input.is_action_just_pressed("ui_accept") or Input.is_action_just_pressed("ui_up")) and coyote_timer > 0.0:
		velocity.y = JUMP_VELOCITY
		coyote_timer = 0.0

	var crouching := Input.is_action_pressed("ui_down")
	var direction := Input.get_axis("ui_left", "ui_right")

	var target_speed := SPEED
	if crouching:
		target_speed *= CROUCH_SPEED_MULTIPLIER

	if direction:
		velocity.x = move_toward(velocity.x, direction * target_speed, ACCELERATION * delta)
	else:
		velocity.x = move_toward(velocity.x, 0, FRICTION * delta)

	move_and_slide()

	update_animation(direction, crouching)


func update_animation(direction: float, crouching: bool) -> void:
	if direction != 0.0:
		sprite.flip_h = direction < 0.0

	if not is_on_floor():
		sprite.play("jumping")
	elif crouching:
		sprite.play("crouching")
	elif direction != 0.0:
		sprite.play("running")
	else:
		sprite.play("idle")
