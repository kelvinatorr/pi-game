extends Node2D

var turtle_energy: int = 1000
var energy_per_second: int = 1

func _ready() -> void:
	$EnergyTimer.start()

func _on_EnergyTimer_timeout() -> void:
	reduce_energy(energy_per_second)

func _on_Player_movement(energy_consumption) -> void:
	reduce_energy(energy_consumption)

func reduce_energy(val: int):
	turtle_energy -= energy_per_second
	if turtle_energy < 0:
		print('Game Over')
	else:
		$UI.update_energy(turtle_energy)
