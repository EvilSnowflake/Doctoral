extends Control

var _test_json: Dictionary = {
	"GAME_DATA" : {
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
	
	print_debug(content)
	var json: JSON = JSON.new()
	var error: Error = json.parse(content)
	var data_received: Dictionary = {}
	if error == OK:
		data_received = json.data
		if typeof(data_received) == TYPE_DICTIONARY:
			print_debug("Data found as dictionary : " + str(data_received))
		else:
			print_debug("Unexpected data")
	else:
		print("JSON Parse Error: ", json.get_error_message(), " in ", content, " at line ", json.get_error_line())
	if !data_received.has("GAME_DATA"):
		print_debug("File does not have any game data")
		return
	var gamedata: Dictionary = data_received["GAME_DATA"]
	if !gamedata.has("PLAYER_CREATION_DICTIONARY"):
		print_debug("File does not have any data for player creation")
		return
	var player_creation_dictionary: Dictionary = gamedata["PLAYER_CREATION_DICTIONARY"]
	#print_debug(player_creation_dictionary)
	for combatstat_key in player_creation_dictionary["PLAYER_COMBAT_STATS"].keys():
		player_creation_dictionary["PLAYER_COMBAT_STATS"][combatstat_key] = int(player_creation_dictionary["PLAYER_COMBAT_STATS"][combatstat_key])
	print_debug(player_creation_dictionary.values())
	if !gamedata.has("QUEST_DICTIONARY"):
		print_debug("File does not have any data for quests")
		return
	var quests_dict: Dictionary = gamedata["QUEST_DICTIONARY"]
	print_debug(quests_dict.keys())
	if !gamedata.has("THEME_DICTIONARY"):
		print_debug("File does not have any data for the theme")
		return
	var theme_dictionary: Dictionary = gamedata["THEME_DICTIONARY"]
	print_debug(theme_dictionary.keys())
	if !gamedata.has("STAGES"):
		print_debug("File does not have any data for STAGES")
		return
	var stage_data: Dictionary = gamedata["STAGES"]
	var stage_info_array: Array[Dictionary] = []
	for stg: Dictionary in stage_data.values():
		print_debug("New stage creation")
		if !stg.has("ITEM_CREATION_DICTIONARY"):
			print_debug("File does not have any data for item creation")
			return
		var item_creation_dictionary: Dictionary = stg["ITEM_CREATION_DICTIONARY"]
		print_debug(item_creation_dictionary.keys())
		if !stg.has("NPC_CREATION_DICTIONARY"):
			print_debug("File does not have any data for npc creation")
			return
		var npc_creation_dictionary : Dictionary = stg["NPC_CREATION_DICTIONARY"]
		#print_debug(npc_creation_dictionary)
		for npc in npc_creation_dictionary.values():
			for combatstat_key in npc["NPC_STATS"]:
				npc["NPC_STATS"][combatstat_key] = int(npc["NPC_STATS"][combatstat_key])
		print_debug(npc_creation_dictionary.keys())
		if !stg.has("TILE_DICTIONARY"):
			print_debug("File does not have any data for tile creation")
			return
		var tile_dictionary : Dictionary = stg["TILE_DICTIONARY"]
		print_debug(tile_dictionary.keys())
