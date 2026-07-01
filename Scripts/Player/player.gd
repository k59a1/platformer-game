# NOTE, this is edited from stackoverflow, with my addition of coyote time, and a reddit post for the dash. this isn't directly my code.
extends CharacterBody2D
const SPEED = 300.0
const CROUCH_SPEED_MULTIPLIER = 0.5
const SPRINT_MULTIPLIER = 1.6
const JUMP_VELOCITY = -400.0
const COYOTE_TIME = 0.15
const ACCELERATION = 1800.0
const FRICTION = 600.0
const DASH_SPEED = 700.0
const DASH_TIME = 0.2
const DASH_GROUND_COOLDOWN = 0.4  # min time between dashes, even when grounded
var coyote_timer := 0.0
var facing_dir := 1.0  # 1 = right, -1 = left
var dash_timer := 0.0
var dash_cooldown_timer := 0.0
var can_dash := true
var dash_velocity := Vector2.ZERO
@onready var sprite := $AnimatedSprite2D
func _physics_process(delta: float) -> void:
	# Add the gravity (skip while actively dashing, for a flat dash line).
	if not is_on_floor() and dash_timer <= 0.0:
		velocity += get_gravity() * delta
	if is_on_floor():
		coyote_timer = COYOTE_TIME
		can_dash = true
	else:
		coyote_timer -= delta
	if dash_cooldown_timer > 0.0:
		dash_cooldown_timer -= delta
	# Handle jump.
	if Input.is_action_just_pressed("ui_up") and coyote_timer > 0.0 and dash_timer <= 0.0:
		velocity.y = JUMP_VELOCITY
		coyote_timer = 0.0
		can_dash = true
	var crouching := Input.is_action_pressed("ui_down")
	var direction := Input.get_axis("ui_left", "ui_right")
	var sprinting := Input.is_action_pressed("sprint")
	if direction != 0.0:
		facing_dir = sign(direction)
	# start dash
	if Input.is_action_just_pressed("ui_accept") and can_dash and dash_timer <= 0.0 and dash_cooldown_timer <= 0.0:
		dash_timer = DASH_TIME
		dash_cooldown_timer = DASH_GROUND_COOLDOWN
		can_dash = false
		dash_velocity = Vector2(facing_dir, 0) * DASH_SPEED
	if dash_timer > 0.0:
		dash_timer -= delta
		velocity = dash_velocity
	else:
		var target_speed := SPEED
		if crouching:
			target_speed *= CROUCH_SPEED_MULTIPLIER
		elif sprinting:
			target_speed *= SPRINT_MULTIPLIER
		if direction:
			velocity.x = move_toward(velocity.x, direction * target_speed, ACCELERATION * delta)
		else:
			velocity.x = move_toward(velocity.x, 0, FRICTION * delta)
	move_and_slide()
	update_animation(direction, crouching)
func update_animation(direction: float, crouching: bool) -> void:
	if direction != 0.0:
		sprite.flip_h = direction < 0.0
	if dash_timer > 0.0:
		sprite.play("jumping")  # jump animation looks good
	elif not is_on_floor():
		sprite.play("jumping")
	elif crouching:
		sprite.play("crouching")
	elif direction != 0.0:
		sprite.play("running")
	else:
		sprite.play("idle")
