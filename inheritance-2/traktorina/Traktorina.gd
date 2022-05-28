extends BasicSlime

export var strong_attack_multiplier := 1.5
export var strong_attack_period := 5.0

var time_to_next_strong_attack := strong_attack_period

onready var animation_player := $AnimationPlayer
onready var body := $GFX/Body
onready var graphix := $GFX
onready var strong_hit_impulse := 50.0
onready var weapon_sprite := $GFX/Weapon

func reset_strong_attack_calldown():
	time_to_next_strong_attack = strong_attack_period
	
func has_strong_attack():
	return time_to_next_strong_attack <= 0

func act(delta: float):
	if time_to_next_strong_attack >= 0:
		time_to_next_strong_attack -= delta
	.act(delta)

func stop():
	body.play("idle")
	.stop()
	
func attack(enemy: BasicSlime):
	animation_player.play("smash")
	reset_attack_calldown()

func on_melee_hit():
	if not get_target():
		reset_target()
		return
	var damage = calculate_damage(get_target())
	if has_strong_attack():
		damage = damage * strong_attack_multiplier
	get_target().take_damage(damage)
	var direction = global_position.direction_to(get_target().global_position)
	if not get_target().is_dead() and has_strong_attack():
		Events.emit_signal("damage_taken")
		reset_strong_attack_calldown()
		get_target().apply_central_impulse(get_target().global_position + (direction * strong_hit_impulse))

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
	$BodyCollision.set_deferred("disabled", true)
	body.play("die")
	yield(body, "animation_finished")
	.die()

func move_to(point: Vector2, speed: float):
	if not body.is_playing() or body.animation == "idle":
		body.play("move")
	graphix.scale.x = -1.0 if point.x <= global_position.x else 1.0
	.move_to(point, speed)
