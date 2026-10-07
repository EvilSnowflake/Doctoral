## QUEST MANAGER - GLOBAL SCRIPT
extends Node

#This script is a global solution to the quest functionality. By calling this script, another entity
#can add new quests to the total using a dictionary, search for a quest using the quest itself,
#a title, or get its index using that title. It also holds the player's current quests in an array
#while showing on what step they are along with whether or not its complete.

@warning_ignore("unused_signal")
## This signal should be emitted when the player continues a step in a quest
signal quest_updated(dict: Dictionary)

var quests: Array[Quest]
var current_quests : Array[Dictionary] = [{
	"TITLE" = "Recover Lost Magical Flute", "IS_COMPLETE" = false, "COMPLETED_STEPS" = ["Find the Magical Flute"]
},
{
	"TITLE" = "Long Quest", "IS_COMPLETE" = false, "COMPLETED_STEPS" = [""]
}]

var _player_combat_stats: Combat_Stats
var _player_inventory: Inventory

func _ready() -> void:
	pass

func gather_quests(_quest_dictionary: Dictionary) -> void:
	quests.clear()
	for quest_key in _quest_dictionary.keys():
		var new_quest: Quest = Quest.new()
		new_quest.set_details(_quest_dictionary[quest_key])
		quests.append(new_quest)
	print_debug("Quests added. Total quests : %s" %[str(quests.size())])

func update_quest(_title : String, _completed_step: String = "", _is_complete: bool = false) -> void:
	var quest_index: int = get_quest_index_by_title(_title)
	print_debug("Quest %s updated to %s, with the step: %s" %[_title, str(_is_complete), _completed_step])
	if quest_index == -1:
		var new_quest: Dictionary = {"TITLE" = _title, "IS_COMPLETE" = _is_complete, "COMPLETED_STEPS" = []}
		if _completed_step != "":
			new_quest["COMPLETED_STEPS"].append(_completed_step)
		current_quests.append(new_quest)
		quest_updated.emit(new_quest)
	else:
		var q: Dictionary = current_quests[quest_index]
		if _completed_step != "" and !q["COMPLETED_STEPS"].has(_completed_step):
			q["COMPLETED_STEPS"].append(_completed_step)
		if q["IS_COMPLETE"] != _is_complete:
			q["IS_COMPLETE"] = _is_complete
			if q["IS_COMPLETE"]:
				give_rewards(find_quest_by_title(q["TITLE"]))
		quest_updated.emit(q)
		

func give_rewards(_q: Quest) -> void:
	_player_combat_stats.add_experience(_q.reward_xp)
	for i in range(_q.reward_items.size()):
		_player_inventory.add_item(_q.reward_items[i],_q.reward_item_quantity[i])

func find_quest(_quest: Quest) -> Dictionary:
	for q in current_quests:
		if q["TITLE"].to_upper() == _quest.title.to_upper():
			return q
	return { "TITLE" = "not found", "IS_COMPLETE" = false, "COMPLETED_STEPS" = [""] }

func find_quest_by_title(_title: String) -> Quest:
	for q in quests:
		if q.title.to_upper() == _title.to_upper():
			return q
	return null

func get_quest_index_by_title(_title: String) -> int:
	for q in range(current_quests.size()):
		if current_quests[q]["TITLE"].to_upper() == _title.to_upper():
			return q
	return -1

func sort_quests() -> void:
	pass

func receive_player_requirements(_comb: Combat_Stats, _inv: Inventory):
	if _comb != null and _inv != null:
		_player_combat_stats = _comb
		_player_inventory = _inv

func get_current_quests() -> Array[Dictionary]:
	return current_quests
