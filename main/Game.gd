extends Node

var turtle_energy: int = 1000
var energy_per_second: int = 1
var game_over: bool = false

signal game_over()

func _ready() -> void:
	$EnergyTimer.start()

func _on_EnergyTimer_timeout() -> void:
	reduce_energy(energy_per_second)

func _on_Player_movement(energy_consumption) -> void:
	reduce_energy(energy_consumption)

func reduce_energy(val: int) -> void:
	if game_over:
		return
	turtle_energy -= energy_per_second	
	if turtle_energy < 0:
		game_over()
	else:
		$UI.update_energy(turtle_energy)

func game_over() -> void:
	print('Game Over')
	$Player.game_over_sequence()
	emit_signal("game_over")
	$EnergyTimer.stop()
	game_over = true
