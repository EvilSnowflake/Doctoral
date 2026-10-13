extends Control

const STAGE = preload("res://scenes/stage.tscn")
const OPTION_BUTTON = preload("res://scenes/option_button.tscn")

@onready var stage_button_h_box_container = $Panel/HBoxContainer/VBoxContainer/StageButtonHBoxContainer

var _stages_dictionary: Dictionary = {}
var _player_dictionary: Dictionary = {}
var _quest_dictionary: Dictionary = {}
var _theme_dictionary: Dictionary = {}
var _battle_actions_dictionary: Dictionary = {}
var _tilesize: Array[int]
var _items_dictionary: Dictionary = {}
var _test_json: Dictionary = {
	"GAME_DATA" : {
		"TILESIZE" : [64,64],
		"BATTLE_ACTIONS_DICTIONARY": {
			"BUTTON_ARRAY_NAMES" : ["ATTACK","DEFEND","RUN"],
			"BUTTON_NAME_BEHAVIOUR" : {
			"ATTACK" : "DEAL_DAMAGE1",
			"DEFEND" : "STOP_DAMAGE1",
			"RUN" : "DISENGAGE_COMBAT1"
		}
	},
		"PLAYER_CREATION_DICTIONARY" : {
			"PLAYER_SCENE" : "res://scenes/player.tscn",
			"PLAYER_POSITION" : [0.0,0.0],
			"PLAYER_COMBAT_STATS" : { "MAX_HEALTH" : 10, "ATTACK_POWER" : 10, "DEFENSE" : 10, "SPEED" : 10}
		},
		"QUEST_DICTIONARY" : {
			"QUEST_1" : {
				"TITLE" : "Test",
				"DESCRIPTION" : "Test",
				"STEPS" : ["Test"],
				"REWARD_XP" : 1,
				"REWARD_ITEMS" : ["test"],
				"REWARD_ITEM_QUANTITY" : [1]
			}
		},
	"ITEMS_DICTIONARY" : {
		"ITEM_1" : {
			"ID" : "1",
			"NAME" : "Bone",
			"DESCRIPTION" : "This is a Bone",
			"ICON" : "res://assets/sprites/items/14.png",
			"MAX_STACK" : 5,
			"ITEM_TYPE" : "KEY_ITEM"
		}
	},
		"THEME_DICTIONARY" : {
			"Panel" : {	"BASE_TYPE" : { } }
		},
		"STAGES" : {
			"STAGE_1" : {
				"ITEM_CREATION_DICTIONARY" : {
					"ITEM_SPAWN_1": {
						"ITEM_SCENE" : "res://scenes/interactable_item.tscn",
						"ITEM_RESOURCE" : "Test",
						"ITEM_POSITION" : [0.0,0.0],
						"ITEM_QUEST_TO_GIVE": {
							"TITLE" : "test",
							"COMPLETED_STEPS" : "Test",
							"IS_COMPLETE" : false
						}
					}
				},
				"NPC_CREATION_DICTIONARY" : {
					"CHARACTER_SPAWN_1": {
						"NPC_SCENE" : "res://scenes/npc.tscn",
						"NPC_POSITION" : [0.0,0.0],
						"NPC_ITEM_ID" : "Test",
						"NPC_DIALOGUE" : {
							"Dialogue_1": {
								"STARTING_CONVERSATION" : "Test#1",
								"Test#1": "ENDING_CONVERSATION"
								}
						},
						"NPC_NAME" : "Test",
						"NPC_STATS" : { "MAX_HEALTH" : 10, "ATTACK_POWER" : 10, "DEFENSE" : 10, "SPEED" : 10},
						"NPC_COMBATABILITY" : false,
						"NPC_QUEST": {}
					}
				}
			}
		}
	}
}

