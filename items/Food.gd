extends KinematicBody2D

signal chomped(energy_value)

func _ready():
	$ChompArea.connect('area_entered', self, '_on_ChompArea_area_entered')

func _on_ChompArea_area_entered(area):
	# create a one shot timer so that it doesn't disappear right away
	# and waits for the animation to finish
	yield(get_tree().create_timer(0.4), 'timeout')
	emit_signal("chomped", self.ENERGY_VALUE, self.show_heart)
	queue_free()
