extends VBoxContainer

signal option_added()

var parent_keyword: VBoxContainer:
	set(v):
		parent_keyword = v
	get():
		return parent_keyword
var child_keywords: Array[VBoxContainer]
@onready var keyword_label = $KeywordLabel
@onready var key_word = $KeyWord
@onready var key_or_word = $KeyOrWord
@onready var add_option = $AddOption
@onready var option_container = $OptionContainer


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func add_child_option( _ch: VBoxContainer):
	child_keywords.append(_ch)
