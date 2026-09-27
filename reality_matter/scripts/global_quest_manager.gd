## QUEST MANAGER - GLOBAL SCRIPT
extends Node

#This script is a global solution to the quest functionality. By calling this script, another entity
#can add new quests to the total using a dictionary, search for a quest using the quest itself,
#a title, or get its index using that title. It also holds the player's current quests in an array
#while showing on what step they are along with whether or not its complete.

@warning_ignore("unused_signal")
## This signal should be emitted when the player continues a step in a quest
signal quest_updated(q: Quest)

var quests: Array[Quest]
var current_quests : Array = []

func _ready() -> void:
	pass

func gather_quests(_quest_dictionary: Dictionary) -> void:
	quests.clear()
	for quest_key in _quest_dictionary.keys():
		var new_quest: Quest = Quest.new()
		new_quest.set_details(_quest_dictionary[quest_key])
		quests.append(new_quest)
	print_debug("Quests added. Total quests : %s" %[str(quests.size())])

func update_quest() -> void:
	pass

func give_rewards() -> void:
	#Give the user the quest rewards
	pass

func find_quest(_quest: Quest) -> Dictionary:
	for q in current_quests:
		if q.title.to_upper() == _quest.title.to_upper():
			return q
	return { title = "not found", is_complete = false, completed_steps = [""] }

func find_quest_by_title(_title: String) -> Quest:
	for q in quests:
		if q.title.to_upper() == _title.to_upper():
			return q
	return null

func get_quest_index_by_title(_title: String) -> int:
	for q in range(current_quests.size()):
		if current_quests[q].title.to_upper() == _title.to_upper():
			return q
	return -1

func sort_quests() -> void:
	pass
