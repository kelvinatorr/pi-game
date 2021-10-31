extends KinematicBody2D

export var ACCELERATION: int = 150
export var MAX_SPEED: int = 250
export var FRICTION: int = 100
export var MOVEMENT_ENERGY_CONSUMPTION: int = 1

var velocity: Vector2 = Vector2.ZERO
var moving_left: bool = false
var game_over: bool = false
var state: int = State.MOVE
var heart_scene: PackedScene = preload("res://items/Heart.tscn")

enum State {
	MOVE,
	CHOMP
}

signal movement(energy_consumption)
signal chomp_success(energy_value)

onready var animation_player: AnimationPlayer = $AnimationPlayer
onready var chomp_collision_shape: CollisionShape2D = $ChompPivot/ChomperArea/CollisionShape2D
onready var chomper_area: Area2D = $ChompPivot/ChomperArea
onready var chomp_pivot: Position2D = $ChompPivot

func _physics_process(delta: float) -> void:
	if game_over:
		sink_to_bottom(delta)
		return
	match state:
		State.MOVE:
			move_state(delta)
		State.CHOMP:
			chomp_state()

func move_state(delta):
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
	
	if Input.is_action_just_pressed("chomp"):
		state = State.CHOMP

func chomp_state() -> void:
	velocity = Vector2.ZERO
	chomp_collision_shape.disabled = false
	if !moving_left:
		animation_player.play("ChompRight")
	else:
		animation_player.play("ChompLeft")
	# Resume execution when animation is done playing.
	yield(animation_player, "animation_finished")
	chomp_collision_shape.disabled = true
	state = State.MOVE

func sink_to_bottom(delta: float) -> void:
	if self.is_on_floor():
		return
	var sink_vector: Vector2 = Vector2.DOWN
	velocity = velocity.move_toward(sink_vector * (MAX_SPEED * 0.1), FRICTION * delta)
	velocity = move_and_slide(velocity, Vector2.UP) # Vector2.UP is Vector2(0, -1), pointing up

func game_over_sequence() -> void:
	# Stop movement from controls
	game_over = true
	# Show closed eyes frame
	animation_player.stop()
	$Sprite.frame = 8

func _on_ChomperArea_area_entered(area: Area2D):
	var food: Node2D = area.get_parent()
	# Spawn Heart Above Head
	var heart: Sprite = heart_scene.instance()
	add_child(heart)
	heart.global_position = chomper_area.global_position
	var float_direction: int = -1
	if abs(chomp_pivot.rotation_degrees) < 90:
		float_direction = 1
	heart.float_up_left_and_free(float_direction)
	# Emit Chomp Success
	emit_signal("chomp_success", food.ENERGY_VALUE)
