extends Label

export var ttl := 0.3
export var speed := 15

func _physics_process(delta):
	ttl -= delta
	if ttl <= 0:
		queue_free()
	rect_position.y -= delta * speed
	
func set_value(value: float):
	text = String(round(value))
	rect_position.x = - (rect_size.x / 4.0)
