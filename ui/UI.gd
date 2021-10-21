extends CanvasLayer

onready var energy_bar: TextureProgress = $HUD/InfoBar/HBoxContainer/TextureProgress

func reduce_energy(val: float) -> void:
	energy_bar.value -= val
