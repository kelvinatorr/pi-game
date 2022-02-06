extends "res://player/PlayerBase.gd"

export var ACCELERATION: int = 30
export var MAX_SPEED: int = 60
export var FRICTION: int = 300
export var MOVEMENT_ENERGY_CONSUMPTION: int = 1

onready var animation_tree: AnimationTree = $AnimationTree
onready var animation_state: AnimationNodeStateMachinePlayback = animation_tree.get("parameters/playback")
onready var touch_area_lat: CollisionShape2D = $TouchArea/LateralCS2D
onready var touch_area_long: CollisionShape2D = $TouchArea/LongitudinalCS2D2
onready var collide_area_lat: CollisionShape2D = $LateralCollisionShape
onready var collide_area_long: CollisionShape2D = $LongitudinalCollisionShape

var last_input_vector: Vector2 = Vector2.ZERO

signal slid_down_ramp()

func _ready() -> void:
	var ready_blend_position: Vector2 = animation_tree.get("parameters/Idle/blend_position")
	activate_shape(ready_blend_position)

func _physics_process(delta: float) -> void:
	if game_over:
		return
	var input_vector: Vector2 = get_input()

	if input_vector != Vector2.ZERO:
		if state == State.SLEEP:
			emit_signal("woke_up")
		state = State.MOVE
	else:
		if (velocity == Vector2.ZERO and state != State.PENSIVE and state != State.SLEEP 
			and state != State.HIDE):
			state = State.IDLE
	
	if Input.is_action_just_pressed("feed_shrimp"):
		state = State.HIDE
	if state == State.HIDE and Input.is_action_just_released("feed_shrimp"):
		state = State.IDLE
	
	if state != State.IDLE and !idle_timer.is_stopped():
		idle_timer.stop()
	
	if state != State.PENSIVE and !pensive_timer.is_stopped():
		pensive_timer.stop()

	match state:
		State.MOVE:
			move_state(delta, input_vector)
		State.IDLE:
			idle_state()
		State.SLEEP:
			sleep_state()
		State.HIDE:
			hide()

func move_state(delta: float, input_vector: Vector2):
	if input_vector != Vector2.ZERO:
		animation_tree.set("parameters/Idle/blend_position", input_vector)
		animation_tree.set("parameters/Crawl/blend_position", input_vector)
		animation_tree.set("parameters/Sleep/blend_position", input_vector)
		animation_tree.set("parameters/Annoyed/blend_position", input_vector)
		animation_tree.set("parameters/Hide/blend_position", input_vector)
		animation_state.travel("Crawl")
		if not changed_dir(input_vector):
			velocity = velocity.move_toward(input_vector * MAX_SPEED, ACCELERATION * delta)
		else:
			velocity = Vector2.ZERO
		# Emit movement signal
		emit_signal("movement", MOVEMENT_ENERGY_CONSUMPTION)
		activate_shape(input_vector)
	else:
		animation_state.travel("Idle")
		velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)

	last_input_vector = input_vector
	# Get the velocity back so that if a collision happened then it is retained and we can change 
	# directions faster
	velocity = move_and_slide(velocity, Vector2.UP) # Vector2.UP is Vector2(0, -1), pointing up
	
	if self.is_on_wall():
		# Check if collided with right wall
		if self.get_which_wall_collided():
			emit_signal("slid_down_ramp")

func changed_dir(input_vector: Vector2) -> bool:
	if ((input_vector.x < 0 and last_input_vector.x >= 0) 
		or (input_vector.x > 0 and last_input_vector.x <= 0)):
		return true
	if ((input_vector.y < 0 and last_input_vector.y >= 0) 
		or (input_vector.y > 0 and last_input_vector.y <= 0)):
		return true
	return false

func activate_shape(input_vector: Vector2) -> void:
	var iv: Vector2 = input_vector.abs()
	if iv.x > iv.y:
		touch_area_lat.disabled = false
		touch_area_long.disabled = true
		collide_area_lat.disabled = false
		collide_area_long.disabled = true
	elif iv.x < iv.y:
		touch_area_lat.disabled = true
		touch_area_long.disabled = false
		collide_area_lat.disabled = true
		collide_area_long.disabled = false
	else:
		touch_area_lat.disabled = false
		touch_area_long.disabled = true
		collide_area_lat.disabled = false
		collide_area_long.disabled = true

func poked() -> void:
	if state == State.HIDE:
		return
	animation_state.travel("Annoyed")
	state = State.IDLE

func hide() -> void:
	animation_state.travel("Hide")

func idle_state() -> void:
	if animation_state.get_current_node() != "Idle":
		animation_state.travel("Idle")
	if idle_timer.is_stopped():
		idle_timer.start()

func sleep_state() -> void:
	animation_state.travel("Sleep")

func _on_IdleTimer_timeout() -> void:
	emit_signal("sleeping")
	state = State.SLEEP


func _on_TouchArea_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event.is_action_pressed("poke"):
		poked()
