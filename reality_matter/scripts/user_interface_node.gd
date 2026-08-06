extends Control

@export var dialog_label: Label
@export var option_button_component: PackedScene
@export var button_container: HBoxContainer
@export var slot_scene: PackedScene
@export var item_collection: HBoxContainer

var _current_npc_conversing: StaticBody2D
var _await_user_input: bool = false
var _has_options: bool = false
var _inventory: Inventory

#Here we will hold what the Interface will be able to do
#When created this item gets connected to the user and all the npcs's related
#signals so that when the users picks up an item the Interface gets informed
#and when an npc gets interacted with and starts a conversation we get notified

# Called when the node enters the scene tree for the first time.
func _ready():
	#When ready we find the appropriate items for the job, a label and the
	#button container
	if dialog_label == null:
		dialog_label = find_child("DialogueLabel")
	dialog_label.text = ""
	if button_container == null:
		button_container = find_child("ButtonContainer")
	if item_collection == null:
		item_collection = find_child("ItemCollection")

# Called every frame. '_delta' is the elapsed time since the previous frame.
func _process(_delta):
	#While a conversation is ongoing we need to check if an npc awaits the user
	#to press the interact button to continue the conversation if there are
	#no buttons to press
	if !_await_user_input or _current_npc_conversing == null:
		return
	if !_current_npc_conversing.has_signal("continue_dialogue") or _has_options:
		return
	if Input.is_action_just_pressed("Interact"):
		print_debug("Pressed continue conversation")
		_await_user_input = false
		_current_npc_conversing.emit_signal("continue_dialogue")

#We should make a function that when called it connects a characters add item
#signal to a function we make that adds an item's graphic to the inventory
func connect_player_adding_item(player: CharacterBody2D) -> void:
	if !player.has_signal("add_item"):
		return
	player.add_item.connect(_make_item_appear_on_onventory)

#Here we should have the function that adds the graphic of an item to the
#inventory
#NOT CURRENTLY MADE
func _make_item_appear_on_onventory(item_instance: Item) -> void:
	print_debug("Item " + str(item_instance.name) + " added to inventory")

#Here the interface connects to an npc's needed signals that: initiate a dialog
#end the dialogue, show the dialogue's next text, adds the user's options
#and await for the user to press something to continue
func connect_characters_dialogues(npc: StaticBody2D) -> void:
	if !npc.has_signal("initiate_dialogue") or !npc.has_signal("end_dialogue") or !npc.has_signal("show_dialogue_text") or !npc.has_signal("await_user_input") or !npc.has_signal("add_options"):
		return
	npc.initiate_dialogue.connect(_begin_dialogue_routine)
	npc.end_dialogue.connect(_end_dialogue_routine)
	npc.show_dialogue_text.connect(_write_dialogue_text_to_label)
	npc.await_user_input.connect(_wait_for_user_input)
	npc.add_options.connect(_create_options)

#Here we should have a function for the dialogue begin, we keep the npc
#currently conversing for the other functions
func _begin_dialogue_routine(npc: StaticBody2D) -> void:
	_current_npc_conversing = npc

#Here we empty the variable that holds the currently conversing character when
#the dialogue ends
func _end_dialogue_routine() -> void:
	_current_npc_conversing = null
	_write_dialogue_text_to_label("")

#Here we write the text for the currently conversing npc's line
func _write_dialogue_text_to_label(text: String) -> void:
	dialog_label.text = text

#Here we get informed by the character when they need an input from the user
func _wait_for_user_input() -> void:
	_await_user_input = true

#Here we should have a function to create buttons for options given, the buttons
#should have functionality that when pressed continues the dialogue. We create
#a button from an already set up one give it a number for the option held
#give it text that contain the thing the user would say, give it funcitonality
#and then add it as a child to the button container that aligns the buttons
func _create_options(options: Dictionary, num: int):
	var button: Button
	_has_options = true
	var i: int = 1
	for op in options:
		button = option_button_component.instantiate()
		button.text = options[op].trim_suffix("#"+str(num))
		button.pressed.connect(_option_button_pressed.bind(i))
		button_container.add_child(button)
		i += 1

#This is the function that the buttons get when they are created. The button
#holds a number that signifies the option which we inform the character that
#the user opted for, we disconenct all the buttons currently in the button
#container so that they don't hold any memory and then we delete them.
#Then we continue the dialogue
func _option_button_pressed(button_num: int):
	for child in button_container.get_children():
		if !child.has_signal("pressed"):
			continue
		if child.pressed.is_connected(_option_button_pressed):
			child.pressed.disconnect(_option_button_pressed)
		child.queue_free()
	_await_user_input = false
	if _current_npc_conversing!= null:
		_current_npc_conversing.emit_signal("continue_dialogue",button_num)
		_has_options = false

func receive_inventory(inventory_instance: Inventory):
	_inventory = inventory_instance
	if _inventory.has_signal("inventory_changed"):
		_inventory.inventory_changed.connect(_inventory_modified)
	_inventory_modified()

func _inventory_modified():
	print_debug("Inventory changed")
	#clear ui
	for child in item_collection.get_children():
		child.queue_free()
	
	#rebuild
	for slot in _inventory.slots:
		var ui_slot: PanelContainer = slot_scene.instantiate()
		item_collection.add_child(ui_slot)
		if !ui_slot.has_method("set_slot_data"):
			return
			
		ui_slot.set_slot_data(slot)
