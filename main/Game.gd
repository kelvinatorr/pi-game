extends Node2D

var turtle_health: int = 1000
var energy_per_second: int = 1

func _ready() -> void:
	$EnergyTimer.start()

func _on_EnergyTimer_timeout() -> void:
	turtle_health -= energy_per_second
	if turtle_health < 0:
		print('Game Over')
	else:
		$UI.update_energy(turtle_health)
