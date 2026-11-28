extends Panel

signal option_added(_dial: int, _text: String, _cl: Array ,_lin: int, _par: Node, _opt_num: int)
signal option_removed(num: int, dial: int, line: int)
signal keyword_modified(_dialogue:int, _line: int)
signal opt_num_modified(_ar: Array)

const START: String = "STARTING_CONVERSATION"
const OPTION_CONTAINER = preload("res://scenes/option_container.tscn")

var parent_keyword: Node:
	set(v):
		parent_keyword = v; keyword_modified.emit(current_dialogue, current_line)
	get():
		return parent_keyword
var child_keywords: Array[Node]
var current_line: int = 1:
	set(v):
		current_line = v
	get():
		return current_line
var current_dialogue: int = 1:
	set(v):
		current_dialogue = v
	get():
		return current_dialogue
var option_number: int = 0:
	set(v):
		option_number = v
		if keyword_label != null: modify_keyword_title(keyword_label.text)
	get():
		return option_number
var col_number: Array:
	set(v):
		col_number = v; opt_num_modified.emit(col_number)
	get():
		return col_number
var word_options: Array:
	get():
		return word_options
var keyword_without_opts: bool = false:
	get():
		return keyword_without_opts

@onready var keyword_label = $MarginContainer/VBoxContainer/KeywordLabel
@onready var key_word = $MarginContainer/VBoxContainer/KeyWord
@onready var key_or_word = $MarginContainer/VBoxContainer/KeyOrWord
@onready var add_option = $MarginContainer/VBoxContainer/AddOption
@onready var options_v_box = $MarginContainer/VBoxContainer/OptionsVBox
@onready var key_dropdown = $MarginContainer/VBoxContainer/KeyOrWord/KeyVboxContainer/KeyHboxContainer/KeyDropdown
@onready var word_text_edit = $MarginContainer/VBoxContainer/KeyOrWord/WordTextEdit
@onready var extra_info_h_box = $MarginContainer/VBoxContainer/KeyOrWord/KeyVboxContainer/KeyHboxContainer/ExtraInfoHBox
@onready var quest_info = $MarginContainer/VBoxContainer/KeyOrWord/KeyVboxContainer/QuestInfo
@onready var continue_conv = $MarginContainer/VBoxContainer/ContinueConv
@onready var return_opts = $MarginContainer/VBoxContainer/ReturnOpts

var _vbx_cont: VBoxContainer

# Called when the node enters the scene tree for the first time.
func _ready():
	#_option_container_child =  OPTION_CONTAINER.instantiate()
	add_option.pressed.connect(add_option_to_keyword)
	continue_conv.pressed.connect(continue_conversation_without_opts.bind(true))
	return_opts.pressed.connect(continue_conversation_without_opts.bind(false))
	key_word.item_selected.connect(key_word_is_key_or_word)
	key_dropdown.item_selected.connect(_on_key_dropdown_index_selected)
	if col_number != null: _apply_style_color(col_number)
	opt_num_modified.connect(_apply_style_color)
	#print_debug(current_line)
	#print_debug(current_dialogue)
	#modify_keyword_title(START)
	_vbx_cont = get_child(0).get_child(0)
	_vbx_cont.resized.connect(_apply_resize)

func _process(_delta):
	pass
	#size = get_child(0).size

func _apply_resize() -> void:
	custom_minimum_size.x = _vbx_cont.size.x + 8
	custom_minimum_size.y = _vbx_cont.size.y + 8

func add_child_keyword( _ch: Node) -> void:
	child_keywords.append(_ch)

func modify_keyword_title(_text: String) -> void:
	if _text != "" and _text != START: _text = _text + "#" + str(current_line-1)
	keyword_label.text = _text 
	#if option_number != 0:
		#var parts = keyword_label.text.split("#")
		#if parts.size() > 1:
			#parts[-1] = str(option_number)
			#keyword_label.text = "#".join(parts)
		#elif _text != "": keyword_label.text = keyword_label.text+"#"+str(option_number)
		##keyword_label.text = keyword_label.text+"#"+str(option_number)
	
	if _text == START:
		key_word_is_key_or_word(1)
		key_word.hide()

