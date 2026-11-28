extends Control

const GAME_THEME: Theme = preload("res://assets/themes/game_theme.tres")
const KEY_WORD_CONTAINER = preload("res://scenes/key_word_container.tscn")
const KEYWORD_CONNECTOR = preload("res://scenes/keyword_connector.tscn")
const KEYWORDVBOXNAME = "KeywordVBOX"
const KEYWORDLINENAME = "LineHBOX"
const START = "STARTING_CONVERSATION"

var lines2d_array: Array[Line2D] = []
var base_color_number: Array[int] = [0,0,0]
var increment: float = 16
var add_dialogue_button: Button
var remove_dialogue_button: Button

@onready var dialogues_hbox: HBoxContainer = %DialoguesHBOX
@onready var dialoge_creator_camera: Camera2D = %dialoge_creator_camera
@onready var save_button = $CanvasLayer/SaveButton
@onready var modify_dialogues_buttons = %ModifyDialoguesButtons

#var _test_dict: Dictionary = { "DIALOGUE_1": { "STARTING_CONVERSATION": "Hi#1", "Hi#1": { "Hello there, can you hear me?#2": { "OPTION_1": "Yes hello#2", "OPTION_2": "No I can\'t#2" } }, "Yes hello#2": "ENDING_CONVERSATION", "No I can\'t#2": "BATTLE" } }
var _test_dict: Dictionary = { "DIALOGUE_1": { "STARTING_CONVERSATION": "Hey#1", "Hey#1": { "Is it you?#2": { "OPTION_1": "Yes!#2", "OPTION_2": "No!#2" } }, "Yes!#2": "Oh right, we know so much.#3", "No!#2": "ENDING_CONVERSATION", "Oh right, we know so much.#3": { "How have you been?#4": { "OPTION_1": "Fine.#4", "OPTION_2": "Great!#4" } }, "Fine.#4": "ENDING_CONVERSATION", "Great!#4": "Take this item!#5", "Take this item!#5": "GIVE_ITEM|QUEST_1" }, "DIALOGUE_2": { "STARTING_CONVERSATION": { "Hello#1": { "OPTION_1": "Hey#1", "OPTION_2": "Hi#1" } }, "Hey#1": "Do not talk to me!#2", "Hi#1": { "Nice to meet you#2": { "OPTION_1": "Bye#2", "OPTION_2": "Goodbye#2" } }, "Do not talk to me!#2": "ENDING_CONVERSATION", "Bye#2": "ENDING_CONVERSATION", "Goodbye#2": "ENDING_CONVERSATION" } }

# Called when the node enters the scene tree for the first time.
func _ready():
	#var keyword = KEY_WORD_CONTAINER.instantiate()
	#dialogue_container.add_child(keyword)
	add_dialogue_button = modify_dialogues_buttons.get_child(0)
	remove_dialogue_button = modify_dialogues_buttons.get_child(1)
	add_dialogue_button.pressed.connect(_create_dialogue_instance)
	remove_dialogue_button.pressed.connect(_remove_last_dialogue_instance)
	dialoge_creator_camera.global_position = add_dialogue_button.global_position
	
	GAME_THEME.add_type(KEYWORDVBOXNAME)
	GAME_THEME.set_type_variation(KEYWORDVBOXNAME,"VBoxContainer")
	GAME_THEME.set_constant("separation",KEYWORDVBOXNAME,131)
	
	GAME_THEME.add_type(KEYWORDLINENAME)
	GAME_THEME.set_type_variation(KEYWORDLINENAME,"HBoxContainer")
	GAME_THEME.set_constant("separation",KEYWORDLINENAME,64)
	
	save_button.pressed.connect(_on_save_button_pressed)
	print_debug(_test_dict)
	_setup_previous_dictionary(_test_dict)

func _create_dialogue_instance() -> Node:
	var new_dialogue_vbox: VBoxContainer = VBoxContainer.new()
	new_dialogue_vbox.custom_minimum_size.x = 584.0
	new_dialogue_vbox.theme = GAME_THEME
	new_dialogue_vbox.theme_type_variation = KEYWORDVBOXNAME
	dialogues_hbox.add_child(new_dialogue_vbox)
	var new_dialogue_num_label: Label = Label.new()
	new_dialogue_num_label.text = "DIALOGUE " + str(dialogues_hbox.get_child_count()-1)
	new_dialogue_num_label.custom_minimum_size.y = 64
	new_dialogue_num_label.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	new_dialogue_num_label.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	new_dialogue_num_label.add_theme_font_size_override("font_size",44)
	new_dialogue_num_label.add_theme_color_override("font_color", Color.BLACK)
	var new_label_stylebox : StyleBoxFlat = StyleBoxFlat.new()
	new_label_stylebox.bg_color = Color.WHITE
	new_dialogue_num_label.add_theme_stylebox_override("normal",new_label_stylebox)
	new_dialogue_vbox.add_child(new_dialogue_num_label)
	dialogues_hbox.move_child(modify_dialogues_buttons,-1)
	var color_number_array: Array[int] = base_color_number
	color_number_array[0] = int(((dialogues_hbox.get_child_count()-1)*(increment*2))-1)
	add_keyword_instance_to_dialogue(dialogues_hbox.get_child_count()-1,START, color_number_array)
	dialoge_creator_camera.position = add_dialogue_button.global_position
	if !remove_dialogue_button.visible:
		remove_dialogue_button.show()
	return new_dialogue_vbox

