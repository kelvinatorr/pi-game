extends KinematicBody2D

export var ACCELERATION: int = 150
export var MAX_SPEED: int = 250
export var FRICTION: int = 100
export var MOVEMENT_ENERGY_CONSUMPTION: int = 1

var velocity: Vector2 = Vector2.ZERO
var moving_left: bool = true
var game_over: bool = false
var state: int = State.MOVE
var heart_scene: PackedScene = preload("res://items/Heart.tscn")

enum State {
	MOVE,
	CHOMP,
	IDLE,
	PENSIVE,
	SLEEP
}

signal movement(energy_consumption)
signal pooping(butt_global_pos)
signal sleeping()
signal woke_up()
signal surfaced()

onready var animation_player: AnimationPlayer = $AnimationPlayer
onready var chomp_collision_shape: CollisionShape2D = $ChompPivot/ChomperArea/CollisionShape2D
onready var chomper_area: Area2D = $ChompPivot/ChomperArea
onready var chomp_pivot: Position2D = $ChompPivot
onready var butt_position: Node2D = $ButtPivot/ButtPosition
onready var idle_timer: Timer = $IdleTimer
onready var pensive_timer: Timer = $PensiveTimer
onready var poop_timer: Timer = $PoopTimer

func _physics_process(delta: float) -> void:
	if game_over:
		sink_to_bottom(delta)
		return
	var input_vector: Vector2 = get_input()
	
	if input_vector != Vector2.ZERO:
		if state == State.SLEEP:
			emit_signal("woke_up")
		state = State.MOVE
	else:
		if velocity == Vector2.ZERO and state != State.PENSIVE and state != State.SLEEP:
			state = State.IDLE
	
	if Input.is_action_just_pressed("chomp"):
		if state == State.SLEEP:
			emit_signal("woke_up")
		state = State.CHOMP
	
	if state != State.IDLE and !idle_timer.is_stopped():
		idle_timer.stop()
	
	if state != State.PENSIVE and !pensive_timer.is_stopped():
		pensive_timer.stop()
	
	if state != State.SLEEP and poop_timer.is_stopped():
		poop_timer.start()

	match state:
		State.MOVE:
			move_state(delta, input_vector)
		State.CHOMP:
			chomp_state()
		State.IDLE:
			idle_state()
		State.PENSIVE:
			pensive_state()
		State.SLEEP:
			sleep_state(delta)

func get_input() -> Vector2:
	var input_vector: Vector2 = Vector2.ZERO
	input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input_vector.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	input_vector = input_vector.normalized()
	return input_vector

func move_state(delta: float, input_vector: Vector2):
	if input_vector != Vector2.ZERO:
		if input_vector.x > 0:
			animation_player.play("SwimRight")
			moving_left = false
		elif input_vector.x < 0:
			animation_player.play("SwimLeft")
			moving_left = true
		elif input_vector.y < 0:
			if !moving_left:
				animation_player.play("SwimRight")
			else:
				animation_player.play("SwimLeft")
		elif input_vector.y > 0:
			if !moving_left:
				animation_player.play("SwimRight")
			else:
				animation_player.play("SwimLeft")
		velocity = velocity.move_toward(input_vector * MAX_SPEED, ACCELERATION * delta)
		# Emit movement signal
		emit_signal("movement", MOVEMENT_ENERGY_CONSUMPTION)
	else:
		if !moving_left:
			animation_player.play("SwimIdleRight")
		else:
			animation_player.play("SwimIdleLeft")
		velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)

	# Get the velocity back so that if a collision happened then it is retained and we can change 
	# directions faster
	velocity = move_and_slide(velocity, Vector2.UP) # Vector2.UP is Vector2(0, -1), pointing up
	
	if self.is_on_ceiling():
		for i in get_slide_count():
			var collision: KinematicCollision2D = get_slide_collision(i)
			if collision.collider.name == "Surface":
				emit_signal("surfaced")
				return

func sleep_state(delta: float) -> void:
	sink_to_bottom(delta)
	if !moving_left:
		animation_player.play("SleepRight")
	else:
		animation_player.play("SleepLeft")
	poop_timer.stop()

func pensive_state() -> void:
	$Sprite.frame = 11
	velocity = Vector2(0, sin(OS.get_ticks_msec() / 400.0) * 2.0)
	velocity = move_and_slide(velocity, Vector2.UP)
	if pensive_timer.is_stopped():
		pensive_timer.start()

func idle_state() -> void:
	if idle_timer.is_stopped():
		idle_timer.start()

func chomp_state() -> void:
	velocity = Vector2.ZERO
	chomp_collision_shape.disabled = false
	if !moving_left:
		chomp_pivot.rotation_degrees = 180
		animation_player.play("ChompRight")
	else:
		chomp_pivot.rotation_degrees = 0
		animation_player.play("ChompLeft")
	# Resume execution when animation is done playing.
	yield(animation_player, "animation_finished")
	chomp_collision_shape.disabled = true

func sink_to_bottom(delta: float) -> void:
	if self.is_on_floor():
		return
	var sink_vector: Vector2 = Vector2.DOWN
	velocity = velocity.move_toward(sink_vector * (MAX_SPEED * 0.1), FRICTION * delta)
	velocity = move_and_slide(velocity, Vector2.UP) # Vector2.UP is Vector2(0, -1), pointing up

func game_over_sequence() -> void:
	# Stop movement from controls
	game_over = true
	# Stop Poop timer so she doesn't continue to poop
	poop_timer.stop()
	# Show closed eyes frame
	animation_player.stop()
	$Sprite.frame = 8

func show_heart():
	# Spawn Heart Above Head
	var heart: Sprite = heart_scene.instance()
	add_child(heart)
	heart.global_position = chomper_area.global_position
	var float_direction: int = -1
	if abs(chomp_pivot.rotation_degrees) < 90:
		float_direction = 1
	heart.float_up_left_and_free(float_direction)

func _on_PoopTimer_timeout():
	# Toss coin, if tails (less than 0.5) she poops
	var flip_result: float = rand_range(0, 1)
	if flip_result >= 0.5:
		return

	emit_signal("pooping", butt_position.global_position)

func _on_IdleTimer_timeout() -> void:
	state = State.PENSIVE


func _on_PensiveTimer_timeout() -> void:
	emit_signal("sleeping")
	state = State.SLEEP
