## QUEST MANAGER - GLOBAL SCRIPT
extends Node

#This script is a global solution to the quest functionality. By calling this script, another entity
#can add new quests to the total using a dictionary, search for a quest using the quest itself,
#a title, or get its index using that title. It also holds the player's current quests in an array
#while showing on what step they are along with whether or not its complete.

@warning_ignore("unused_signal")
## This signal should be emitted when the player continues a step in a quest
signal quest_updated(array_dict: Array[Dictionary])

## This variable contains all the quests throught the whole game that the player can engage in
var quests: Array[Quest]
## The current quests varible has all the quests the user is currently engaged in but not as quest
## Resources. It has them as dictionaries containing the title of the quest, if it is complete and
## which steps are completed.
var current_quests : Array[Dictionary] = [{
	"TITLE" = "Recover Lost Magical Flute", "IS_COMPLETE" = false, "COMPLETED_STEPS" = ["Find the Magical Flute"]
},
{
	"TITLE" = "Long Quest", "IS_COMPLETE" = false, "COMPLETED_STEPS" = [""]
}]
## This variable points to the player's combat statistics resource. This gives the quest manager the
## ability to give the user experience when they complete a quest
var _player_combat_stats: Combat_Stats
## This variable points to the player's inventory resource. This gives the manager the ability to
## add an item to their inventory after a quest's completion
var _player_inventory: Inventory

func _ready() -> void:
	pass

## This function is used at the beginning of the game in order to create all the quests the
## game creator has written on the json file. For each quest in the file, a new resource is created
## and is then appended with the details provided to the quests array
func gather_quests(_quest_dictionary: Dictionary) -> void:
	quests.clear()
	for quest_key in _quest_dictionary.keys():
		var new_quest: Quest = Quest.new()
		new_quest.set_details(_quest_dictionary[quest_key])
		quests.append(new_quest)
	print_debug("Quests added. Total quests : %s" %[str(quests.size())])

## This function should be called when the player interacts with any entity containing a quest step.
## That entity is calling the function with the title name, which step is completed and if the quest
## is completed as a whole. With those details, the function attempts to add the quest and the steps
## to the current quests and then emits a signal with an array containing the dictionary with
## the added info. The signal can be used by other parts of the code to do any actions needed.
func update_quest(_title : String, _completed_step: String = "", _is_complete: bool = false) -> void:
	var quest_index: int = get_quest_index_by_title(_title)
	var quest_up: Array[Dictionary] = []
	print_debug("Quest %s updated to %s, with the step: %s" %[_title, str(_is_complete), _completed_step])
	if quest_index == -1:
		var new_quest: Dictionary = {"TITLE" = _title, "IS_COMPLETE" = _is_complete, "COMPLETED_STEPS" = []}
		if _completed_step != "":
			new_quest["COMPLETED_STEPS"].append(_completed_step)
		current_quests.append(new_quest)
		quest_up.append(new_quest)
		#quest_updated.emit([new_quest])
	else:
		var q: Dictionary = current_quests[quest_index]
		if _completed_step != "" and !q["COMPLETED_STEPS"].has(_completed_step):
			q["COMPLETED_STEPS"].append(_completed_step)
		if q["IS_COMPLETE"] != _is_complete:
			q["IS_COMPLETE"] = _is_complete
			if q["IS_COMPLETE"]:
				give_rewards(find_quest_by_title(q["TITLE"]))
		quest_up.append(q)
		#quest_updated.emit([q])
	quest_updated.emit(quest_up)

## This function should be used when the player completes a quest. It reads how much xp it needs
## to give from the quest resource and which items along with their quantity in order to add the
## experience to the user's combat statistics and also give the items to the player's inventory
func give_rewards(_q: Quest) -> void:
	_player_combat_stats.add_experience(_q.reward_xp)
	for i in range(_q.reward_items.size()):
		_player_inventory.add_item(_q.reward_items[i],_q.reward_item_quantity[i])

## This function should be used when we want to check if the player is currently in a specific quest
## It requires a quest resource as input and it checks if that quest's title is in the user's
## current quest while also returning the info in a dictionary
func find_quest(_quest: Quest) -> Dictionary:
	for q in current_quests:
		if q["TITLE"].to_upper() == _quest.title.to_upper():
			return q
	return { "TITLE" = "not found", "IS_COMPLETE" = false, "COMPLETED_STEPS" = [""] }

## This function is used in order to identify a quest by it's title. Using the title we search the
## quests variable and then we return the quest in its entierty if it exists
func find_quest_by_title(_title: String) -> Quest:
	for q in quests:
		if q.title.to_upper() == _title.to_upper():
			return q
	return null

## This function can be used in order to find the index of a quest in the user's current quests
## array.
func get_quest_index_by_title(_title: String) -> int:
	for q in range(current_quests.size()):
		if current_quests[q]["TITLE"].to_upper() == _title.to_upper():
			return q
	return -1

func sort_quests() -> void:
	pass

## This function should be used in order to obtain the user's combat stats and inventory so that
## we can give the user experience and items
func receive_player_requirements(_comb: Combat_Stats, _inv: Inventory):
	if _comb != null and _inv != null:
		_player_combat_stats = _comb
		_player_inventory = _inv

## This function can be used so that another script gets the user's current quests
func get_current_quests() -> Array[Dictionary]:
	return current_quests
