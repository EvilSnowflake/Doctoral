extends Node2D

#This script gives function to the current stage of the game. The stage contains
#the environment the user interacts with, the non player characters and the
#items they can pick up. Curreently the stage spawns the user chartacter and
#the tileset thje user can wander in, along with the npcs and the items while
#also giving them their properties through code alone but this functionality
#will be passed to the game manager eventualy and the game manager will take
#those properties from a json file

## This variable should contain a reference to the user interface scene to
## instantiate
const USER_INTERFACE_NODE = preload("res://scenes/user_interface_node.tscn")
## The scene all battles happen on
const BATTLE = preload("res://scenes/battle.tscn")

## This signal should be called when we want to enable or disable the player's
## camera
signal player_camera_changeability(ability: bool)
signal stage_discontinue()

## This variable contains the dictionary to place items on the environemnt for the player to collect
## For each key inside an item will be created and placed and it requires the path to the item scene
## along with what item id it will have, its position on the world and what quest step it will
## complete if any.
var item_creation_dictionary: Dictionary = {}
## This variable contains the dictionary to spawn a player character on the game scene. Inside it
## requires a path to the player scene, a position in a 2 element array and a combat stats
## dictionary. That dictionary requires a MAX_HEALTH int element, an ATTACK_POWER int element,
## a DEFENSE int element and a SPEED int element
var player_creation_dictionary: Dictionary = {}
## This variable contains the dictionary to spawn non player characters on the environment. For each
## key inside this dictionary, a new character will be spawned with the specifications inside. Each
## character requires a path to the NPC_SCENE, a 2 element float array with the NPC_POSITION,
## an NPC_ITEM_ID string in order for the character to give the player an item during their fall or
## conversation, a dictionary containing their NPC_DIALOGUE, their NPC_NAME in a string,
## their NPC_STATS for combat in a dictionary, their NPC_COMBATABILITY in oder for them to be able
## to fight or not in a bool and a dictionary for what NPC_QUEST they progress.
var npc_creation_dictionary: Dictionary = {}


## This variable dictates how many inventory slots the user interface is going
## to contain
var inventory_spaces: int = 5

#var tweenNames: Array[String] = ["IdleTween", "RunTween"]
#var tweenComps: Array[String] = ["Sprite2D", "Sprite2D"]
#var tweenProps: Array[String] = ["frame", "frame"]
#var tweenChanges: Array[Vector2i] = [Vector2i(0,5), Vector2i(6,11)]
#var tweenDurations: Array[float] = [0.4, 0.4]
#var tweensItems: Dictionary = {
#	"NAMES": { "NAME_1" : "ENEMY_DAMAGED", "NAME_2" : "ENEMY_DIED", "NAME_3" : "SHAKE", "NAME_4" : "MINI_SHAKE"},
#	"COMPONENTS": { "COMPONENT_1" : "Enemy_Sprite", "COMPONENT_2" : "Enemy_Sprite", "COMPONENT_3" : "Background", "COMPONENT_4" : "Background"},
#	"PROPERTIES" : { "PROPERTY_1" : "modulate", "PROPERTY_2" : "modulate", "PROPERTY_3" : "position", "PROPERTY_4" : "position"}
#}

## This variable should contain the current instance of the user inventory
var inventory_instance: Inventory

## This variable should contain the user interface instance
var _user_interface: Control
## This variable should contain the battle scene where the user and a npc can engage in combat
var _batt: Control
## This variable contains a reference to the player character inside the scene
var _player: CharacterBody2D
## This variable has a dictionary with all quests that will exist on the game. Each keyword inside 
## will create a different quest and is going to require the following details to manifest. Firstly
## it needs a TITLE string, that will be the primary way to differentiate it from other quests,
## a DESCRIPTION string which will give the user hints of what they need to do to complete the
## quest, a STEPS array of strings that will be given on the npcs and items that will further the
## quest for the user, a REWARD_XP int and a REWARD_ITEMS Item array that will be given to the user
## after completion and a REWARD_ITEM_QUANTITY int array that will inform the quest of how many of
## each item will be distributed.
var quests_dict: Dictionary = {}
## This variable will inform the whole game of the size each tile will take in the grid of the game
var _tilesize: Vector2i
var _astar_grid: AStarGrid2D

