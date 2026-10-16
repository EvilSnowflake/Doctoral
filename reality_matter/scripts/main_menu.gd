extends Control

const STAGE = preload("res://scenes/stage.tscn")
const OPTION_BUTTON = preload("res://scenes/option_button.tscn")

@onready var stage_button_h_box_container = $Panel/HBoxContainer/VBoxContainer/StageButtonHBoxContainer

## This variable points to the theme file that is used by some of the Interface
## elements. Will be modified depending on the contents of the theme dictionary
var _theme: Theme = preload("res://assets/themes/game_theme.tres")
var _stages_dictionary: Dictionary = {}
var _player_dictionary: Dictionary = {}
var _quest_dictionary: Dictionary = {}
var _theme_dictionary: Dictionary = {}
var _battle_actions_dictionary: Dictionary = {}
var _tilesize: Array[int]
var _items_dictionary: Dictionary = {}
var _should_show_quests: bool = true
var _elementsnothere: Array[Dictionary] = []
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
		var wfile = FileAccess.open(json_file, FileAccess.WRITE)
		wfile.store_string(JSON.stringify(_test_json))
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
	if !gamedata.has("ITEMS_DICTIONARY"):
		print_debug("File does not have any data on items")
		return
	_items_dictionary = gamedata["ITEMS_DICTIONARY"]
	for item_key in _items_dictionary:
		_items_dictionary[item_key]["MAX_STACK"] = int(gamedata["ITEMS_DICTIONARY"][item_key]["MAX_STACK"])
	ItemManager.set_items(_items_dictionary)
	if !gamedata.has("QUEST_DICTIONARY"):
		print_debug("File does not have any data for quests")
		return
	var quests_dict: Dictionary = gamedata["QUEST_DICTIONARY"]
	print_debug(quests_dict.keys())
	_quest_dictionary = quests_dict
	QuestManager.gather_quests(_quest_dictionary)
	if !gamedata.has("THEME_DICTIONARY"):
		print_debug("File does not have any data for the theme")
		return
	var theme_dictionary: Dictionary = gamedata["THEME_DICTIONARY"]
	print_debug(theme_dictionary)
	_theme_dictionary = theme_dictionary
	#Then we read the theme dictionary in order to set up the modifications specified inside
	for key in theme_dictionary.keys():
		_set_up_theme(theme_dictionary[key], _theme, key)
	if !gamedata.has("BATTLE_ACTIONS_DICTIONARY"):
		print_debug("File does not have any data for action behaviour")
		return
	_battle_actions_dictionary = gamedata["BATTLE_ACTIONS_DICTIONARY"]
	print_debug(_battle_actions_dictionary.keys())
	
	if !gamedata.has("SHOULD_SHOW_QUESTS"):
		print_debug("Does not have if we should show quests")
	else:
		_should_show_quests = gamedata["SHOULD_SHOW_QUESTS"]
		print_debug(gamedata["SHOULD_SHOW_QUESTS"])
	
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

func _process(_delta):
	#print_debug("Works")
	if Input.is_action_just_pressed("test"):
		print_debug(stage_button_h_box_container.get_child(0).is_connected("pressed",_start_stage))
		stage_button_h_box_container.get_child(0).pressed.emit()

func _start_stage(_stage_name: String) -> void:
	#for ch: Button in stage_button_h_box_container.get_children():
	#	ch.release_focus()
	#release_focus()
	var stage_component = STAGE.instantiate()
	print_debug(_stages_dictionary[_stage_name].keys())
	add_child(stage_component)
	
	if !stage_component.has_method("setup_stage_details"):
		print_debug("Stage has no setup function")
		return
	stage_component.setup_stage_details(_player_dictionary, _battle_actions_dictionary, _stages_dictionary[_stage_name], _tilesize, _elementsnothere, _should_show_quests)