func _remove_last_dialogue_instance() -> void:
	if dialogues_hbox.get_child_count() == 2:
		remove_dialogue_button.hide()
	dialogues_hbox.get_child(-2).queue_free()

func add_keyword_instance_to_dialogue(_dial_num: int, _word: String, _col: Array , _line_num: int = 1, _caller_comp: Node = null, _option_num: int = 0) -> void:
	var new_keyword_cont: Node = KEY_WORD_CONTAINER.instantiate()
	new_keyword_cont.current_line = _line_num
	new_keyword_cont.current_dialogue = _dial_num
	new_keyword_cont.keyword_modified.connect(_point_to_child)
	#FIND THE NUMBER FOR THE COLOR HERE
	
	new_keyword_cont.col_number = [_col[0], int(_col[1] + increment + _line_num + _option_num), max(int(increment*+_option_num) - 1,0)]
	#new_keyword_cont.col_number = _col + (increment/_line_num) + ((_option_num+1)/(increment/2))
	#FIND THE NUMBER FOR THE COLOR HERE
	if _option_num != 0:
		new_keyword_cont.option_number = _option_num
	var hbox_child_vbox: Node = dialogues_hbox.get_child(_dial_num-1)
	if hbox_child_vbox.get_child_count() == _line_num:
		var new_line: HBoxContainer = HBoxContainer.new()
		new_line.theme = GAME_THEME
		new_line.theme_type_variation = KEYWORDLINENAME
		new_line.alignment = BoxContainer.ALIGNMENT_CENTER
		dialogues_hbox.get_child(_dial_num-1).add_child(new_line)
	dialogues_hbox.get_child(_dial_num-1).get_child(_line_num).add_child(new_keyword_cont)
	new_keyword_cont.modify_keyword_title(_word)
	new_keyword_cont.option_added.connect(add_keyword_instance_to_dialogue)
	if _caller_comp == null: return
	var kw_connect: Line2D = KEYWORD_CONNECTOR.instantiate()
	lines2d_array.append(kw_connect)
	add_child(kw_connect)
	kw_connect.set_point_node(_caller_comp, new_keyword_cont)
	_caller_comp.add_child_keyword(new_keyword_cont)
	new_keyword_cont.parent_keyword = _caller_comp
	
	#CHECK IF THE POSITION OF THIS KEYWORD IN THE LINE IS CORRECT
	#WHLIE THE POSITION IS INCORRECT MOVE THE CHILD
	var caller_index: int = _caller_comp.get_index()
	var par_ln: Node = new_keyword_cont.get_parent()
	var index_to_go: int = new_keyword_cont.get_index()
	while index_to_go > 0:
		var other_ch: Node = par_ln.get_child(index_to_go - 1)
		var other_prnt: Node = other_ch.parent_keyword
		if other_prnt.get_index() > caller_index : index_to_go -= 1
		else: break
	if index_to_go != new_keyword_cont.get_index(): par_ln.move_child(new_keyword_cont,index_to_go);
	#Here we will instantiate a new keyword that is either the beginning of the
	#conversation where the name of the keyword will be STARTING CONVERSATION
	#or the name will be linked to an option of a parent keyword. I need to know
	#in which dialogue vbox the keyword will be added and then I need to check
	#if that dialogvbox has the correct amount of lines for me to add the
	#keyword to that numbered line, otherwise I should create a new one at the
	#end.

func _point_to_child(_dl: int, _ln: int):
	var deleted_line: int = -1
	for l in range(lines2d_array.size()):
		if lines2d_array[l] == null:
			deleted_line = l
			continue
		lines2d_array[l].fix_both_points()
	if deleted_line != -1:
		lines2d_array.pop_at(deleted_line)

