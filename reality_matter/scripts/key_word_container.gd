extends VBoxContainer

signal option_added()
signal option_removed(num: int, dial: int, line: int)
signal keyword_modified()

const START: String = "STARTING CONVERSATION"

var parent_keyword: VBoxContainer:
	set(v):
		parent_keyword = v
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

var _option_container_child: Node

# Called when the node enters the scene tree for the first time.
func _ready():
	_option_container_child = options_v_box.get_child(0).duplicate()
	options_v_box.get_child(0).queue_free()
	add_option.pressed.connect(add_option_to_keyword)
	key_word.item_selected.connect(_key_word_is_key_or_word)
	print_debug(current_line)
	print_debug(current_dialogue)
	#modify_keyword_title(START)


func add_child_keyword( _ch: VBoxContainer) -> void:
	child_keywords.append(_ch)

func modify_keyword_title(_text: String) -> void:
	keyword_label.text = _text
	if _text == START:
		_key_word_is_key_or_word(1)
		key_word.hide()

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

func remove_child_option(_ch_num: int) -> void:
	#print_debug(_ch_num)
	var counter: int = 0
	var counter_name: int = 0
	for ch in options_v_box.get_children():
		counter += 1
		if counter == _ch_num+1:
			continue
		counter_name += 1
		var child_lb: Label = ch.get_child(0)
		var child_rb: Button = ch.get_child(2)
		child_lb.text = "Option " + str(counter_name)
		child_rb.disconnect("pressed",remove_child_option)
		child_rb.pressed.connect(remove_child_option.bind(counter_name-1))
	options_v_box.get_child(_ch_num).queue_free()
	child_keywords.pop_at(_ch_num).queue_free()
	
	option_removed.emit(_ch_num,current_dialogue,current_line)
	
