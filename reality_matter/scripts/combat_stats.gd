class_name Combat_Stats
#This resource should be used by the combat system to draw in each characters
#combat statistics
extends Resource

@export var max_health: int = 10
@export var health: int = 10
@export var attack_power: int = 1
@export var defense: int = 1
@export var speed: int = 1

var _level: int = 1
var _experience: int = 1
var _default_experience_to_next_level: int = 9
var _exp_to_level: int = 9

func _ready():
	_exp_to_level = _default_experience_to_next_level

func set_statistics(hlth: int, ap: int, dfnc: int, spd: int) -> void:
	max_health = hlth
	health = max_health
	attack_power = ap
	defense = dfnc
	speed = spd

func add_experience(amount: int) -> void:
	_experience += amount
	while _experience >= _exp_to_level:
		_experience -= _exp_to_level
		_levelup()

func deal_damage(amount: int) -> int:
	health -= amount
	return health

func _levelup():
	_level += 1
	health += 5
	attack_power += 1
	defense += 1
	speed += 1
	_exp_to_level += 1
