extends KinematicBody2D

var velocity: Vector2 = Vector2.ZERO
var moving_left: bool = true
var game_over: bool = false
var state: int = State.MOVE

enum State {
	MOVE,
	IDLE,
	PENSIVE,
	SLEEP
}

signal movement(energy_consumption)
signal sleeping()
signal woke_up()


onready var idle_timer: Timer = $IdleTimer
onready var pensive_timer: Timer = $PensiveTimer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func get_input() -> Vector2:
	var input_vector: Vector2 = Vector2.ZERO
	input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input_vector.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	input_vector = input_vector.normalized()
	return input_vector
