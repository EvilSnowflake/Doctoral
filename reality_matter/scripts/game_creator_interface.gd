extends CanvasLayer

var csv_file_path: String = ""
var png_file_path: String = ""
var speadsheet_textbox
var tile_set_path_textbox
var num_of_stages: LineEdit
var stage_premade_container: TabContainer

var num_of_stage_items: Array[Node]
var stage_item_premade_containers: Array[Node]
var num_of_stage_item: Node
var stage_item_premade_container: Node
var num_of_stage_item_path: String
var stage_item_premade_container_path: String


var num_of_stage_chars: Array[Node]
var stage_chars_premade_containers: Array[Node]
var num_of_stage_char: Node
var stage_chars_premade_container: Node
var num_of_stage_char_path: String
var stage_char_premade_container_path: String

var num_of_stage_tilesets: Array[Node]
var stage_tilesets_premade_containers: Array[Node]
var num_of_stage_tileset: Node
var stage_tilesets_premade_container: Node
var num_of_stage_tileset_path: String
var stage_tileset_premade_container_path: String

var num_of_stage_char_animation: Node
var stage_char_animation_premade_container: Node
var num_of_stage_char_animation_path: String
var stage_char_animation_premade_container_path: String

var num_of_stage_char_quest_check: Node
var stage_char_quest_check_premade_container: Node
var num_of_stage_char_quest_check_path: String
var stage_char_quest_check_premade_container_path: String

@onready var stages = %STAGES


# Called when the node enters the scene tree for the first time.
func _ready():
	speadsheet_textbox = find_child("SpeadsheetTextbox")
	tile_set_path_textbox = find_child("TileSetPathTextbox")
	speadsheet_textbox.focus_entered.connect(on_spreadsheet_textbox_focus_entered)
	tile_set_path_textbox.focus_entered.connect(on_tilepath_textbox_focus_entered)
	
	
	stage_premade_container = stages.find_child("StageTabContainer")
	num_of_stages = stages.find_child("NUM_OF_STAGES")
	num_of_stages.text_changed.connect(duplicate_form_element.bind(stage_premade_container, stage_premade_container.get_child(0).duplicate()))
	
	stage_item_premade_container = stage_premade_container.find_child("ItemStageTabContainer")
	num_of_stage_item = stage_premade_container.find_child("NUM_OF_STAGE_ITEMS")
	num_of_stage_item_path = str(num_of_stage_item.get_path())
	stage_item_premade_container_path = str(stage_item_premade_container.get_path())
	stage_chars_premade_container = stage_premade_container.find_child("CharacterStageTabContainer")
	num_of_stage_char = stage_premade_container.find_child("NUM_OF_STAGE_CHARACTERS")
	num_of_stage_char_path = str(num_of_stage_char.get_path())
	stage_char_premade_container_path = str(stage_chars_premade_container.get_path())
	stage_tilesets_premade_container = stage_premade_container.find_child("TileSetStageTabContainer")
	num_of_stage_tileset = stage_premade_container.find_child("NUM_OF_STAGE_TILESETS")
	num_of_stage_tileset_path = str(num_of_stage_tileset.get_path())
	stage_tileset_premade_container_path = str(stage_tilesets_premade_container.get_path())
	
	num_of_stage_char_animation = stage_chars_premade_container.find_child("NUM_OF_STAGE_CHAR_ANIMATION")
	stage_char_animation_premade_container = stage_chars_premade_container.find_child("StageCharAnimationTabContainer")
	num_of_stage_char_animation_path = str(num_of_stage_char_animation.get_path())
	stage_char_animation_premade_container_path = str(stage_char_animation_premade_container.get_path())
	
	check_numbered_line_edits()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func on_player_selected_csv_file(_path: String) -> void:
	csv_file_path = _path
	print_debug(csv_file_path)
	if !csv_file_path.ends_with(".csv"):
		print_debug("FILE NOT CSV")
	speadsheet_textbox.text = csv_file_path
	speadsheet_textbox.release_focus()
	var _sprd_array : Array = []
	var file = FileAccess.open(csv_file_path, FileAccess.READ)
	while not file.eof_reached():
		var line = file.get_line()
		_sprd_array.append(line.split(","))
	file.close()
	print_debug(_sprd_array)

