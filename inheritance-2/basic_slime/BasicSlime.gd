extends RigidBody2D
class_name BasicSlime

const damage_label_scene := preload("res://inheritance-2/damage_label/DamageLabel.tscn")

export var speed := 10.0
export var damage := 5.0
export var hp := 40.0
export var attack_period := 2.0
export var damage_percent_range := 0.2
export var armor := 0.0


var _target = null setget set_target, get_target
var time_to_next_attack := 0.0
var is_target_in_attack_range := false
var max_hp := hp
var rng := RandomNumberGenerator.new()

onready var hp_bar := $HpBar
onready var damage_label_origin := $DamageLabelOrigin
onready var name_label := $Label

func _ready():
	rng.randomize()
	max_hp = hp # дочерний класс перепишет значение 

func _physics_process(delta: float):
	if is_dead():
		return
	if time_to_next_attack >= 0:
		time_to_next_attack -= delta
	if not get_target() or (get_target() and  get_target().is_dead()):
		reset_target()
	act(delta)

func act(delta: float):
	if get_target() and not is_target_in_attack_range:
		move_to(get_target().global_position, speed)
	if not get_target() or is_target_in_attack_range:
		stop()
	if can_attack_target():
		attack(get_target())

func stop():
	sleeping = true

func move_to(point: Vector2, max_speed: float):
	sleeping = false
	if linear_velocity.length() > max_speed:
		return
	apply_central_impulse(global_position.direction_to(point).normalized())

func calculate_damage(enemy: BasicSlime) -> float:
	var dmg_random_fraction = damage * damage_percent_range
	var final_damage = damage + rng.randf_range(-dmg_random_fraction, dmg_random_fraction)
	return clamp(final_damage - enemy.armor, 0, final_damage)

func take_damage(damage: float):
	Events.emit_signal("damage_taken")
	hp -= damage
	hp_bar.value = (hp / max_hp) * 100
	var dmg_label = damage_label_scene.instance()
	dmg_label.set_value(damage)
	damage_label_origin.add_child(dmg_label)
	if is_dead():
		die()
	_on_after_take_damage()

func attack(enemy: BasicSlime):
	enemy.take_damage(calculate_damage(enemy))
	reset_attack_calldown()

func can_attack_target() -> bool:
	return is_target_in_attack_range and time_to_next_attack <= 0.0

func reset_attack_calldown():
	time_to_next_attack = attack_period

func is_dead() -> bool:
	return hp <= 0
	
func die():
	queue_free()
	
func reset_target():
	for target_candidate in $AttackArea.get_overlapping_bodies():
		if target_candidate == self:
			continue
		if not target_candidate.is_dead():
			set_target(target_candidate)
			print_debug(name + " new target in attack area " + target_candidate.name)
			return
	is_target_in_attack_range = false
	var target_candidates = []
	for target_candidate in $GuardArea.get_overlapping_bodies():
		if target_candidate == self:
			continue
		if not target_candidate.is_dead():
			target_candidates.append([global_position.distance_to(target_candidate.global_position), target_candidate])
	target_candidates.sort_custom(ClosestUnitTuppleSorter, "sort_ascending")
	if target_candidates.size() > 0:
		set_target(target_candidates[0][1])
		return
	set_target(null)

func _on_after_take_damage():
	pass

func _on_GuardArea_body_entered(body: BasicSlime):
	if body == self:
		return
	if body.is_dead():
		return
	if not get_target():
		set_target(body)
		return
	var is_closer_enemy = \
		global_position.distance_to(body.global_position) < \
		global_position.distance_to(get_target().global_position)
	if is_closer_enemy:
		set_target(body)

func _on_GuardArea_body_exited(body: BasicSlime):
	if get_target():
		reset_target()
		stop()

func _on_AttackArea_body_entered(body: BasicSlime):
	if body == get_target():
		is_target_in_attack_range = true


func _on_AttackArea_body_exited(body: BasicSlime):
	if body == get_target():
		is_target_in_attack_range = false

func set_target(target):
	_target = weakref(target)
	
func get_target():
	if _target:
		return _target.get_ref()
	return null


class ClosestUnitTuppleSorter:
	static func sort_ascending(a, b):
		if a[0] < b[0]:
			return true
		return false
