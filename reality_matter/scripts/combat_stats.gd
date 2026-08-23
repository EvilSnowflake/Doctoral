########NEW SCRIPT
class_name Combat_Stats
#This resource should be used by the combat system to draw in each characters
#combat statistics
extends Resource

@export var health: int = 10
@export var attack_power: int = 1
@export var defense: int = 1
@export var speed: int = 1

var _level: int = 1
var _experience: int = 1
var _default_experience_to_next_level: int = 9
var _exp_to_level: int = 9

func set_statistics(hlth: int, ap: int, dfnc: int, spd: int) -> void:
	health = hlth
	attack_power = ap
	defense = dfnc
	speed = spd
#######NEWSCRIPT