func on_player_selected_png_file(_path: String) -> void:
	png_file_path = _path
	print_debug(png_file_path)
	if !png_file_path.ends_with(".png"):
		print_debug("FILE NOT PNG")
	tile_set_path_textbox.release_focus()
	tile_set_path_textbox.text = png_file_path

func on_spreadsheet_textbox_focus_entered() -> void:
	var fil_Dil: FileDialog = FileDialog.new()
	fil_Dil.set_file_mode(FileDialog.FILE_MODE_OPEN_FILE)
	fil_Dil.set_access(FileDialog.ACCESS_FILESYSTEM)
	fil_Dil.file_selected.connect(on_player_selected_csv_file)
	fil_Dil.use_native_dialog = true
	fil_Dil.add_filter("*.csv")
	add_child(fil_Dil)
	fil_Dil.show()

func on_tilepath_textbox_focus_entered() -> void:
	var fil_Dil2: FileDialog = FileDialog.new()
	fil_Dil2.set_file_mode(FileDialog.FILE_MODE_OPEN_FILE)
	fil_Dil2.set_access(FileDialog.ACCESS_FILESYSTEM)
	fil_Dil2.file_selected.connect(on_player_selected_png_file)
	fil_Dil2.use_native_dialog = true
	fil_Dil2.add_filter("*.png")
	add_child(fil_Dil2)
	fil_Dil2.show()

func duplicate_form_element(_num: String, _cont, _ch) -> void:
	var numbe: int = _num.to_int()
	if numbe < _cont.get_child_count():
		for i in range(_cont.get_child_count()-1,numbe-1, -1):
			_cont.get_child(i).queue_free()
			#print_debug(_cont.get_child(-1).name)
		return
	while _cont.get_child_count() < numbe:
		var element: MarginContainer = _ch.duplicate()
		_cont.add_child(element)
		element.name = _cont.get_child(0).name
		#print_debug(_cont.get_child(-1).name)
	check_numbered_line_edits()
	#print_debug(_num)
	#print_debug(_ch)
	