# Called when the node enters the scene tree for the first time.
func _ready():
	#_setup_stage_details()
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass
	if Input.is_action_just_pressed("test"):
		pass
		#%GridDisplay.toggle_grid_display()
	#	print_debug(find_child("PlayerPanel",true,false))

## This function is used to spawn the player on the current scene. It requires a
## player scene to instantiate and a position. After setting the player's
## position we then add a reference to the user's inventory on that character
## All those information should be inside a dictionary
func _spawn_player(_player_create_dict: Dictionary, _battle_actions_dict: Dictionary) -> void:
	var player_component_scene = load(_player_create_dict["PLAYER_SCENE"])
	_player = player_component_scene.instantiate()
	add_child(_player)
	var _player_sprite_path = _player_create_dict["PLAYER_SPRITE_PATH"]
	var _player_tween_dictionary = _player_create_dict["PLAYER_TWEENS"]
	if !_player.has_method("setup_player_entity"):
		print_debug("Cannot initiate player entity")
		return
	_player.setup_player_entity(_player_sprite_path,_player_tween_dictionary)
	#pl.add_child(_user_interface)
	var player_pos_x: float = _player_create_dict["PLAYER_POSITION"][0]
	var player_pos_y: float = _player_create_dict["PLAYER_POSITION"][1]
	_player.position = Vector2(player_pos_x,player_pos_y)
	var player_combat_variable: Combat_Stats = Combat_Stats.new()
	var temp_max_hp = _player_create_dict["PLAYER_COMBAT_STATS"]["MAX_HEALTH"]
	var temp_ap = _player_create_dict["PLAYER_COMBAT_STATS"]["ATTACK_POWER"]
	var temp_defense = _player_create_dict["PLAYER_COMBAT_STATS"]["DEFENSE"]
	var temp_speed = _player_create_dict["PLAYER_COMBAT_STATS"]["SPEED"]
	player_combat_variable.set_statistics(temp_max_hp,temp_ap,temp_defense,temp_speed)
	if _user_interface == null:
		return
	if _user_interface.has_method("connect_player_adding_item"):
		_user_interface.connect_player_adding_item(_player)
	if _player.has_method("receive_inventory") and inventory_instance != null:
		_player.receive_inventory(inventory_instance)
	if _player.has_method("receive_combat_stats"):
		_player.receive_combat_stats(player_combat_variable)
	if _player.has_method("get_combat_stats") and _player.has_method("get_character_name"):
		create_combat_environment(_player.get_character_name(), _player.get_combat_stats(), _battle_actions_dict)
	if _player.has_method("change_camera_ability"):
		player_camera_changeability.connect(_player.change_camera_ability)
	if _player.has_signal("player_died"):
		_player.player_died.connect(_end_stage)
	if _player.has_method("stop_animations"):
		stage_discontinue.connect(_player.stop_animations)

## This function is used to instantiate the required items to the current scene
## It requires the interactive item's scene, the position the item is going
## to have and what item is going to be. All those information should be inside a dictionary
func _spawn_item(_item_details: Dictionary) -> void:
	var item_scene = load(_item_details["ITEM_SCENE"])
	var it = item_scene.instantiate()
	add_child(it)
	var vect_two_pos_x: float = _item_details["ITEM_POSITION"][0]
	var vect_two_pos_y: float = _item_details["ITEM_POSITION"][1]
	it.position = Vector2(vect_two_pos_x,vect_two_pos_y)
	#print_debug(item_resource.description)
	if it.has_signal("assign_item_contained"):
		var item_contained: Item = ItemManager.find_item_by_id(_item_details["ITEM_RESOURCE"])
		it.emit_signal("assign_item_contained",item_contained)
	if it.has_method("set_quest_to_give"):
		it.set_quest_to_give(_item_details["ITEM_QUEST_TO_GIVE"])
	if _player == null:
		return
	if it.has_signal("give_item_to_player") and _player.has_method("add_item_to_inventory"):
		it.give_item_to_player.connect(_player.add_item_to_inventory)

## This function is used to spawn the characters that populate the scene other
## than the player character. We require the character's scene, their position
## on the environemnt, their dialogue and what item (if any) they can give the
## player character. All those information should be inside a dictionary
func _spawn_non_players(_npc_dictionary: Dictionary) -> void:
	var npc_scene_component: PackedScene = load(_npc_dictionary["NPC_SCENE"])
	var new_npc = npc_scene_component.instantiate()
	add_child(new_npc)
	if !new_npc.has_method("setup_npc_entity"):
		print_debug("NPC cannot be initiated")
		return
	new_npc.setup_npc_entity(_npc_dictionary["NPC_SPRITE_PATH"], _npc_dictionary["NPC_TWEENS"])
	
	var new_npc_position_x: float = _npc_dictionary["NPC_POSITION"][0]
	var new_npc_position_y: float = _npc_dictionary["NPC_POSITION"][1]
	new_npc.position = Vector2(new_npc_position_x,new_npc_position_y)
	if _npc_dictionary["NPC_ITEM_ID"] != "" and new_npc.has_signal("assign_item_to_give"):
		var item_to_give: Item = ItemManager.find_item_by_id(_npc_dictionary["NPC_ITEM_ID"])
		new_npc.emit_signal("assign_item_to_give", item_to_give)
	if new_npc.has_method("add_dialogue"):
		var new_npc_dialogue: Dictionary = _npc_dictionary["NPC_DIALOGUE"]
		new_npc.add_dialogue(new_npc_dialogue)
	if new_npc.has_method("set_char_name"):
		var new_npc_name: String = _npc_dictionary["NPC_NAME"]
		new_npc.set_char_name(new_npc_name)
	if new_npc.has_method("set_quest_checks") and _npc_dictionary["QUEST_CHECK"] != {}:
		var checks: Dictionary = _npc_dictionary["QUEST_CHECK"]
		new_npc.set_quest_checks(checks)
	if new_npc.has_method("set_npc_combat"):
		var npc_combat_variable: Combat_Stats = Combat_Stats.new()
		var temp_max_hp = _npc_dictionary["NPC_STATS"]["MAX_HEALTH"]
		var temp_ap = _npc_dictionary["NPC_STATS"]["ATTACK_POWER"]
		var temp_defense = _npc_dictionary["NPC_STATS"]["DEFENSE"]
		var temp_speed = _npc_dictionary["NPC_STATS"]["SPEED"]
		npc_combat_variable.set_statistics(temp_max_hp,temp_ap,temp_defense,temp_speed)
		var new_npc_stats: Combat_Stats = npc_combat_variable
		var new_npc_combability: bool = _npc_dictionary["NPC_COMBATABILITY"]
		new_npc.set_npc_combat(new_npc_stats, new_npc_combability)
	if new_npc.has_method("set_quest_to_give") and _npc_dictionary["NPC_QUEST"] != {}:
		new_npc.set_quest_to_give(_npc_dictionary["NPC_QUEST"])
	if new_npc.has_signal("engage_battle"):
		new_npc.engage_battle.connect(_start_combat_env)
	if new_npc.has_signal("adjust_player_movement") and _player.has_method("change_moveability"):
		new_npc.adjust_player_movement.connect(_player.change_moveability)
	if new_npc.has_signal("give_item_to_player") and _player.has_method("add_item_to_inventory"):
		new_npc.give_item_to_player.connect(_player.add_item_to_inventory)
	if new_npc.has_method("stop_npc_animations"):
		stage_discontinue.connect(new_npc.stop_npc_animations)
	if _user_interface == null:
		return
	if _user_interface.has_method("connect_characters_dialogues"):
		_user_interface.connect_characters_dialogues(new_npc)
	#GRID#
	new_npc.setup(_astar_grid)
	#GRID#

## This function is used to instantiate the user interface on the scene. It only
## requires the interface's scene.
func _spawn_user_interface(ui: PackedScene, _should_show_quests: bool) -> void:
	var new_ui = ui.instantiate()
	add_child(new_ui)
	_user_interface = new_ui
	if new_ui.has_method("receive_inventory") and inventory_instance != null:
		new_ui.receive_inventory(inventory_instance)
	if new_ui.has_signal("close_stage_instance"):
		new_ui.close_stage_instance.connect(_end_stage)
	if new_ui.has_method("disable_quests_in_pause") and !_should_show_quests:
		new_ui.disable_quests_in_pause()

## This function creates the battle scene where combat encounters happen. It requires the
## user's name and their combat stats resource as input. It instantiates the scene on the
## canvas layer in order for it to follow the screen of the user.
func create_combat_environment(nm: String, sts: Combat_Stats, _actions_behaviour: Dictionary) -> void:
	#return
	_batt = BATTLE.instantiate()
	var canvas_l: CanvasLayer = get_node(str(_user_interface.get_path())+"/CanvasLayer")
	canvas_l.add_child(_batt)
	_user_interface.add_pause()
	if !_batt.has_method("setup_actions"):
		print_debug("Battle does not have the ability to setup actions")
		return
	_batt.setup_actions(_actions_behaviour["BUTTON_NAME_BEHAVIOUR"])
	if !_batt.has_method("set_up_player"):
		print_debug("Battle does not have the ability for the player to be setup!")
		return
	if !_batt.has_signal("engagement_ended"):
		print_debug("Battle does not have the ability to end!")
		return
	_batt.engagement_ended.connect(_end_combat_env)
	_batt.set_up_player(nm,sts)
	_batt.hide()

## This function initiates the battle between the user and the npc beginning the encounter. It
## requires the sprite of the character, their name, their CombatStats resource and their tween
## animations in a dictionary. It's job is to pass the information to the battle scene and show it
## to the user.
func _start_combat_env(spr: Sprite2D, nm: String, sts: Combat_Stats, _tweens: Dictionary = {}) -> void:
	print_debug("The combat begins for %s and %s" % ["player", nm])
	if _batt == null:
		print_debug("Battle does not exist")
		return
	if !_batt.has_method("setup_combat_second"):
		print_debug("Battle can't be set up")
		return
	_batt.show()
	_batt.setup_combat_second(spr,nm,sts,_tweens)
	player_camera_changeability.emit(false)

## This function is responsible for ending battles. It hides the scene where the battle takes place
## and enable the player's camera so that we follow the user again.
func _end_combat_env() -> void:
	#print_debug("The combat ends!")
	_batt.hide()
	player_camera_changeability.emit(true)

