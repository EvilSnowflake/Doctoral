extends Node2D

const WATER = preload("uid://1fdh0hykast2")
const WATERTILESET = preload("uid://cnn5d42l12km6")

@export var player_component: PackedScene
@export var item_list: Array[PackedScene]
@export var item_resources_list: Array[Item]
@export var item_positions: Array[Vector2]
@export var playerPosition: Vector2
@export var characters_list: Array[PackedScene]
@export var characters_positions: Array[Vector2]
@export var character_items_to_give: Array[Item]
@export var user_interface_component: PackedScene
@export var inventory_spaces: int

var inventory_instance: Inventory

var _user_interface: Control

# Called when the node enters the scene tree for the first time.
func _ready():
	inventory_instance = Inventory.new()
	#inventory_instance.max_slots = inventory_spaces
	if inventory_instance.has_method("change_max_slots") and inventory_spaces != null:
		inventory_instance.change_max_slots(inventory_spaces)
	
	if user_interface_component != null:
		_spawn_user_interface(user_interface_component)
	if player_component != null && playerPosition != null:
		_spawn_player(player_component,playerPosition)
	if item_list.size() == item_positions.size() && item_positions.size() == item_resources_list.size():
		for i in range(item_list.size()):
			_spawn_item(item_list[i],item_positions[i], item_resources_list[i])
	if characters_list.size() == characters_positions.size() and characters_positions.size() == character_items_to_give.size():
		for i in range(characters_list.size()):
			_spawn_non_players(characters_list[i],characters_positions[i], character_items_to_give[i])
	
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
	#tileSet.add_physics_layer(0)
	#var tile_data :TileData = tileAtlas.get_tile_data(Vector2i(0,0),0)
	#tile_data.add_collision_polygon(0)
	#tile_data.set_collision_polygon_points(0, 0, PackedVector2Array([Vector2(-1, -1),Vector2(-1, 1),Vector2(1, 1),Vector2(1, -1)]))
	#print_debug(tile_data.get_collision_polygon_points(0,0));
	add_child(tilemapl)
	#print_debug(tileSet.tile_shape)
	#print_debug(WATERTILESET.get_source(0))
	#print_debug(tileSet.get_source(0).has_tile(Vector2i(0,0)))
	for i in range(30):
		for j in range(30):
			tilemapl.set_cell(Vector2i(i-15,j-15), tileSet.get_source_id(0), Vector2i(0,0))
	
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
	#print_debug(tileSet2.tile_shape)
	#print_debug(tileSet2.get_source(0).has_tile(Vector2i(0,0)))
	#tilemapl2.set_cell(Vector2i(i,j), tileSet2.get_source_id(0), Vector2i(i,j))
	for i in range(grassMapSize[0]):
		for j in range(grassMapSize[1]):
			tilemapl2.set_cell(Vector2i(j,i),tileSet2.get_source_id(0), grassMap[i + (i*(grassMapSize[0]-1)) + j])
	#tilemapl2.set_cell(Vector2i(0,0),tileSet2.get_source_id(0),up_left)
	#tilemapl2.set_cell(Vector2i(1,0),tileSet2.get_source_id(0),up_middle)
	#tilemapl2.set_cell(Vector2i(2,0),tileSet2.get_source_id(0),up_middle)
	#tilemapl2.set_cell(Vector2i(3,0),tileSet2.get_source_id(0),up_middle)
	#tilemapl2.set_cell(Vector2i(4,0),tileSet2.get_source_id(0),up_right)
	#tilemapl2.set_cell(Vector2i(0,1),tileSet2.get_source_id(0),middle_left)
	#tilemapl2.set_cell(Vector2i(1,1),tileSet2.get_source_id(0),middle_middle)
	#tilemapl2.set_cell(Vector2i(2,1),tileSet2.get_source_id(0),middle_middle)
	#tilemapl2.set_cell(Vector2i(3,1),tileSet2.get_source_id(0),middle_middle)
	#tilemapl2.set_cell(Vector2i(4,1),tileSet2.get_source_id(0),middle_right)
	#tilemapl2.set_cell(Vector2i(0,2),tileSet2.get_source_id(0),middle_left)
	#tilemapl2.set_cell(Vector2i(1,2),tileSet2.get_source_id(0),middle_middle)
	#tilemapl2.set_cell(Vector2i(2,2),tileSet2.get_source_id(0),middle_middle)
	#tilemapl2.set_cell(Vector2i(3,2),tileSet2.get_source_id(0),middle_middle)
	#tilemapl2.set_cell(Vector2i(4,2),tileSet2.get_source_id(0),middle_right)
	#tilemapl2.set_cell(Vector2i(0,3),tileSet2.get_source_id(0),middle_left)
	#tilemapl2.set_cell(Vector2i(1,3),tileSet2.get_source_id(0),middle_middle)
	#tilemapl2.set_cell(Vector2i(2,3),tileSet2.get_source_id(0),middle_middle)
	#tilemapl2.set_cell(Vector2i(3,3),tileSet2.get_source_id(0),middle_middle)
	#tilemapl2.set_cell(Vector2i(4,3),tileSet2.get_source_id(0),middle_right)
	#tilemapl2.set_cell(Vector2i(0,4),tileSet2.get_source_id(0),down_left)
	#tilemapl2.set_cell(Vector2i(1,4),tileSet2.get_source_id(0),down_middle)
	#tilemapl2.set_cell(Vector2i(2,4),tileSet2.get_source_id(0),down_middle)
	#tilemapl2.set_cell(Vector2i(3,4),tileSet2.get_source_id(0),down_middle)
	#tilemapl2.set_cell(Vector2i(4,4),tileSet2.get_source_id(0),down_right)
	
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
	#print_debug(tilemapl_el.y_sort_enabled)
	
	#This part adds collision to whichever tile i want
	tileSet_el.add_physics_layer(0)
	#var tile_data_el_1 :TileData = tileAtlas_el.get_tile_data(Vector2i(3,4),0)
	#tile_data_el_1.add_collision_polygon(0)
	#tile_data_el_1.set_collision_polygon_points(0, 0, PackedVector2Array([Vector2(-1, -1),Vector2(-1, 1),Vector2(1, 1),Vector2(1, -1)]))
	#print_debug(tile_data_el_1.get_collision_polygon_points(0,0));
	var tile_data_el_2 :TileData = tileAtlas_el.get_tile_data(Vector2i(3,5),0)
	tile_data_el_2.add_collision_polygon(0)
	tile_data_el_2.set_collision_polygon_points(0, 0, PackedVector2Array([Vector2(-1, -1),Vector2(-1, 1),Vector2(1, 1),Vector2(1, -1)]))
	#This part adds collision to whichever tile i want
	
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

func _spawn_item(item: PackedScene, new_position: Vector2, item_resource: Item):
	var it = item.instantiate()
	add_child(it)
	it.position = new_position
	#var item_contained: Item = item_resource
	#item_contained.id = "5A"
	#item_contained.description = "THIS DOES NOTHING"
	#item_contained.name = "GARBAGE"
	print_debug(item_resource.description)
	if it.has_signal("assign_item_contained"):
		it.emit_signal("assign_item_contained",item_resource)

func _spawn_non_players(npc: PackedScene, new_position: Vector2, item_to_give: Item = null):
	var new_npc = npc.instantiate()
	add_child(new_npc)
	new_npc.position = new_position
	if item_to_give != null and new_npc.has_signal("assign_item_to_give"):
		new_npc.emit_signal("assign_item_to_give", item_to_give)
	if _user_interface == null:
		return
	if _user_interface.has_method("connect_characters_dialogues"):
		_user_interface.connect_characters_dialogues(new_npc)

func _spawn_user_interface(ui: PackedScene):
	var new_ui = ui.instantiate()
	add_child(new_ui)
	_user_interface = new_ui
	if new_ui.has_method("receive_inventory") and inventory_instance != null:
		new_ui.receive_inventory(inventory_instance)