func check_numbered_line_edits() -> void:
	#stage_item_premade_containers = stage_premade_container.find_children("ItemStageTabContainer", "TabContainer", true , false)
	#num_of_stage_items = stage_premade_container.find_children("NUM_OF_STAGE_ITEMS", "LineEdit", true , false)
	#for i in range(num_of_stage_items.size()):
		#if num_of_stage_items[i].text_changed.is_connected(duplicate_form_element): continue
		#print_debug("Not connected")
		#num_of_stage_items[i].text_changed.connect(duplicate_form_element.bind(stage_item_premade_containers[i],stage_item_premade_containers[i].get_child(0).duplicate()))
	
	#stage_chars_premade_containers = stage_premade_container.find_children("CharacterStageTabContainer", "TabContainer", true , false)
	#num_of_stage_chars = stage_premade_container.find_children("NUM_OF_STAGE_CHARACTERS", "LineEdit", true , false)
	#for i in range(num_of_stage_chars.size()):
		#if num_of_stage_chars[i].text_changed.is_connected(duplicate_form_element): continue
		#print_debug("Not connected")
		#num_of_stage_chars[i].text_changed.connect(duplicate_form_element.bind(stage_chars_premade_containers[i],stage_chars_premade_containers[i].get_child(0).duplicate()))
	
	#stage_tilesets_premade_containers = stage_premade_container.find_children("TileSetStageTabContainer", "TabContainer", true , false)
	#num_of_stage_tilesets = stage_premade_container.find_children("NUM_OF_STAGE_TILESETS", "LineEdit", true , false)
	#for i in range(num_of_stage_tilesets.size()):
		#if num_of_stage_tilesets[i].text_changed.is_connected(duplicate_form_element): continue
		#print_debug("Not connected")
		#num_of_stage_tilesets[i].text_changed.connect(duplicate_form_element.bind(stage_tilesets_premade_containers[i],stage_tilesets_premade_containers[i].get_child(0).duplicate()))
	
	
	#MAYBE I CAN FIND A WAY TO FIND THE STATIC PATHS ONCE AND THEN DEPENDING ON
	#THE NUM OF LINE EDITS WE MODIFY THE PATHS AND FIND THE APPROPRIATE ITEMS
	#BY CHANGING THE [ITEM]1 WITH [ITEM][NUM]. SO DEPENDING 0N THE NUMS WE GO
	#DOWN THE PATH OF A TREE THAT BRANCHES WHENEVER A NUM LINE EDIT IS FOUND
	
	for i in range(1,int(num_of_stages.text)+1):
		var benchmark1: String = "Stage"
		var new_stage_item_num_path = num_of_stage_item_path.replace(benchmark1+"1",benchmark1+str(i))
		var new_stage_item_cont_path = stage_item_premade_container_path.replace(benchmark1+"1",benchmark1+str(i))
		var new_stage_item_num_node: Node = get_node(new_stage_item_num_path)
		var new_stage_item_cont_node: Node = get_node(new_stage_item_cont_path)
		
		if !new_stage_item_num_node.text_changed.is_connected(duplicate_form_element):
			print_debug("Not connected")
			new_stage_item_num_node.text_changed.connect(duplicate_form_element.bind(new_stage_item_cont_node,new_stage_item_cont_node.get_child(0).duplicate()))
		
		for j in range(1,int(num_of_stage_item.text)):
			var benchmark12: String = "Item"
		
		var new_stage_char_num_path = num_of_stage_char_path.replace(benchmark1+"1",benchmark1+str(i))
		var new_stage_char_cont_path = stage_char_premade_container_path.replace(benchmark1+"1",benchmark1+str(i))
		var new_stage_char_num_node: Node = get_node(new_stage_char_num_path)
		var new_stage_char_cont_node: Node = get_node(new_stage_char_cont_path)
		
		if !new_stage_char_num_node.text_changed.is_connected(duplicate_form_element):
			print_debug("Not connected")
			new_stage_char_num_node.text_changed.connect(duplicate_form_element.bind(new_stage_char_cont_node,new_stage_char_cont_node.get_child(0).duplicate()))
		
		for k in range(1,int(new_stage_char_num_node.text)+1):
			var benchmark12: String = "Character"
			var new_num_of_stage_char_animation_path = (num_of_stage_char_animation_path.replace(benchmark1+"1",benchmark1+str(i))).replace(benchmark12+"1",benchmark12+str(k))
			var new_stage_char_animation_premade_container_path = (stage_char_animation_premade_container_path.replace(benchmark1+"1",benchmark1+str(i))).replace(benchmark12+"1",benchmark12+str(k))
			var new_num_of_stage_char_animation_node: Node = get_node(new_num_of_stage_char_animation_path)
			var new_stage_char_animation_premade_container_node: Node = get_node(new_stage_char_animation_premade_container_path)
			#print_debug(new_num_of_stage_char_animation_node)
			if !new_num_of_stage_char_animation_node.text_changed.is_connected(duplicate_form_element):
				print_debug("Not connected")
				new_num_of_stage_char_animation_node.text_changed.connect(duplicate_form_element.bind(new_stage_char_animation_premade_container_node,new_stage_char_animation_premade_container_node.get_child(0).duplicate()))
		
		var new_stage_tileset_num_path = num_of_stage_tileset_path.replace(benchmark1+"1",benchmark1+str(i))
		var new_stage_tileset_cont_path = stage_tileset_premade_container_path.replace(benchmark1+"1",benchmark1+str(i))
		var new_stage_tileset_num_node: Node = get_node(new_stage_tileset_num_path)
		var new_stage_tileset_cont_node: Node = get_node(new_stage_tileset_cont_path)
		
		if !new_stage_tileset_num_node.text_changed.is_connected(duplicate_form_element):
			print_debug("Not connected")
			new_stage_tileset_num_node.text_changed.connect(duplicate_form_element.bind(new_stage_tileset_cont_node,new_stage_tileset_cont_node.get_child(0).duplicate()))
		
		for l in range(1,int(num_of_stage_tileset.text)):
			var benchmark12: String = "TileSet"
	
