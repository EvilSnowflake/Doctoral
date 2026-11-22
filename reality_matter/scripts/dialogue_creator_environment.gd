extends Control

const GAME_THEME: Theme = preload("res://assets/themes/game_theme.tres")
const KEY_WORD_CONTAINER = preload("res://scenes/key_word_container.tscn")
const KEYWORD_CONNECTOR = preload("res://scenes/keyword_connector.tscn")
const KEYWORDVBOXNAME = "KeywordVBOX"
const KEYWORDLINENAME = "LineHBOX"

var lines2d_array: Array[Line2D] = []
var base_color_number: Array[int] = [0,0,0]
var increment: float = 16

@onready var dialogues_hbox: HBoxContainer = %DialoguesHBOX
@onready var add_dialogue_button: Button = %AddDialogueButton
@onready var dialoge_creator_camera: Camera2D = %dialoge_creator_camera


# Called when the node enters the scene tree for the first time.
func _ready():
	#var keyword = KEY_WORD_CONTAINER.instantiate()
	#dialogue_container.add_child(keyword)
	add_dialogue_button.pressed.connect(_create_dialogue_instance)
	dialoge_creator_camera.position = add_dialogue_button.position
	
	GAME_THEME.add_type(KEYWORDVBOXNAME)
	GAME_THEME.set_type_variation(KEYWORDVBOXNAME,"VBoxContainer")
	GAME_THEME.set_constant("separation",KEYWORDVBOXNAME,131)
	
	GAME_THEME.add_type(KEYWORDLINENAME)
	GAME_THEME.set_type_variation(KEYWORDLINENAME,"HBoxContainer")
	GAME_THEME.set_constant("separation",KEYWORDLINENAME,64)
	

func _create_dialogue_instance() -> void:
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
	dialogues_hbox.move_child(add_dialogue_button,-1)
	var color_number_array: Array[int] = base_color_number
	color_number_array[0] = int(((dialogues_hbox.get_child_count()-1)*(increment*2))-1)
	add_keyword_instance_to_dialogue(dialogues_hbox.get_child_count()-1,"STARTING CONVERSATION", color_number_array)
	dialoge_creator_camera.position = add_dialogue_button.global_position

func add_keyword_instance_to_dialogue(_dial_num: int, _word: String, _col: Array , _line_num: int = 1, _caller_comp: Node = null, _option_num: int = 0) -> void:
	var new_keyword_cont: VBoxContainer = KEY_WORD_CONTAINER.instantiate()
	new_keyword_cont.current_line = _line_num
	new_keyword_cont.current_dialogue = _dial_num
	new_keyword_cont.keyword_modified.connect(_point_to_child)
	#FIND THE NUMBER FOR THE COLOR HERE
	
	new_keyword_cont.col_number = [_col[0], int(_col[1] + increment + _line_num + _option_num), max(int(increment*+_option_num) - 1,0)]
	#new_keyword_cont.col_number = _col + (increment/_line_num) + ((_option_num+1)/(increment/2))
	#FIND THE NUMBER FOR THE COLOR HERE
	if _option_num != 0:
		new_keyword_cont.option_number = _option_num
	var hbox_child_vbox: VBoxContainer = dialogues_hbox.get_child(_dial_num-1)
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