#FIRST WE NEED TO BE ABLE TO READ A FILE THAT IS IN THE SAME DIRECTORY AS THE EXECUTABLE
func _ready():
	var folder: String = ""
	var file_name: String = "game_file.json"
	var json_file: String = ""
	if OS.has_feature("standalone"):
		folder = OS.get_executable_path().get_base_dir()
		json_file = folder + file_name
	else:
		folder = "res://gamefile/"
		json_file = folder + file_name
	if !FileAccess.file_exists(json_file):
		print_debug("File does not exist")
		#var file = FileAccess.new()
		#var err = file.open(json_file, File.WRITE)
		var file = FileAccess.open(json_file, FileAccess.WRITE)
		file.store_string(JSON.stringify(_test_json))
		return
	var file: FileAccess = FileAccess.open(json_file,FileAccess.READ)
	var content = file.get_as_text()
	
	#print_debug(content)
	var json: JSON = JSON.new()
	var error: Error = json.parse(content)
	var data_received: Dictionary = {}
	if error == OK:
		data_received = json.data
		if typeof(data_received) == TYPE_DICTIONARY:
			print_debug("Data found as dictionary :")
		else:
			print_debug("Unexpected data")
	else:
		print("JSON Parse Error: ", json.get_error_message(), " in ", content, " at line ", json.get_error_line())
	if !data_received.has("GAME_DATA"):
		print_debug("File does not have any game data")
		return
	var gamedata: Dictionary = data_received["GAME_DATA"]
	if !gamedata.has("TILESIZE"):
		print_debug("File does not have tilesize")
		return
	_tilesize = [int(gamedata["TILESIZE"][0]),int(gamedata["TILESIZE"][1])]
	print_debug(_tilesize)
	if !gamedata.has("PLAYER_CREATION_DICTIONARY"):
		print_debug("File does not have any data for player creation")
		return
	var player_creation_dictionary: Dictionary = gamedata["PLAYER_CREATION_DICTIONARY"]
	#print_debug(player_creation_dictionary)
	for combatstat_key in player_creation_dictionary["PLAYER_COMBAT_STATS"].keys():
		player_creation_dictionary["PLAYER_COMBAT_STATS"][combatstat_key] = int(player_creation_dictionary["PLAYER_COMBAT_STATS"][combatstat_key])
	print_debug(player_creation_dictionary.values())
	_player_dictionary = player_creation_dictionary
	if !gamedata.has("QUEST_DICTIONARY"):
		print_debug("File does not have any data for quests")
		return
	var quests_dict: Dictionary = gamedata["QUEST_DICTIONARY"]
	print_debug(quests_dict.keys())
	_quest_dictionary = quests_dict
	if !gamedata.has("ITEMS_DICTIONARY"):
		print_debug("File does not have any data on items")
		return
	_items_dictionary = gamedata["ITEMS_DICTIONARY"]
	for item_key in _items_dictionary:
		_items_dictionary[item_key]["MAX_STACK"] = int(gamedata["ITEMS_DICTIONARY"][item_key]["MAX_STACK"])
	if !gamedata.has("THEME_DICTIONARY"):
		print_debug("File does not have any data for the theme")
		return
	var theme_dictionary: Dictionary = gamedata["THEME_DICTIONARY"]
	print_debug(theme_dictionary.keys())
	_theme_dictionary = theme_dictionary
	if !gamedata.has("BATTLE_ACTIONS_DICTIONARY"):
		print_debug("File does not have any data for action behaviour")
		return
	_battle_actions_dictionary = gamedata["BATTLE_ACTIONS_DICTIONARY"]
	print_debug(_battle_actions_dictionary.keys())
	print_debug(_battle_actions_dictionary["BUTTON_NAME_BEHAVIOUR"])
	print_debug(typeof(_battle_actions_dictionary["BUTTON_ARRAY_NAMES"][0]) == TYPE_STRING)
	if !gamedata.has("STAGES"):
		print_debug("File does not have any data for STAGES")
		return
	var stage_data: Dictionary = gamedata["STAGES"]
	_stages_dictionary = stage_data
	var stage_info_array: Array[Dictionary] = []
	for stg: String in stage_data.keys():
		print_debug("New stage creation")
		stage_info_array.append(stage_data[stg])
		var stg_button: Button = OPTION_BUTTON.instantiate()
		stg_button.text = stg
		stg_button.pressed.connect(_start_stage.bind(stg))
		stage_button_h_box_container.add_child(stg_button)
		if !stage_data[stg].has("ITEM_CREATION_DICTIONARY"):
			print_debug("File does not have any data for item creation")
			return
		var item_creation_dictionary: Dictionary = stage_data[stg]["ITEM_CREATION_DICTIONARY"]
		print_debug(item_creation_dictionary.keys())
		if !stage_data[stg].has("NPC_CREATION_DICTIONARY"):
			print_debug("File does not have any data for npc creation")
			return
		var npc_creation_dictionary : Dictionary = stage_data[stg]["NPC_CREATION_DICTIONARY"]
		#print_debug(npc_creation_dictionary)
		for npc in npc_creation_dictionary.values():
			for combatstat_key in npc["NPC_STATS"]:
				npc["NPC_STATS"][combatstat_key] = int(npc["NPC_STATS"][combatstat_key])
		print_debug(npc_creation_dictionary.keys())
		if !stage_data[stg].has("TILE_DICTIONARY"):
			print_debug("File does not have any data for tile creation")
			return
		var tile_dictionary : Dictionary = stage_data[stg]["TILE_DICTIONARY"]
		print_debug(tile_dictionary.keys())
	file.close()
	#var stage_component = STAGE.instantiate()
	#add_child(stage_component)

func _start_stage(_stage_name: String) -> void:
	for ch in stage_button_h_box_container.get_children():
		ch.release_focus()
	#release_focus()
	var stage_component = STAGE.instantiate()
	print_debug(_stages_dictionary[_stage_name])
	add_child(stage_component)
	
	if !stage_component.has_method("setup_stage_details"):
		print_debug("Stage has no setup function")
		return
	stage_component.setup_stage_details(_player_dictionary, _battle_actions_dictionary, _theme_dictionary, _stages_dictionary[_stage_name], _quest_dictionary, _items_dictionary, _tilesize)
