## QUEST MANAGER - GLOBAL SCRIPT
extends Node

signal quest_updated(q: Quest)

var quests: Array[Quest]
var current_quests : Array

var quests_dict_test: Dictionary = {
	"QUEST_1" : {
		"TITLE" : "Short Quest",
		"DESCRIPTION" : "An example short quest with only one step required to complete it",
		"STEPS" : ["Complete Quest"],
		"REWARD_XP" : 10,
		"REWARD_ITEMS" : [],
		"REWARD_ITEM_QUANTITY" : []
		},
	"QUEST_2" : {
		"TITLE" : "Long Quest",
		"DESCRIPTION" : "A long quest with multiple steps.",
		"STEPS" : ["Step 1","Step 2","Step 3","Step 4","Step 5"],
		"REWARD_XP" : 50,
		"REWARD_ITEMS" : ["1"],
		"REWARD_ITEM_QUANTITY" : [2]
		},
	"QUEST_3" : {
		"TITLE" : "Recover Lost Magical Flute",
		"DESCRIPTION" : "Bill has tasked you with retreiving his lost magical flute from the dark dungeon.",
		"STEPS" : ["Find the Magical Flute","Return Magical Flute to Bill"],
		"REWARD_XP" : 100,
		"REWARD_ITEMS" : ["1"],
		"REWARD_ITEM_QUANTITY" : [3]
		}
	}

func _ready() -> void:
	gather_quests(quests_dict_test)

func gather_quests(_quest_dictionary: Dictionary) -> void:
	for quest_key in _quest_dictionary.keys():
		var new_quest: Quest = Quest.new()
		new_quest.set_details(_quest_dictionary[quest_key])
		quests.append(new_quest)
	#print_debug(quests[2].reward_item_quantity)

func update_quest() -> void:
	pass

func give_rewards() -> void:
	#Give the user the quest rewards
	pass

func find_quest(_quest: Quest) -> Dictionary:
	return {}

func find_quest_by_title(_title: String) -> Quest:
	return null

func get_quest_index_by_title(_title: String) -> int:
	return -1
