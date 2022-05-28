extends Node2D

onready var camera := $ShakeCamera2D

var units: Array = []

func _ready():
	for unit in $Units.get_children():
		units.append(weakref(unit))
	Events.connect("missile_spawned", self, "spawn_missile")
	Events.connect("damage_taken", self, "shake_camera")


func _process(delta):
	for unit_ref in units:
		var unit = unit_ref.get_ref()
		if unit != null:
			camera.set_target(unit)
			return

func shake_camera():
	if camera.trauma <= 0.3:
		camera.add_trauma(0.2)
	
func spawn_missile(missile: Missile, m_position: Vector2, m_direction: Vector2, speed: float):
	missile.global_position = m_position
	missile.rotation = m_direction.angle()
	add_child(missile)
	missile.apply_central_impulse(m_direction * speed)
	
