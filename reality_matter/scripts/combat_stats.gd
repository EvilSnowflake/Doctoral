class_name Combat_Stats
#This resource should be used by the combat system to draw in each characters
#combat statistics
extends Resource

## This signal is used to inform the character that holds the combat stats that
## they have just died. Used by the user to end the game and the npcs to delete
## themselves
signal living_died()
## This signal is emitted the moment the user attempta to disengage combat. It's
## used by the player character to return the user to the main menu and by the
## npc to give control back to the user 
signal char_run()

## Max health signifies how much health the character can reach by recovering it
@export var max_health: int = 10
## This variable shows how much health the character currently posseses
@export var health: int = 10
## This variable is used during combat to calculate how much damage they can
## deal with an attack
@export var attack_power: int = 1
## Defense is currently not used
@export var defense: int = 1
## Speed is currently not used
@export var speed: int = 1

#THIS SET OF VARIABLES IS CURRENTLY NOT IN USE BUT SHOULD BE UTILISED FOR THE
#EXPERIENCE SYSTEM WE WILL MAKE LATER
var _level: int = 1
var _experience: int = 1
var _default_experience_to_next_level: int = 9
var _exp_to_level: int = 9
#
## This variable signifies if the character is currently alive
var _alive: bool = true

#This function is used to set the default numbers for some variables
func _ready():
	_exp_to_level = _default_experience_to_next_level

## With set_statistics() each character can modify their own combat ability
func set_statistics(hlth: int, ap: int, dfnc: int, spd: int) -> void:
	max_health = hlth
	health = max_health
	attack_power = ap
	defense = dfnc
	speed = spd

## This function is currently not used but it can add experience to the user
## after combat
func add_experience(amount: int) -> void:
	_experience += amount
	while _experience >= _exp_to_level:
		_experience -= _exp_to_level
		_levelup()

## Using deal_damage() the combat scene can substract a specific amount of
## health from any character and if that character dies the appropriate signal
## is emitted
func deal_damage(amount: int) -> int:
	health = max(0, health-amount)
	if health == 0:
		_alive = false
		living_died.emit()
	return health

## This function is currently not in use but if any entity adds axperience to
## the user this is called automaticly in order for the user to increase its
## level
func _levelup():
	_level += 1
	health += 5
	attack_power += 1
	defense += 1
	speed += 1
	_exp_to_level += 1
