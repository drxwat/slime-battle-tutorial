extends BasicSlime

export var flee_range_radius := 0.5
export var flee_move_penalty := 0.5
export var arrow_speed := 120.0

onready var arrow_scene := preload("res://inheritance-2/arrow/Arrow.tscn")
onready var animation_player := $AnimationPlayer
onready var arrow_gfx := $GFX/Arrow
onready var graphix := $GFX
onready var debug_line := $Node/DebugLine2D
onready var body := $GFX/Body
onready var attack_area_shape := $AttackArea/AttackAreaCollisionShape
onready var weapon_sprite := $GFX/Weapon

var shot_offset := Vector2(0, -5)

func act(delta: float):
	if get_target():
		turn_to_target()
	if get_target() and not is_target_in_attack_range:
		move_to(get_target().global_position, speed)
	var is_feeing = get_target() and is_target_in_flee_radius()
	if is_feeing:
		flee()
	if not get_target() or is_target_in_attack_range and not is_feeing:
		stop()
	if can_attack_target():
		attack(get_target())

func flee():
	var direction = -global_position.direction_to(get_target().global_position)
	.move_to(global_position + (direction * 100), speed * flee_move_penalty)

func is_target_in_flee_radius() -> bool:
	var attack_radius = attack_area_shape.shape.radius
	if global_position.distance_to(get_target().global_position) <= (attack_radius * flee_range_radius):
		return true
	return false

func attack(enemy: BasicSlime):
	reset_attack_calldown()
	animation_player.play("shot")
	yield(animation_player, "animation_finished")
	spawn_arrow()
	
func spawn_arrow():
	var arrow = arrow_scene.instance()
	arrow.damage = calculate_damage(get_target())
	Events.emit_signal(
		"missile_spawned", 
		arrow, 
		arrow_gfx.global_position, 
		arrow_gfx.global_position.direction_to(get_target().global_position + shot_offset),
		arrow_speed
	)

func stop():
	body.play("idle")
	.stop()

func turn_to_target():
	graphix.scale.x = -1.0 if get_target().global_position.x <= global_position.x else 1.0
	
func move_to(point: Vector2, speed: float):
	if not body.is_playing():
		body.play("move")
	turn_to_target()
	.move_to(point, speed)

func take_damage(damage: float):
	body.play("take_damage")
	.take_damage(damage)
	yield(body, "animation_finished")
	if not is_dead():
		body.play("move")

func die():
	hp_bar.visible = false
	name_label.visible = false
	weapon_sprite.hide()
	$BodyCollisionShape2D.set_deferred("disabled", true)
	body.play("die")
	yield(body, "animation_finished")
	.die()
