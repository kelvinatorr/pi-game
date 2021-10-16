extends KinematicBody2D

export var ACCELERATION: int = 350
export var MAX_SPEED: int = 500
export var FRICTION: int = 200

var velocity: Vector2 = Vector2.ZERO
var moving_left: bool = false

onready var animation_player: AnimationPlayer = $AnimationPlayer


func _physics_process(delta: float) -> void:
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
	else:
		if !moving_left:
			animation_player.play("SwimIdleRight")
		else:
			animation_player.play("SwimIdleLeft")
		velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)

	# Get the velocity back so that if a collision happened then it is retained and we can change 
	# directions faster	
	velocity = move_and_slide(velocity, Vector2.UP) # Vector2.UP is Vector2(0, -1), pointing up


