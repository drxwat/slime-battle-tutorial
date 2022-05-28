extends "res://inheritance-2/vladlen/Vladlen.gd"

func _ready():
	yield($AnimationPlayer, "animation_finished")
	body.play("idle")
	yield(get_tree().create_timer(2), "timeout")
	body.play("idle")
	$AnimationPlayer.play("shot", -1, 0.3)
	yield($AnimationPlayer, "animation_finished")
	$AnimationPlayer.play("shot", -1, 0.3)
	yield($AnimationPlayer, "animation_finished")
	$AnimationPlayer.play("shot", -1, 0.3)
	yield($AnimationPlayer, "animation_finished")
	$GFX/Weapon.hide()
	$GFX/Arrow.hide()
	body.play("die")

func act(delta: float):
	pass