func get_keyword_title() -> String:
	return keyword_label.text

func key_word_is_key_or_word(_ind: int) -> void:
	if _ind == 1 :
		add_option.show()
		continue_conv.show()
		key_or_word.get_child(0).show()
		key_or_word.get_child(1).hide()
		key_word.show()
	elif _ind == 2 : 
		add_option.hide()
		continue_conv.hide()
		key_or_word.get_child(0).hide()
		key_or_word.get_child(1).show()
		key_word.show()
	else :
		add_option.hide()
		continue_conv.hide()
		key_or_word.get_child(0).hide()
		key_or_word.get_child(1).hide()

func add_option_to_keyword() -> Node:
	if continue_conv.visible == true:
		continue_conv.hide()
	var new_option: Node = OPTION_CONTAINER.instantiate()
	options_v_box.add_child(new_option)
	new_option.get_child(0).text = new_option.get_child(0).text.replace("1",str(options_v_box.get_child_count()))
	new_option.get_child(2).pressed.connect(remove_child_option.bind(options_v_box.get_child_count()-1))
	option_added.emit(current_dialogue,"", col_number ,current_line+1,self,options_v_box.get_child_count())
	var option_wrd: TextEdit = new_option.get_node("OptionWord")
	option_wrd.text_changed.connect(on_option_word_text_changed.bind(options_v_box.get_child_count()))
	word_options.append(option_wrd)
	return option_wrd
	#keyword_modified.emit(current_dialogue, current_line)

func continue_conversation_without_opts(_is_it: bool) -> void:
	if _is_it:
		add_option.hide()
		continue_conv.hide()
		options_v_box.hide()
		option_added.emit(current_dialogue,word_text_edit.text, col_number ,current_line+1,self)
		word_text_edit.text_changed.connect(on_option_word_text_changed.bind(0))
		return_opts.show()
	else :
		if !remove_child_option(0): return
		add_option.show()
		continue_conv.show()
		options_v_box.show()
		word_text_edit.disconnect("text_changed",on_option_word_text_changed)
		return_opts.hide()
	keyword_without_opts = _is_it

func remove_child_option(_ch_num: int) -> bool:
	#print_debug(_ch_num)
	#print_debug(child_keywords)
	var has_ch: bool = child_keywords[_ch_num].child_keywords.size() > 0
	if has_ch:
		print_debug("OPTIONS HAS CHILDREN, YOU CANT DELETE IT!")
		return false
	var counter: int = 0
	var counter_name: int = 0
	var options_ch: Array = options_v_box.get_children()
	var temp_color: Array = []
	var color_to_be: Array = []
	for i in range(child_keywords.size()):
		counter += 1
		if counter == _ch_num+1:
			if counter < child_keywords.size(): temp_color = child_keywords[i].col_number
			continue
		counter_name += 1
		if temp_color != []:
			color_to_be = temp_color
			temp_color = child_keywords[i].col_number
			child_keywords[i].col_number = color_to_be
		var opt_child_lb: Label = options_ch[i].get_child(0)
		var opt_child_rb: Button = options_ch[i].get_child(2)
		var option_wrd: TextEdit = options_ch[i].get_child(1)
		opt_child_lb.text = "Option " + str(counter_name)
		opt_child_rb.disconnect("pressed",remove_child_option)
		opt_child_rb.pressed.connect(remove_child_option.bind(counter_name-1))
		
		option_wrd.disconnect("text_changed",on_option_word_text_changed)
		option_wrd.text_changed.connect(on_option_word_text_changed.bind(counter_name))
		child_keywords[i].option_number = counter_name
		#var ch_title_text: String = child_keywords[i].get_keyword_title()
		#if ch_title_text == "": continue
		#var title_splt = ch_title_text.split("#")
		#title_splt[-1] = str(counter_name)
		#child_keywords[i].modify_keyword_title("#".join(title_splt))
	#for wrdopt in word_options:
	#	print_debug(wrdopt.text)
	if child_keywords.size() == 1:
		continue_conv.show()
	word_options.pop_at(_ch_num)
	if options_v_box.visible: options_v_box.get_child(_ch_num).queue_free()
	child_keywords.pop_at(_ch_num).queue_free()
	option_removed.emit(_ch_num,current_dialogue,current_line)
	keyword_modified.emit(current_dialogue, current_line)
	return true

