extends CanvasLayer

var csv_file_path: String = ""
var png_file_path: String = ""
var speadsheet_textbox
var tile_set_path_textbox
var num_of_stages: Node
var stage_premade_container: Node
var num_of_stages_path: String
var stage_premade_container_path: String

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
@onready var player_creation_dictionary = %PLAYER_CREATION_DICTIONARY
@onready var quest_dictionary = %QUEST_DICTIONARY

var testDict: Dictionary = {
		"Stage": {
			"stage_item_premade_container_path": "num_of_stage_item_path",
			"stage_char_premade_container_path": "num_of_stage_char_path",
			"Character" : {
					"new_stage_char_animation_premade_container_path": "new_num_of_stage_char_animation_path"
			},
			"stage_tileset_premade_container_path": "num_of_stage_tileset_path"
		}
	}

# Called when the node enters the scene tree for the first time.
func _ready():
	speadsheet_textbox = find_child("SpeadsheetTextbox")
	tile_set_path_textbox = find_child("TileSetPathTextbox")
	speadsheet_textbox.focus_entered.connect(on_spreadsheet_textbox_focus_entered)
	tile_set_path_textbox.focus_entered.connect(on_tilepath_textbox_focus_entered)
	
	
	stage_premade_container = stages.find_child("StageTabContainer")
	num_of_stages = stages.find_child("NUM_OF_STAGES")
	num_of_stages_path = num_of_stages.get_path()
	stage_premade_container_path = stage_premade_container.get_path()
	#num_of_stages.text_changed.connect(duplicate_form_element.bind(stage_premade_container, stage_premade_container.get_child(0).duplicate()))
	
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
	
	
	num_of_stage_char_quest_check_path = stage_chars_premade_container.find_child("NUM_OF_STAGE_CHAR_QUEST_CHECKS").get_path()
	stage_char_quest_check_premade_container_path = stage_chars_premade_container.find_child("StageCharQuestCheckTabContainer").get_path()
	
	var num_of_player_tweens_path: String = player_creation_dictionary.find_child("PLAYER_TWEENS").get_path()
	var player_tweens_container_path: String = player_creation_dictionary.find_child("PlayerTweensTabContainer").get_path()
	
	var num_of_quest_path: String = quest_dictionary.find_child("QUEST_NUM").get_path()
	var quest_container_path: String = quest_dictionary.find_child("QuestsTabContainer").get_path()
	var num_of_quest_step_path: String = quest_dictionary.find_child("STEPS_NUM").get_path()
	var quest_step_container_path: String = quest_dictionary.find_child("QuestStepTabContainer").get_path()
	var num_of_quest_reward_path: String = quest_dictionary.find_child("REWARD_ITEM_NUM").get_path()
	var quest_reward_container_path: String = quest_dictionary.find_child("QuestRewardTabContainer").get_path()
	
	var benchmark1: String = "Stage"
	var benchmark12: String = "Character"
	var benchmark3: String = "Quest"
	
	testDict = {stage_premade_container_path : num_of_stages_path,
		benchmark1:
		{
			stage_item_premade_container_path: num_of_stage_item_path,
			stage_char_premade_container_path: num_of_stage_char_path,
				benchmark12 : {
					stage_char_animation_premade_container_path : num_of_stage_char_animation_path,
					stage_char_quest_check_premade_container_path: num_of_stage_char_quest_check_path
				},
			stage_tileset_premade_container_path: num_of_stage_tileset_path
		},
		player_tweens_container_path: num_of_player_tweens_path,
		quest_container_path: num_of_quest_path,
		benchmark3: {
			quest_step_container_path: num_of_quest_step_path,
			quest_reward_container_path: num_of_quest_reward_path
		}
	}
	
	
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
	var currval
	var sum_of_benches: Array[String] = []
	var sum_of_counter_benches: Array = []
	var sum_of_keys: Array = []
	var currkey
	var currdictionary: Dictionary = {}
	sum_of_keys.append(testDict.keys())
	#print_debug("Current all keys: " + str(sum_of_keys))
	var counter : int = 10000
	while !sum_of_keys.is_empty():
		counter -= 1
		if counter == 0:
			break
		if sum_of_keys[-1] == []:
			#print_debug("No keys found on last sum of keys, skipping")
			sum_of_keys.pop_back()
			if sum_of_keys == []:
				break
			#sum_of_benches.pop_back()
			sum_of_counter_benches[-1] -= 1
			#print_debug("Current sum of counters for benches :" + str(sum_of_counter_benches))
			#print_debug("Current all keys: " + str(sum_of_keys))
			if sum_of_counter_benches[-1] == 0:
				sum_of_counter_benches.pop_back()
				#sum_of_keys.pop_back()
			continue
		currkey = sum_of_keys[-1].front()
		#print_debug("Current all keys: " + str(sum_of_keys))
		#print_debug("Current key: " + str(currkey))
			
		if sum_of_benches.is_empty():
			#print_debug("No benches found, getting the first one")
			currval = testDict[currkey]
			currdictionary = testDict
		else:
			#print_debug("Found benches, searching them")
			#print_debug("Current sum of benches :" + str(sum_of_benches))
			currdictionary = testDict[sum_of_benches[0]]
			for be in range(1,sum_of_benches.size()):
				currdictionary = currdictionary[sum_of_benches[be]]
			if currkey == sum_of_benches[-1]:
				sum_of_keys[-1].pop_front()
				sum_of_benches.pop_back()
				continue
			currval = currdictionary[currkey]
		#print_debug("Current value: " + str(currval))
		#print_debug(currdictionary)
		if typeof(currval) == TYPE_STRING:
			#print_debug("Current val is a string so applying!!")
			var new_num_path: String = currval
			var new_cont_path: String = currkey
			#if sum_of_counter_benches.size() == sum_of_benches.size() and sum_of_counter_benches.size() > 0:	
			#var next_num = 0
			
			for b in range(sum_of_benches.size()):
				#print_debug(sum_of_benches[b]+"1" + "     " + sum_of_benches[b]+str(sum_of_counter_benches[b]))
				if sum_of_counter_benches[b] == 1:
					continue
				new_num_path = new_num_path.replace(sum_of_benches[b]+"1",sum_of_benches[b]+str(sum_of_counter_benches[b]))
				new_cont_path = new_cont_path.replace(sum_of_benches[b]+"1",sum_of_benches[b]+str(sum_of_counter_benches[b]))
			
			#print_debug(has_node(new_num_path))
			#print_debug(has_node(new_cont_path))
			var new_num_node = get_node(new_num_path)
			var new_cont_node = get_node(new_cont_path)
			if new_num_node == null or new_cont_node == null:
				print_debug("A num or cont node does not exist")
				break
			
			if !new_num_node.text_changed.is_connected(duplicate_form_element):
					#print_debug("Not connected")
					new_num_node.text_changed.connect(duplicate_form_element.bind(new_cont_node,new_cont_node.get_child(0).duplicate()))
			
			if sum_of_counter_benches.size() <= sum_of_benches.size() or sum_of_benches.size() == 0:
				sum_of_counter_benches.append(int(new_num_node.text))
					
			#var curr_next_num_array: Array[int] = []
			
			#print_debug("Current sum of counters for benches :" + str(sum_of_counter_benches))
			#print_debug("CURRENT NEW NUM WILL BE CONNECTED TO NEW CONT AT THE LAST NUMBER ON THE BENCHES")
			if sum_of_keys[-1].size() > 1:
				if typeof(currdictionary[sum_of_keys[-1][1]]) != TYPE_STRING:
					sum_of_counter_benches[-1] += 1
					sum_of_keys[-1].pop_front()
			
		elif typeof(currval) == TYPE_DICTIONARY:
			#print_debug("Current val is a dictionary so delving!!")
			if sum_of_counter_benches[-1] == 0:
				sum_of_keys[-1].pop_front()
			sum_of_benches.append(currkey)
			for cb in range(sum_of_counter_benches[-1]):
				sum_of_keys.append(currval.keys())
			continue
		
		sum_of_counter_benches[-1] -= 1
		if sum_of_counter_benches[-1] <= 0:
			#break
			sum_of_keys[-1].pop_front()
			if sum_of_benches.size() == sum_of_counter_benches.size():
				sum_of_benches.pop_back()
			sum_of_counter_benches.pop_back()
			

func pass_through_dict(_currentdict) -> void:
	var currval
	for key1 in _currentdict.keys():
		currval = _currentdict[key1]
		if typeof(currval) == TYPE_STRING:
			pass
