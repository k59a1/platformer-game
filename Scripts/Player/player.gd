# NOTE, this is edited from stackoverflow, with my addition of coyote time, and a reddit post for the dash. this isn't directly my code.
extends CharacterBody2D
@onready var sprite := $AnimatedSprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var ceiling_check_left: RayCast2D = get_node_or_null("CeilingCheckLeft")
@onready var ceiling_check_right: RayCast2D = get_node_or_null("CeilingCheckRight")
const SPEED = 300.0
const CROUCH_SPEED_MULTIPLIER = 0.5
const SPRINT_MULTIPLIER = 1.6
const JUMP_VELOCITY = -400.0
const COYOTE_TIME = 0.15
const ACCELERATION = 1800.0
const FRICTION = 600.0
const DASH_SPEED = 700.0
const DASH_TIME = 0.2
const DASH_GROUND_COOLDOWN = 0.0  # set to 0 cuz i want it to be more like celeste
const HEIGHT_STANDING: float = 80.0
const HEIGHT_CROUCHING: float = 55.0
const CEILING_CHECK_MARGIN: float = 10.0
const CEILING_RAY_START_OFFSET: float = 25.0  # shifts the ray's start point down, so it doesn't begin inside the ceiling collider itself
const PLAYER_WIDTH: float = 50.0  # adjust to match your actual collision shape width
var target_height: float = HEIGHT_STANDING
var coyote_timer := 0.0
var facing_dir := 1.0  # 1 = right, -1 = left
var dash_timer := 0.0
var dash_cooldown_timer := 0.0
var can_dash := true
var dash_velocity := Vector2.ZERO
func _ready() -> void:
	var start_y := -HEIGHT_CROUCHING / 2.0 + CEILING_RAY_START_OFFSET
	var target_y := -(HEIGHT_STANDING - HEIGHT_CROUCHING + CEILING_CHECK_MARGIN + CEILING_RAY_START_OFFSET)
	if ceiling_check_left:
		ceiling_check_left.position = Vector2(-PLAYER_WIDTH / 2.0, start_y)
		ceiling_check_left.target_position = Vector2(0, target_y)
	else:
		push_warning("CeilingCheckLeft RayCast2D node not found.")
	if ceiling_check_right:
		ceiling_check_right.position = Vector2(PLAYER_WIDTH / 2.0, start_y)
		ceiling_check_right.target_position = Vector2(0, target_y)
	else:
		push_warning("CeilingCheckRight RayCast2D node not found.")
func _physics_process(delta: float) -> void:
	var wants_to_crouch := Input.is_action_pressed("ui_down")
	var blocked_by_ceiling := (ceiling_check_left != null and ceiling_check_left.is_colliding()) or (ceiling_check_right != null and ceiling_check_right.is_colliding())
	var crouching := wants_to_crouch or blocked_by_ceiling
	if crouching:
		target_height = HEIGHT_CROUCHING
	else:
		target_height = HEIGHT_STANDING
	var capsule: CapsuleShape2D = collision_shape.shape as CapsuleShape2D # yoinked from reddit
	if capsule:
		var old_height := capsule.height
		# smoothly interpolate height
		capsule.height = lerpf(capsule.height, target_height, delta * 10.0)
		var height_diff := capsule.height - old_height
		collision_shape.position.y -= height_diff * 0.5
		if ceiling_check_left:
			ceiling_check_left.position.y -= height_diff * 0.5  # keep raycast anchored to head as it shrinks
		if ceiling_check_right:
			ceiling_check_right.position.y -= height_diff * 0.5
	var on_floor := is_on_floor()
	# Add the gravity (skip while actively dashing, for a flat dash line).
	if not on_floor and dash_timer <= 0.0:
		velocity += get_gravity() * delta
	if on_floor:
		coyote_timer = COYOTE_TIME
		# being grounded keeps your dash continuously charged, celeste-style.
		can_dash = true
	else:
		coyote_timer -= delta
	if dash_cooldown_timer > 0.0:
		dash_cooldown_timer -= delta
	# Handle jump. Jumping ALWAYS resets and cancels dash, no matter what state dash is in.
	# Also blocked if a ceiling is directly overhead, so you can't jump into a low gap.
	if Input.is_action_just_pressed("ui_up") and coyote_timer > 0.0 and not blocked_by_ceiling:
		velocity.y = JUMP_VELOCITY
		coyote_timer = 0.0
		dash_timer = 0.0
		dash_cooldown_timer = 0.0
		can_dash = true
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
	if crouching:
		sprite.play("crouching")
	elif dash_timer > 0.0:
		sprite.play("jumping")  # jump animation looks good
	elif not is_on_floor():
		sprite.play("jumping")
	elif direction != 0.0:
		sprite.play("running")
	else:
		sprite.play("idle")