func _on_key_dropdown_index_selected(_ind: int):
	match _ind:
		0:
			quest_info.hide()
			extra_info_h_box.hide()
		1:
			quest_info.show()
			extra_info_h_box.hide()
		2:
			quest_info.show()
			extra_info_h_box.show()
		3:
			quest_info.hide()
			extra_info_h_box.hide()
		4:
			quest_info.hide()
			extra_info_h_box.hide()
		5:
			quest_info.hide()
			extra_info_h_box.hide()

func on_option_word_text_changed(_option_num: int):
	if _option_num != 0:
		var option_word: TextEdit = options_v_box.get_child(_option_num-1).get_node("OptionWord")
		#print_debug(option_word.text + " # " + str(_option_num))
		#child_keywords[_option_num-1].modify_keyword_title(option_word.text + "#" + str(_option_num))
		child_keywords[_option_num-1].modify_keyword_title(option_word.text)
	else :
		child_keywords[0].modify_keyword_title(word_text_edit.text)

func _apply_style_color(_col: Array) -> void:
	if _col.size() < 3 : return
	var stl: StyleBoxFlat = StyleBoxFlat.new()
	var stl2: StyleBoxFlat = StyleBoxFlat.new()
	stl.bg_color = Color(_col[0]/255.0,_col[1]/255.0,_col[2]/255.0)
	stl2.bg_color = Color(_col[0]/255.0,_col[1]/255.0,_col[2]/255.0,0.6)
	keyword_label.add_theme_stylebox_override("normal", stl)
	add_theme_stylebox_override("panel", stl2)

func is_it_word() -> bool:
	if !key_word.visible:
		if keyword_label.text == START: return true
		else: return false
	if key_word.get_selected_id() == 1: return true
	else: return false

func get_word_text() -> String:
	if !word_text_edit.visible: return ""
	return word_text_edit.text

func get_key_information() -> Array:
	var infoArr: Array = []
	if key_word.get_selected_id() == 1 or key_word.get_selected_id() == 0: return infoArr
	var keytype: String = key_dropdown.get_item_text(key_dropdown.get_selected_id())
	infoArr.append(keytype.replace(" ","_"))
	if extra_info_h_box.visible:
		infoArr[-1] = infoArr[-1]+"_"+extra_info_h_box.get_child(1).text
	if quest_info.visible and quest_info.text != "":
		infoArr.append("QUEST_"+quest_info.text)
	return infoArr

func modify_word_text(_text: String) -> void:
	if word_text_edit.visible == false: return
	word_text_edit.text = _text
	if keyword_without_opts: on_option_word_text_changed(0)

func find_and_modify_key_dropdown_based_on_text(_item_text: String) -> void:
	var keys: int = key_dropdown.item_count
	#print_debug(keys)
	_item_text = _item_text.replace(" ", "_")
	for i in range(keys):
		var curr_item: String = key_dropdown.get_item_text(i).replace(" ", "_")
		#print_debug(curr_item)
		if curr_item == _item_text: 
			key_dropdown.select(i)
			_on_key_dropdown_index_selected(i)
			return
	print_debug("FOUND NONE")
	#NO BATTLE??

func fill_extra_info(_extra_text: String, quest_text: String) -> void:
	_extra_text = _extra_text.split("_")[-1]
	extra_info_h_box.get_child(1).text = _extra_text
	quest_text = quest_text.split("_")[-1]
	quest_info.text = quest_text

func select_key_or_word(_indx: int) -> void:
	if _indx <= key_word.item_count: 
		key_word.select(_indx)
		key_word_is_key_or_word(_indx)
