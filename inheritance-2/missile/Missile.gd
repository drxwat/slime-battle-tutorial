extends RigidBody2D
class_name Missile

export var damage := 1.0
export var ttl := 5.0

func _process(delta: float):
	ttl -= delta
	if delta <= 0:
		queue_free()

func _on_DamageArea_body_entered(body):
	if "hp" in body and not body.is_dead():
		body.take_damage(damage)
		queue_free()
