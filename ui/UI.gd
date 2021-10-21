extends CanvasLayer

onready var energy_bar: TextureProgress = $HUD/InfoBar/HBoxContainer/TextureProgress
onready var energy_bar_tween: Tween = $HUD/InfoBar/HBoxContainer/TextureProgress/Tween

func update_energy(val: int) -> void:
	energy_bar.value = val
	energy_bar_tween.interpolate_property(energy_bar, 'value',
		energy_bar.value, val, 1,
		Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	energy_bar_tween.start()

	if energy_bar.value >= 600:
		energy_bar.set_tint_progress('12b624') # Green
	elif energy_bar.value <= 600 and energy_bar.value >= 250:
		energy_bar.set_tint_progress('e1be32') # Orange
	else:
		energy_bar.set_tint_progress('e11e1e') # Red
