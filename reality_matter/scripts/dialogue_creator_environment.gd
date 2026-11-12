extends Control

const KEY_WORD_CONTAINER = preload("res://scenes/key_word_container.tscn")
@onready var dialogue_container = $HBoxContainer/DialogueContainer

# Called when the node enters the scene tree for the first time.
func _ready():
	var keyword = KEY_WORD_CONTAINER.instantiate()
	dialogue_container.add_child(keyword)
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass
