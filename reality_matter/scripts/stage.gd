extends Node2D

#This script gives function to the current stage of the game. The stage contains
#the environment the user interacts with, the non player characters and the
#items they can pick up. Curreently the stage spawns the user chartacter and
#the tileset thje user can wander in, along with the npcs and the items while
#also giving them their properties through code alone but this functionality
#will be passed to the game manager eventualy and the game manager will take
#those properties from a json file

## This variable contains a reference to the player character scene used to
## instantiate the player character
@export var player_component: PackedScene
## This variable contains an array of item scenes. Those items are going to be
## instantiated during the start of the game based on the item positions list
@export var item_list: Array[PackedScene]
## This varaible contains a list of the items that will be assigned on the 
## previously named item list instances, based on what the item will be in this
## list, that item will be shown on the overworld
@export var item_resources_list: Array[Item]
## This variable holds an array of vector2 positions that informs the items
## where they will be deployed
@export var item_positions: Array[Vector2]
## This variable contains the vector2 position the player will be standing on
## when entering a scene
@export var playerPosition: Vector2
## This variable holds an array with the non player character scenes that will
## be instantiated on to the environment
@export var characters_list: Array[PackedScene]
## This variable contains a list with the positions of the non player characters
## that will be deployed on to the stage
@export var characters_positions: Array[Vector2]
## This variable contains an array that will dictate what items each npc will
## give the user, if we don't need to give any items to them, just add a null
## value
@export var character_items_to_give: Array[Item]
## This variable should contain each and every npc dialogue in a row
@export var character_dialogues_to_say: Dictionary =  {
	"NPC_1":{
		"Dialogue_2":{
			"STARTING_CONVERSATION" :
				{"Hello#1": 
					{"OPTION_1": "Hi there#1",
					"OPTION_2": "Hello to you too!#1"
					}
				},
			"Hi there#1":
				{"Here' an item for you#2":
					{"OPTION_1": "Thanks#2",
					"OPTION_2": "Bye#2"
					}
				},
			"Hello to you too!#1":
				{"Goodbye#2":
					{"OPTION_1": "Bye#2",
					"OPTION_2": "Sure#2"
					}
				},
			"Bye#2":"ENDING_CONVERSATION",
			"Goodbye#2": "ENDING_CONVERSATION",
			"Sure#2": "ENDING_CONVERSATION",
			"Thanks#2": "GIVE_ITEM"
		},
		"Dialogue_1":{
			"STARTING_CONVERSATION" : "I already said hi go away#1",
			"I already said hi go away#1": "ENDING_CONVERSATION"
			}
	},
	"NPC_2":{
		"Dialogue_2":{
			"STARTING_CONVERSATION" : "Do you perhaps have a bone item on you?#1",
			"Do you perhaps have a bone item on you?#1":
				{"If you do please give it to me#2":
					{"OPTION_1": "Sure#2",
					"OPTION_2": "No#2"}
					},
			"Sure#2":"TAKE_ITEM_1",
			"No#2":"NOT_TAKE_ITEM"
		},
		"Dialogue_1":{
			"STARTING_CONVERSATION" : "Thank you for the item#1",
			"Thank you for the item#1": "ENDING_CONVERSATION"
			
		}
	}
}
## This variable should contain a reference to the user interface scene to
## instantiate
@export var user_interface_component: PackedScene
## This variable dictates how many inventory slots the user interface is going
## to contain
@export var inventory_spaces: int

## This variable should contain the current instance of the user inventory
var inventory_instance: Inventory

## This variable should contain the user interface instance
var _user_interface: Control

# Called when the node enters the scene tree for the first time.
func _ready():
	#During startup we need to create an instance of the user's inventory
	inventory_instance = Inventory.new()
	#Then we try to modify the inventory's max item slots
	if inventory_instance.has_method("change_max_slots") and inventory_spaces != null:
		inventory_instance.change_max_slots(inventory_spaces)
	#Afterwards we try to spawn the user interface
	if user_interface_component != null:
		_spawn_user_interface(user_interface_component)
	#And then spawn the player's character
	if player_component != null && playerPosition != null:
		_spawn_player(player_component,playerPosition)
	#After we check the items array and spawn each of them in the position set
	#by the item position list and then assign an item to it
	if item_list.size() == item_positions.size() && item_positions.size() == item_resources_list.size():
		for i in range(item_list.size()):
			_spawn_item(item_list[i],item_positions[i], item_resources_list[i])
	#After that we do the same but for non player characters
	if characters_list.size() == characters_positions.size() and characters_positions.size() == character_items_to_give.size():
		for i in range(characters_list.size()):
			_spawn_non_players(characters_list[i],characters_positions[i], character_dialogues_to_say["NPC_"+str(i+1)], character_items_to_give[i])
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
	var water: Resource = load("res://assets/tiles/Water.png")
	var tile_size = Vector2i(64,64)
	var tilemapl: TileMapLayer = TileMapLayer.new()
	var tileSet: TileSet = TileSet.new()
	var tileAtlas = TileSetAtlasSource.new()
	tileSet.tile_size = tile_size
	tileSet.tile_shape = TileSet.TILE_SHAPE_SQUARE
	tileAtlas.texture = water
	tileAtlas.create_tile(Vector2i(0,0),Vector2i(1,1))
	tileAtlas.texture_region_size = tile_size
	tileSet.add_source(tileAtlas)
	tilemapl.tile_set = tileSet
	tilemapl.z_index = -2
	tilemapl.y_sort_enabled = true
	add_child(tilemapl)
	for i in range(30):
		for j in range(30):
			tilemapl.set_cell(Vector2i(i-15,j-15), tileSet.get_source_id(0), Vector2i(0,0))
	#After putting the water at the bottom we then add another tilemaplayer
	#that will contain a grassy terrain so that they user can have ground to
	#stand on. I created an array of vector2i's to tell where i place which
	#grass tile because contrary to water tile, the grass tiles contain many
	#more than 1 tile and thus i have to create a shape that makes sense on the
	#world
	var tilemap_flat: Resource = load("res://assets/tiles/Tilemap_Flat.png")
	var tilemapl2: TileMapLayer = TileMapLayer.new()
	var tileSet2: TileSet = TileSet.new()
	var tileAtlas2 = TileSetAtlasSource.new()
	var up_left : Vector2i = Vector2i(0,0)
	var up_middle : Vector2i = Vector2i(1,0)
	var up_right : Vector2i = Vector2i(2,0)
	var middle_left : Vector2i = Vector2i(0,1)
	var middle_middle : Vector2i = Vector2i(1,1)
	var middle_right : Vector2i = Vector2i(2,1)
	var down_left : Vector2i = Vector2i(0,2)
	var down_middle : Vector2i = Vector2i(1,2)
	var down_right : Vector2i = Vector2i(2,2)
	var grassMap: Array[Vector2i] = [up_left, up_middle, up_middle, up_middle, up_middle, up_middle, up_right, middle_left, middle_middle, middle_middle, middle_middle, middle_middle, middle_middle, middle_right, middle_left, middle_middle, middle_middle, middle_middle, middle_middle, middle_middle, middle_right, middle_left, middle_middle, middle_middle, middle_middle, middle_middle, middle_middle, middle_right, middle_left, middle_middle, middle_middle, middle_middle, middle_middle, middle_middle, middle_right, middle_left, middle_middle, middle_middle, middle_middle, middle_middle, middle_middle, middle_right, down_left, down_middle, down_middle, down_middle, down_middle, down_middle, down_right]
	var grassMapSize: Vector2i = Vector2i(7,7)
	tileSet2.tile_size = tile_size
	tileSet2.tile_shape = TileSet.TILE_SHAPE_SQUARE
	tileAtlas2.texture = tilemap_flat
	for i in range(3):
		for j in range(3):
			tileAtlas2.create_tile(Vector2i(i,j),Vector2i(1,1))
	tileAtlas2.texture_region_size = tile_size
	tileSet2.add_source(tileAtlas2)
	tilemapl2.tile_set = tileSet2
	tilemapl2.z_index = -1
	tilemapl2.y_sort_enabled = true
	add_child(tilemapl2)
	for i in range(grassMapSize[0]):
		for j in range(grassMapSize[1]):
			tilemapl2.set_cell(Vector2i(j,i),tileSet2.get_source_id(0), grassMap[i + (i*(grassMapSize[0]-1)) + j])
	#The next tilemap layer i made contains elevated ground which is what stops
	#the user from advancing to specific location. Other than following the
	#previous steps from before i also create a physics layer which is the
	#same as the user's collision layer. Then we create a collision polygon on
	#the tilemap's tiledata, we set the polygon's shape so that it covers all
	#the tile's corners and thus we have given the elevated tilemap layer 
	#collision
	var tilemap_Elevation: Resource = load("res://assets/tiles/Tilemap_Elevation.png")
	var tilemapl_el: TileMapLayer = TileMapLayer.new()
	var tileSet_el: TileSet = TileSet.new()
	var tileAtlas_el = TileSetAtlasSource.new()
	tileSet_el.tile_size = tile_size
	tileSet_el.tile_shape = TileSet.TILE_SHAPE_SQUARE
	tileAtlas_el.texture = tilemap_Elevation
	tileAtlas_el.create_tile(Vector2i(3,4),Vector2i(1,1))
	tileAtlas_el.create_tile(Vector2i(3,5),Vector2i(1,1))
	tileAtlas_el.texture_region_size = tile_size
	tileSet_el.add_source(tileAtlas_el)
	tilemapl_el.tile_set = tileSet_el
	tilemapl_el.z_index = 0
	tilemapl_el.y_sort_enabled = true
	tileSet_el.add_physics_layer(0)
	var tile_data_el_2 :TileData = tileAtlas_el.get_tile_data(Vector2i(3,5),0)
	tile_data_el_2.add_collision_polygon(0)
	tile_data_el_2.set_collision_polygon_points(0, 0, PackedVector2Array([Vector2(-1, -1),Vector2(-1, 1),Vector2(1, 1),Vector2(1, -1)]))
	add_child(tilemapl_el)
	tilemapl_el.set_cell(Vector2i(0,0), tileSet.get_source_id(0), Vector2i(3,4))
	tilemapl_el.set_cell(Vector2i(0,1), tileSet.get_source_id(0), Vector2i(3,5))
	tilemapl_el.set_cell(Vector2i(1,-1), tileSet.get_source_id(0), Vector2i(3,4))
	tilemapl_el.set_cell(Vector2i(1,0), tileSet.get_source_id(0), Vector2i(3,5))
	tilemapl_el.set_cell(Vector2i(2,-1), tileSet.get_source_id(0), Vector2i(3,4))
	tilemapl_el.set_cell(Vector2i(2,0), tileSet.get_source_id(0), Vector2i(3,5))
	tilemapl_el.set_cell(Vector2i(3,-1), tileSet.get_source_id(0), Vector2i(3,4))
	tilemapl_el.set_cell(Vector2i(3,0), tileSet.get_source_id(0), Vector2i(3,5))
	tilemapl_el.set_cell(Vector2i(4,0), tileSet.get_source_id(0), Vector2i(3,4))
	tilemapl_el.set_cell(Vector2i(4,1), tileSet.get_source_id(0), Vector2i(3,5))
	tilemapl_el.set_cell(Vector2i(4,2), tileSet.get_source_id(0), Vector2i(3,4))
	tilemapl_el.set_cell(Vector2i(4,3), tileSet.get_source_id(0), Vector2i(3,5))
	tilemapl_el.set_cell(Vector2i(3,3), tileSet.get_source_id(0), Vector2i(3,4))
	tilemapl_el.set_cell(Vector2i(3,4), tileSet.get_source_id(0), Vector2i(3,5))
	tilemapl_el.set_cell(Vector2i(2,3), tileSet.get_source_id(0), Vector2i(3,4))
	tilemapl_el.set_cell(Vector2i(2,4), tileSet.get_source_id(0), Vector2i(3,5))
	tilemapl_el.set_cell(Vector2i(1,3), tileSet.get_source_id(0), Vector2i(3,4))
	tilemapl_el.set_cell(Vector2i(1,4), tileSet.get_source_id(0), Vector2i(3,5))
	tilemapl_el.set_cell(Vector2i(0,2), tileSet.get_source_id(0), Vector2i(3,4))
	tilemapl_el.set_cell(Vector2i(0,3), tileSet.get_source_id(0), Vector2i(3,5))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

## This function is used to spawn the player on the current scene. It requires a
## player scene to instantiate and a position. After setting the player's
## position we then add a reference to the user's inventory on that character
func _spawn_player(player: PackedScene, new_position: Vector2):
	var pl = player.instantiate()
	add_child(pl)
	#pl.add_child(_user_interface)
	pl.position = new_position
	if _user_interface == null:
		return
	if _user_interface.has_method("connect_player_adding_item"):
		_user_interface.connect_player_adding_item(pl)
	if pl.has_method("receive_inventory") and inventory_instance != null:
		pl.receive_inventory(inventory_instance)

## This function is used to instantiate the required items to the current scene
## It requires the interactive item's scene, the position the item is going
## to have and what item is going to be
func _spawn_item(item: PackedScene, new_position: Vector2, item_resource: Item):
	var it = item.instantiate()
	add_child(it)
	it.position = new_position
	print_debug(item_resource.description)
	if it.has_signal("assign_item_contained"):
		it.emit_signal("assign_item_contained",item_resource)

## This function is used to spawn the characters that populate the scene other
## than the player character. We require the character's scene, their position
## on the environemnt, their dialogue and what item (if any) they can give the
## player character.
func _spawn_non_players(npc: PackedScene, new_position: Vector2, dial: Dictionary, item_to_give: Item = null):
	var new_npc = npc.instantiate()
	add_child(new_npc)
	new_npc.position = new_position
	if item_to_give != null and new_npc.has_signal("assign_item_to_give"):
		new_npc.emit_signal("assign_item_to_give", item_to_give)
	if new_npc.has_method("add_dialogue"):
		new_npc.add_dialogue(dial)
	if _user_interface == null:
		return
	if _user_interface.has_method("connect_characters_dialogues"):
		_user_interface.connect_characters_dialogues(new_npc)

## This function is used to instantiate the user interface on the scene. It only
## requires the interface's scene.
func _spawn_user_interface(ui: PackedScene):
	var new_ui = ui.instantiate()
	add_child(new_ui)
	_user_interface = new_ui
	if new_ui.has_method("receive_inventory") and inventory_instance != null:
		new_ui.receive_inventory(inventory_instance)