func _on_save_button_pressed() -> void:
	print_debug("PRESSED SAVE!")
	#Here we will gather all the dialogue children and the keywords that they
	#contain and create a dictionary that has them so that it can be used in
	#the game creator.
	var created_dictionary: Dictionary = {}
	print_debug("There are " + str(dialogues_hbox.get_child_count()-1) + " dialogues")
	var dials: Array = dialogues_hbox.get_children()
	dials.pop_back()
	for i in range(dials.size()):
		var curr_dial_key: String = "DIALOGUE_"+str(i+1)
		created_dictionary[curr_dial_key] = {}
		print_debug("There are " + str(dials[i].get_child_count()-1) + " lines")
		var lnz: Array = dials[i].get_children()
		lnz.pop_front()
		for j in range(lnz.size()):
			print_debug("There are " + str(lnz[j].get_child_count()) + " keywords")
			var kwrds: Array = lnz[j].get_children()
			for k in range(kwrds.size()):
				var current_word: Node = kwrds[k]
				var curr_word_title: String = current_word.get_keyword_title()
				if curr_word_title == "":
					print_debug("This keyword does not have a base word!")
					continue
				created_dictionary[curr_dial_key][curr_word_title] = {}
				var is_word: bool = current_word.is_it_word()
				print_debug("Is this keyword a word: " + str(is_word))
				if is_word:
					var word_txt: String = current_word.get_word_text()
					print_debug(word_txt)
					if word_txt == "": print_debug("This word is empty!"); continue
					else:
						word_txt = word_txt + "#" + str(j+1)
						
						if kwrds[k].keyword_without_opts:
							created_dictionary[curr_dial_key][curr_word_title] = word_txt
							continue
						
						created_dictionary[curr_dial_key][curr_word_title][word_txt] = {}
						var word_opts: Array = current_word.word_options
						for o in range(word_opts.size()):
							var current_opt_text: String = word_opts[o].text + "#" + str(j+1)
							print_debug(current_opt_text)
							created_dictionary[curr_dial_key][curr_word_title][word_txt]["OPTION_"+str(o+1)] = current_opt_text
				else:
					var key_info: Array = current_word.get_key_information()
					print_debug(key_info)
					if key_info == []: continue
					var key_txt = "|".join(key_info)
					created_dictionary[curr_dial_key][curr_word_title] = key_txt
	print_debug(created_dictionary)

func _setup_previous_dictionary(_dict: Dictionary) -> void:
	for i in range(_dict.keys().size()):
		var new_dial: Node = _create_dialogue_instance()
		var dial_dets: Dictionary = _dict[_dict.keys()[i]]
		var prev_line: int = 0
		var counter_line: int = 0
		for j in range(dial_dets.keys().size()):
			var curr_key: String = dial_dets.keys()[j]
			var curr_val = dial_dets[curr_key]
			print_debug(curr_key)
			print_debug(curr_val)
			if curr_key == START:
				#FIRST LINE FIRST KEYWORD IS THE START
				var start_keyword: Node = new_dial.get_child(1).get_child(0)
				if curr_val is String:
					start_keyword.continue_conversation_without_opts(true)
					start_keyword.modify_word_text(curr_val.split("#")[0])
				else:
					var opts_key: String = curr_val.keys()[0]
					var curr_opts: Dictionary = curr_val[opts_key]
					start_keyword.modify_word_text(opts_key.split("#")[0])
					#print_debug(curr_opts)
					for opt_dict in curr_opts:
						var curr_opt_wrd: Node = start_keyword.add_option_to_keyword()
						curr_opt_wrd.text = curr_opts[opt_dict].split("#")[0]
						var opt_num: int = int(opt_dict.split("_")[1])
						start_keyword.on_option_word_text_changed(opt_num)
			else:
				#AFTER THAT WE HAVE TO SEARCH ALL OTHER KEYWORDS AND ADD THEM
				#IN ORDER TO THE CORRECT LINE
				var curr_line: int = int(curr_key.split("#")[1]) + 1
				if curr_line != prev_line: prev_line = curr_line; counter_line = 0
				var curr_keyword: Node = new_dial.get_child(curr_line).get_child(counter_line)
				#print_debug(curr_keyword.get_keyword_title())
				if curr_val is String:
					if curr_val.split("#").size() > 1:
						curr_keyword.select_key_or_word(1)
						curr_keyword.continue_conversation_without_opts(true)
						curr_keyword.modify_word_text(curr_val.split("#")[0])
					else:
						curr_keyword.select_key_or_word(2)
						var keyword_key_values: Array = curr_val.split("|")
						var keyword_key: String = keyword_key_values[0]
						var keyword_extra: String = ""
						var keyword_quest: String = ""
						if keyword_key.begins_with("TAKE_ITEM"):
							var keyword_key_split: Array = keyword_key.split("_")
							keyword_extra = keyword_key_split[2]
							keyword_key = keyword_key_split[0]+"_"+keyword_key_split[1]
						if keyword_key_values.size() > 1:
							keyword_quest = keyword_key_values[1]
						curr_keyword.find_and_modify_key_dropdown_based_on_text(keyword_key)
						curr_keyword.fill_extra_info(keyword_extra, keyword_quest)
				else:
					curr_keyword.select_key_or_word(1)
					var opts_key: String = curr_val.keys()[0]
					var curr_opts: Dictionary = curr_val[opts_key]
					curr_keyword.modify_word_text(opts_key.split("#")[0])
					#print_debug(curr_opts)
					for opt_dict in curr_opts:
						var curr_opt_wrd: Node = curr_keyword.add_option_to_keyword()
						curr_opt_wrd.text = curr_opts[opt_dict].split("#")[0]
						var opt_num: int = int(opt_dict.split("_")[1])
						curr_keyword.on_option_word_text_changed(opt_num)
				counter_line += 1
