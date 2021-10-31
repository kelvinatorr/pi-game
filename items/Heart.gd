extends Sprite

onready var animation_player: AnimationPlayer = $AnimationPlayer

func float_up_left_and_free(direction: int) -> void:
	if direction < 0:
		animation_player.play("FloatUpLeft")
	else:
		animation_player.play("FloatUpRight")
	yield(animation_player, "animation_finished")
	queue_free()
