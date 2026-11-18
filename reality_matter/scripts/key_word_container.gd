extends VBoxContainer

signal option_added()
signal option_removed(num: int, dial: int, line: int)
signal keyword_modified(_dialogue:int, _line: int)

const START: String = "STARTING CONVERSATION"

var parent_keyword: VBoxContainer:
	set(v):
		parent_keyword = v; keyword_modified.emit(current_dialogue, current_line)
	get():
		return parent_keyword
var child_keywords: Array[VBoxContainer]
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

@onready var keyword_label = $KeywordLabel
@onready var key_word = $KeyWord
@onready var key_or_word = $KeyOrWord
@onready var add_option = $AddOption
@onready var options_v_box = $OptionsVBox
@onready var key_dropdown = $KeyOrWord/KeyVboxContainer/KeyHboxContainer/KeyDropdown
@onready var extra_info_h_box = $KeyOrWord/KeyVboxContainer/KeyHboxContainer/ExtraInfoHBox
@onready var quest_info = $KeyOrWord/KeyVboxContainer/QuestInfo

var _option_container_child: Node

# Called when the node enters the scene tree for the first time.
func _ready():
	_option_container_child = options_v_box.get_child(0).duplicate()
	options_v_box.get_child(0).queue_free()
	add_option.pressed.connect(add_option_to_keyword)
	key_word.item_selected.connect(_key_word_is_key_or_word)
	key_dropdown.item_selected.connect(_on_key_drpodown_index_selected)
	#print_debug(current_line)
	#print_debug(current_dialogue)
	#modify_keyword_title(START)


func add_child_keyword( _ch: VBoxContainer) -> void:
	child_keywords.append(_ch)

func modify_keyword_title(_text: String) -> void:
	keyword_label.text = _text
	if _text == START:
		_key_word_is_key_or_word(1)
		key_word.hide()

func get_keyword_title() -> String:
	return keyword_label.text

func _key_word_is_key_or_word(_ind: int) -> void:
	if _ind == 1 :
		add_option.show()
		key_or_word.get_child(0).show()
		key_or_word.get_child(1).hide()
		key_word.show()
	elif _ind == 2 : 
		add_option.hide()
		key_or_word.get_child(0).hide()
		key_or_word.get_child(1).show()
		key_word.show()
	else :
		add_option.hide()
		key_or_word.get_child(0).hide()
		key_or_word.get_child(1).hide()

func add_option_to_keyword() -> void:
	var new_option: Node = _option_container_child.duplicate()
	options_v_box.add_child(new_option)
	new_option.get_child(0).text = new_option.get_child(0).text.replace("1",str(options_v_box.get_child_count()))
	new_option.get_child(2).pressed.connect(remove_child_option.bind(options_v_box.get_child_count()-1))
	option_added.emit(current_dialogue,"",current_line+1,self)
	var option_wrd: TextEdit = new_option.get_node("OptionWord")
	option_wrd.text_changed.connect(_on_option_word_text_changed.bind(options_v_box.get_child_count()))
	#keyword_modified.emit(current_dialogue, current_line)
	#TEXT NOT SHOWN

func remove_child_option(_ch_num: int) -> void:
	#print_debug(_ch_num)
	var has_ch: bool = child_keywords[_ch_num].child_keywords.size() > 0
	if has_ch:
		print_debug("OPTIONS HAS CHILDREN, YOU CANT DELETE IT!")
		return
	var counter: int = 0
	var counter_name: int = 0
	#for ch in options_v_box.get_children():
		#counter += 1
		#if counter == _ch_num+1:
			#continue
		#counter_name += 1
		#var child_lb: Label = ch.get_child(0)
		#var child_rb: Button = ch.get_child(2)
		#child_lb.text = "Option " + str(counter_name)
		#child_rb.disconnect("pressed",remove_child_option)
		#child_rb.pressed.connect(remove_child_option.bind(counter_name-1))
	#options_v_box.get_child(_ch_num).queue_free()
	#child_keywords.pop_at(_ch_num).queue_free()
	#counter = 0
	#counter_name = 0
	var options_ch: Array = options_v_box.get_children()
	for i in range(child_keywords.size()):
		counter += 1
		if counter == _ch_num+1:
			continue
		counter_name += 1
		var opt_child_lb: Label = options_ch[i].get_child(0)
		var opt_child_rb: Button = options_ch[i].get_child(2)
		var option_wrd: TextEdit = options_ch[i].get_child(1)
		opt_child_lb.text = "Option " + str(counter_name)
		opt_child_rb.disconnect("pressed",remove_child_option)
		opt_child_rb.pressed.connect(remove_child_option.bind(counter_name-1))
		
		option_wrd.disconnect("text_changed",_on_option_word_text_changed)
		option_wrd.text_changed.connect(_on_option_word_text_changed.bind(counter_name))
		var ch_title_text: String = child_keywords[i].get_keyword_title()
		if ch_title_text == "": continue
		var title_splt = ch_title_text.split("#")
		title_splt[-1] = str(counter_name)
		child_keywords[i].modify_keyword_title("#".join(title_splt))
	options_v_box.get_child(_ch_num).queue_free()
	child_keywords.pop_at(_ch_num).queue_free()
	
	option_removed.emit(_ch_num,current_dialogue,current_line)
	keyword_modified.emit(current_dialogue, current_line)

func _on_key_drpodown_index_selected(_ind: int):
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

func _on_option_word_text_changed(_option_num: int):
	var option_word: TextEdit = options_v_box.get_child(_option_num-1).get_node("OptionWord")
	#print_debug(option_word.text + " # " + str(_option_num))
	child_keywords[_option_num-1].modify_keyword_title(option_word.text + "#" + str(_option_num))
