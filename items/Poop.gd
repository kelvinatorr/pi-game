extends RigidBody2D

export var ENERGY_VALUE: int = 1

var show_heart: bool = false

func _on_ChompArea_area_entered(area):
	self.linear_velocity = Vector2.ZERO
	# create a one shot timer so that it doesn't disappear right away
	# and waits for the animation to finish
	yield(get_tree().create_timer(0.4), 'timeout')
	queue_free()


