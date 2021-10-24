extends KinematicBody2D

export var ACCELERATION: int = 150
export var MAX_SPEED: int = 250
export var FRICTION: int = 100
export var MOVEMENT_ENERGY_CONSUMPTION: int = 1

var velocity: Vector2 = Vector2.ZERO
var moving_left: bool = false
var game_over: bool = false

signal movement(energy_consumption)

onready var animation_player: AnimationPlayer = $AnimationPlayer

func _physics_process(delta: float) -> void:
	if game_over:
		return
	var input_vector: Vector2 = Vector2.ZERO
	input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input_vector.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	input_vector = input_vector.normalized()

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

func game_over_sequence() -> void:
	# Stop movement from controls
	game_over = true
	# Show closed eyes frame
	animation_player.stop()
	$Sprite.frame = 4
	# TODO: Sink to bottom
	
	
