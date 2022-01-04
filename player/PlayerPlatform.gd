extends "res://player/PlayerBase.gd"

export var ACCELERATION: int = 150
export var MAX_SPEED: int = 250
export var FRICTION: int = 100
export var MOVEMENT_ENERGY_CONSUMPTION: int = 1

func _physics_process(delta: float) -> void:
	if game_over:
		return
	var input_vector: Vector2 = get_input()
	
	if input_vector != Vector2.ZERO:
		if state == State.SLEEP:
			emit_signal("woke_up")
		state = State.MOVE
	else:
		if velocity == Vector2.ZERO and state != State.PENSIVE and state != State.SLEEP:
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
		State.PENSIVE:
			pensive_state()
		State.SLEEP:
			sleep_state(delta)

func move_state(delta: float, input_vector: Vector2):
	if input_vector != Vector2.ZERO:		
		velocity = velocity.move_toward(input_vector * MAX_SPEED, ACCELERATION * delta)
		# Emit movement signal
		emit_signal("movement", MOVEMENT_ENERGY_CONSUMPTION)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)

	# Get the velocity back so that if a collision happened then it is retained and we can change 
	# directions faster
	velocity = move_and_slide(velocity, Vector2.UP) # Vector2.UP is Vector2(0, -1), pointing up

func idle_state():
	print("Idle state!")

func pensive_state():
	print("Pensive state!")

func sleep_state(delta: float):
	print("Sleep state!")