## This function is responsible for changing the central theme for the game. The theme itself does
## not have any overrides to the User Interface elements but if we provide this function with a
## dictionary containing any changes to the theme we want along with the theme and what type of
## element we want to modify, the function then reads the type of change we want to occur and
## does the appropriate action. The typical structure of the dictionary we need to provide is the
## name of the variant we want to create and which elements should get that variant or if we want to
## change the base one we just write BASE TYPE and inside we write what we want to change inside
## like the color, font size etc.
func _set_up_theme(theme_dictionary: Dictionary, theme_source: Theme, current_theme_type: String) -> void:
	for theme_type_key in theme_dictionary.keys():
		var shared_theme_dictionary: Dictionary = theme_dictionary[theme_type_key]
		var shared_theme_type: String = ""
		if theme_type_key != "BASE_TYPE":
			theme_source.add_type(theme_type_key)
			theme_source.set_type_variation(theme_type_key, current_theme_type)
			shared_theme_type = theme_type_key
		else:
			shared_theme_type = current_theme_type
		for theme_name_key in shared_theme_dictionary.keys():
			var theme_name_dictionary = shared_theme_dictionary[theme_name_key]
			if theme_name_dictionary.has("THEME_COLOR"):
				var theme_color: Color = Color(theme_name_dictionary["THEME_COLOR"])
				theme_source.set_color(theme_name_key, shared_theme_type, theme_color)
			elif theme_name_dictionary.has("THEME_STYLEBOX_TYPE"):
				var thm_stylebox_type: String = theme_name_dictionary["THEME_STYLEBOX_TYPE"]
				if thm_stylebox_type == "StyleBoxTexture":
					_setup_stylebox_texture(theme_name_dictionary, theme_source, theme_name_key, shared_theme_type)
				if thm_stylebox_type == "StyleBoxFlat":
					_setup_stylebox_flat(theme_name_dictionary, theme_source, theme_name_key, shared_theme_type)
			elif theme_name_dictionary.has("THEME_SIZE"):
				var theme_size: int = theme_name_dictionary["THEME_SIZE"]
				theme_source.set_constant(theme_name_key,shared_theme_type,theme_size)
			if shared_theme_dictionary.has("UI_ELEMENTS"):
				for var_name in shared_theme_dictionary["UI_ELEMENTS"]:
					var element = find_child(var_name,true,false)
					if element != null:
						element.theme_type_variation = theme_type_key
					else:
						var notin: Dictionary = {"ELEMENT" : var_name, "TYPE" : theme_type_key}
						#print_debug(notin)
						_elementsnothere.append(notin)

## This function is used by the set up theme function and is specifically responsible for modifying
## the stylebox texture of a theme element. It requires the theme dictionary, the theme to change,
## the theme name and what type of element it is we change. The dictionary needs a path to the
## texture we want to apply along with its texture margins. The margin value requires an array with
## 4 elements like: [LEFT,TOP,RIGHT,BOTTOM]
func _setup_stylebox_texture(theme_dictionary: Dictionary, theme_source: Theme, theme_name: String, theme_type: String):
	var thm_texture_path: String = theme_dictionary["THEME_TEXTURE_PATH"]
	var thm_texture_margin: Array = theme_dictionary["THEME_TEXTURE_MARGIN"]
	var stylebox_theme: StyleBoxTexture = StyleBoxTexture.new()
	stylebox_theme.texture = load(thm_texture_path)
	stylebox_theme.set_texture_margin(SIDE_LEFT, thm_texture_margin[0])
	stylebox_theme.set_texture_margin(SIDE_TOP, thm_texture_margin[1])
	stylebox_theme.set_texture_margin(SIDE_RIGHT, thm_texture_margin[2])
	stylebox_theme.set_texture_margin(SIDE_BOTTOM, thm_texture_margin[3])
	#print_debug(" Theme %s of type %s changed stylebox" % [theme_name, theme_type])
	theme_source.set_stylebox(theme_name, theme_type, stylebox_theme)

## This function is used by the set up theme function and is specifically responsible for modifying
## the flat stylebox of a theme element. It requires the theme dictionary, the theme to change,
## the theme name and what type of element it is we change. The dictionary requires a background
## alpha value, a background color value, a border width value and a border color value. The alpha
## is just a float, while the colors only require the name of the color as written in the Godot
## Engine Documentation. The width on the other hand needs an array of 4 elements like: [LEFT,TOP,
##RIGHT,BOTTOM]
func _setup_stylebox_flat(theme_dictionary: Dictionary, theme_source: Theme, theme_name: String, theme_type: String):
	var thm_bg_alpha: float = theme_dictionary["THEME_BG_ALPHA"]
	var thm_bg_color: Color = Color(theme_dictionary["THEME_BG_COLOR"],thm_bg_alpha)
	var thm_border_width: Array = theme_dictionary["THEME_BORDER_WIDTH"]
	var thm_border_color: Color = Color(theme_dictionary["THEME_BORDER_COLOR"])
	var stylebox_theme: StyleBoxFlat = StyleBoxFlat.new()
	stylebox_theme.bg_color = thm_bg_color
	stylebox_theme.border_width_left = thm_border_width[0]
	stylebox_theme.border_width_top = thm_border_width[1]
	stylebox_theme.border_width_right = thm_border_width[2]
	stylebox_theme.border_width_bottom = thm_border_width[3]
	stylebox_theme.border_color = thm_border_color
	#print_debug(" Theme %s of type %s changed stylebox" % [theme_name, theme_type])
	theme_source.set_stylebox(theme_name, theme_type,stylebox_theme)
