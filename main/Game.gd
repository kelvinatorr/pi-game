extends Node2D


func _ready() -> void:
	$EnergyTimer.start()

func _on_EnergyTimer_timeout() -> void:
	print('Energy Timer tick')
	$UI.reduce_energy(0.1)