func setup_stage_details(_player_dictionary_info: Dictionary, _battle_actions_info: Dictionary, _current_stage_dictionary: Dictionary, _tile_size_info: Array[int], _elements_not_there: Array[Dictionary], _should_show_quests: bool) -> void:
	#During startup we need to create an instance of the user's inventory
	inventory_instance = Inventory.new()
	#Then we try to modify the inventory's max item slots
	if inventory_instance.has_method("change_max_slots") and inventory_spaces != null:
		inventory_instance.change_max_slots(int(_player_dictionary_info["PLAYER_INVENTORY_SPACES"]))
	#Afterwards we try to spawn the user interface
	_spawn_user_interface(USER_INTERFACE_NODE,_should_show_quests)
	#And then spawn the player's character
	_spawn_player(_player_dictionary_info, _battle_actions_info)
	#After we check the items array and spawn each of them in the position set
	#by the item position list and then assign an item to it
	for item_list_key in _current_stage_dictionary["ITEM_CREATION_DICTIONARY"].keys():
		_spawn_item(_current_stage_dictionary["ITEM_CREATION_DICTIONARY"][item_list_key])
	_tilesize = Vector2i(_tile_size_info[0],_tile_size_info[1])
	#Having completed the spawning of characters and items i then move on to the
	#tileset of the environment
	#We first have to load the water tileset and then create a new tilemap layer
	#into which we insert a tileset that contains a tileAtlas with the water
	#texture. Using some preset values that need to be specified by the person
	#providing the texture we shape the tileatlas and specify the coordinates
	#that contain the wanted graphic of water. Then we add the atlas as a
	#source to the tileset and then change the z_index to be behind the user
	#by 2 and set its y_sort as enabled so that if the user is under the tile
	#in height then they will be obscured by it otherwise they will hide it.
	#We then add the tilemap to the scene as a child and we place it in a big
	#30x30 radius to simulate a big body of water
	#After putting the water at the bottom we then add another tilemaplayer
	#that will contain a grassy terrain so that they user can have ground to
	#stand on. I created an array of vector2i's to tell where i place which
	#grass tile because contrary to water tile, the grass tiles contain many
	#more than 1 tile and thus i have to create a shape that makes sense on the
	#world
	#The next tilemap layer i made contains elevated ground which is what stops
	#the user from advancing to specific location. Other than following the
	#previous steps from before i also create a physics layer which is the
	#same as the user's collision layer. Then we create a collision polygon on
	#the tilemap's tiledata, we set the polygon's shape so that it covers all
	#the tile's corners and thus we have given the elevated tilemap layer 
	#collision
	
	#INITIALIZE A STAR GRID#
	_astar_grid = AStarGrid2D.new()
	_astar_grid.default_compute_heuristic = AStarGrid2D.HEURISTIC_MANHATTAN
	_astar_grid.default_estimate_heuristic = AStarGrid2D.HEURISTIC_MANHATTAN
	_astar_grid.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	_astar_grid.cell_size = _tilesize
	#_astar_grid.region = Rect2(Vector2.ZERO, ceil(get_viewport_rect().size / _astar_grid.cell_size))
	_astar_grid.region = Rect2(Vector2(-15.0,-15.0), Vector2(30.0,30.0))
	_astar_grid.update()
	print_debug(_astar_grid.region)
	#INITIALIZE A STAR GRID#
	
	var tile_dictionary: Dictionary = _current_stage_dictionary["TILE_DICTIONARY"]
	var tile_path: Resource = null
	var tilemapLayer: TileMapLayer = null
	var tileSetTemp: TileSet = null
	var tileAtlasTemp : TileSetAtlasSource = null
	for tile_spec in tile_dictionary.values():
		var file_path: String = ""
		if OS.has_feature("standalone"):
			file_path = OS.get_executable_path().get_base_dir() + tile_spec["PATH"]
		else:
			file_path = tile_spec["PATH"]
		tile_path = load(file_path)
		tilemapLayer = TileMapLayer.new()
		tileSetTemp = TileSet.new()
		tileAtlasTemp = TileSetAtlasSource.new()
		tileSetTemp.tile_size = _tilesize
		tileSetTemp.tile_shape = TileSet.TILE_SHAPE_SQUARE
		tileAtlasTemp.texture = tile_path
		for tl_create in tile_spec["TILE_CREATION"]:
			tileAtlasTemp.create_tile(Vector2i(tl_create[0],tl_create[1]),Vector2i(1,1))
		tileAtlasTemp.texture_region_size = _tilesize
		tileSetTemp.add_source(tileAtlasTemp)
		tilemapLayer.tile_set = tileSetTemp
		tilemapLayer.z_index = tile_spec["Z_INDEX"]
		tilemapLayer.y_sort_enabled = tile_spec["Y_SORT"]
		
		if tile_spec.has("COLLISION"):
			var tile_collision: Dictionary = tile_spec["COLLISION"]
			tileSetTemp.add_physics_layer(tile_collision["PHYSICS_LAYER"])
			var tile_data_temp: TileData = tileAtlasTemp.get_tile_data(Vector2i(tile_collision["ATLAS_COORDS"][0],tile_collision["ATLAS_COORDS"][1]),tile_collision["ALTERNATIVE_TILE"])
			tile_data_temp.add_collision_polygon(tile_collision["LAYER_ID"])
			tile_data_temp.set_collision_polygon_points(tile_collision["LAYER_ID"], tile_collision["POLYGON_INDEX"], PackedVector2Array([Vector2(tile_collision["POLYGON"][0][0], tile_collision["POLYGON"][0][1]),Vector2(tile_collision["POLYGON"][1][0], tile_collision["POLYGON"][1][1]),Vector2(tile_collision["POLYGON"][2][0], tile_collision["POLYGON"][2][1]),Vector2(tile_collision["POLYGON"][3][0], tile_collision["POLYGON"][3][1])]))
			
			#WE NOW TRY TO MAKE THE OBSTACLE CUSTOM DATA LAYER
			tileSetTemp.add_custom_data_layer(tile_collision["LAYER_ID"])
			tileSetTemp.set_custom_data_layer_name(tile_collision["LAYER_ID"],"obstacle")
			tileSetTemp.set_custom_data_layer_type(tile_collision["LAYER_ID"],TYPE_BOOL)
			var tile_data_temp_2: TileData = tileAtlasTemp.get_tile_data(Vector2i(tile_collision["ATLAS_COORDS"][0],tile_collision["ATLAS_COORDS"][1]),tile_collision["ALTERNATIVE_TILE"])
			tile_data_temp_2.set_custom_data("obstacle",true)
			#WE NOW TRY TO MAKE THE OBSTACLE CUSTOM DATA LAYER
			
		add_child(tilemapLayer)
		if tile_spec.has("CELLS_BLOCK"):
			var x_num: Array = [tile_spec["CELLS_BLOCK"][0][0][0],tile_spec["CELLS_BLOCK"][1][0][0]]
			var y_num: Array = [tile_spec["CELLS_BLOCK"][0][0][1],tile_spec["CELLS_BLOCK"][1][0][1]]
			var at_coords: Vector2i = Vector2i(tile_spec["CELLS_BLOCK"][0][2][0],tile_spec["CELLS_BLOCK"][0][2][1])
			var x_amount: int = x_num[1] - x_num[0]
			var y_amount: int = y_num[1] - y_num[0]
			for i in range(x_amount):
				for j in range(y_amount):
					tilemapLayer.set_cell(Vector2i(x_num[0]+i,y_num[0]+j),tileSetTemp.get_source_id(0),at_coords)
		elif tile_spec.has("CELLS"):
			for coor_dets in tile_spec["CELLS"]:
				var coor: Vector2i = Vector2i(coor_dets[0][0],coor_dets[0][1])
				var s_id: int = coor_dets[1]
				var at_coor: Vector2i = Vector2i(coor_dets[2][0],coor_dets[2][1])
				tilemapLayer.set_cell(coor,s_id, at_coor)
		
		#APPLY THE OBSTACLES IN ASTARGRID#
		if !tileSetTemp.has_custom_data_layer_by_name("obstacle"):
			continue
		for id in tilemapLayer.get_used_cells():
			var data = tilemapLayer.get_cell_tile_data(id)
			if data and data.get_custom_data('obstacle'):
				#print_debug("FOUND AN OBSTACLE")
				_astar_grid.set_point_solid(id)
			#else:
				#print_debug("NOT AN OBSTACLE")
				#APPLY THE OBSTACLES IN ASTARGRID#
	#%GridDisplay.grid = _astar_grid
	for element in _elements_not_there:
		var nd = find_child(element["ELEMENT"],true,false)
		if nd != null:
			nd.theme_type_variation = element["TYPE"]
	
	#After that we do the same but for non player characters
	for npcs_list_key in _current_stage_dictionary["NPC_CREATION_DICTIONARY"].keys():
		_spawn_non_players(_current_stage_dictionary["NPC_CREATION_DICTIONARY"][npcs_list_key])

func _end_stage() -> void:
	stage_discontinue.emit()
	queue_free()
