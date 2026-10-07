extends Control

#This script contains the logic of the user's interface component of the scene
#Here the character can show any words that their dialogue contains, create
#buttons for any options that dialogue may allow and show the inventory of
#the user as item slots

## This variable points to the label showing the dialogue currently being said
@export var dialog_label: Label
## This variable should contain a scene for the options the user can press
## after the character says a word
@export var option_button_component: PackedScene
## This variable shows where the button container resides so that we can add
## the available options there
@export var button_container: HBoxContainer
## This variable should contain the item slot scene
@export var slot_scene: PackedScene
## This variable should point to the container that holds the item slots
@export var item_collection: HBoxContainer

## This variable should point to the texture that the item slots need to have
var slot_graphic_resource: Resource

## This variable should hold the current npcs that talks to the user
var _current_npc_conversing: StaticBody2D
## This variable informs us if we need the user to give any inputs by pressing
## a button or choosing an option
var _await_user_input: bool = false
## This variable should be modified by the conversing npc when the current
## word spoken has any options
var _has_options: bool = false
## This variable should contain a reference of the user's current inventory
var _inventory: Inventory
## This variable should have the path to the item's slot graphic 
var _slot_graphic: String = "res://assets/sprites/uielements/TinySquareBlueButton.png"
## This variable should inform the item slot about the margin that holds the
## item's icon
var _slot_margin: Vector4 = Vector4(8.0,8.0,8.0,8.0)
var _mouse_padding: Vector2 = Vector2(16.0,16.0)
var _label_follow_mouse: bool = false
var _tooltip_label: String = "res://scenes/tooltip.tscn"
var _mLabel: Label
var _pause_menu_scene: String = "res://scenes/pause_menu.tscn"
var _pause: Control

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
	slot_graphic_resource = load(_slot_graphic)
	var tooltip_resource = load(_tooltip_label)
	_mLabel = tooltip_resource.instantiate()
	get_child(0).add_child(_mLabel)
	_mLabel.hide()
	

# Called every frame. '_delta' is the elapsed time since the previous frame.
func _process(_delta):
	#While a conversation is ongoing we need to check if an npc awaits the user
	#to press the interact button to continue the conversation if there are
	#no buttons to press
	#$CanvasLayer/TestPanel.position = get_viewport().get_mouse_position()

	if _label_follow_mouse:
		_mLabel.position = get_viewport().get_mouse_position() + _mouse_padding
	if Input.is_action_just_pressed("Escape"):
		_perform_pause()
	if !_await_user_input or _current_npc_conversing == null:
		return
	if !_current_npc_conversing.has_signal("continue_dialogue") or _has_options:
		return
	if Input.is_action_just_pressed("Interact"):
		_await_user_input = false
		_current_npc_conversing.emit_signal("continue_dialogue")

#We should make a function that when called it connects a characters add item
#signal to a function we make that adds an item's graphic to the inventory
func connect_player_adding_item(player: CharacterBody2D) -> void:
	if !player.has_signal("add_item"):
		return
	player.add_item.connect(_make_item_appear_on_inventory)

#Here we should have the function that adds the graphic of an item to the
#inventory
#NOT CURRENTLY MADE
func _make_item_appear_on_inventory(item_instance: Item) -> void:
	print_debug("Item " + str(item_instance.name) + " added to inventory")

## Here the interface connects to an npc's needed signals that: initiate a dialog
## end the dialogue, show the dialogue's next text, adds the user's options
## and await for the user to press something to continue
func connect_characters_dialogues(npc: StaticBody2D) -> void:
	if !npc.has_signal("initiate_dialogue") or !npc.has_signal("end_dialogue") or !npc.has_signal("show_dialogue_text") or !npc.has_signal("await_user_input") or !npc.has_signal("add_options"):
		return
	npc.initiate_dialogue.connect(_begin_dialogue_routine)
	npc.end_dialogue.connect(_end_dialogue_routine)
	npc.show_dialogue_text.connect(_write_dialogue_text_to_label)
	npc.await_user_input.connect(_wait_for_user_input)
	npc.add_options.connect(_create_options)

## Here we should have a function for the dialogue begin, we keep the npc
## currently conversing for the other functions
func _begin_dialogue_routine(npc: StaticBody2D) -> void:
	_current_npc_conversing = npc

## Here we empty the variable that holds the currently conversing character when
## the dialogue ends
func _end_dialogue_routine() -> void:
	_current_npc_conversing = null
	_write_dialogue_text_to_label("")

## Here we write the text for the currently conversing npc's line
func _write_dialogue_text_to_label(text: String) -> void:
	dialog_label.text = text

## Here we get informed by the character when they need an input from the user
func _wait_for_user_input() -> void:
	_await_user_input = true

## Here we should have a function to create buttons for options given, the buttons
## should have functionality that when pressed continues the dialogue. We create
## a button from an already set up one give it a number for the option held
## give it text that contain the thing the user would say, give it funcitonality
## and then add it as a child to the button container that aligns the buttons
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

## This is the function that the buttons get when they are created. The button
## holds a number that signifies the option which we inform the character that
## the user opted for, we disconenct all the buttons currently in the button
## container so that they don't hold any memory and then we delete them.
## Then we continue the dialogue
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

## This function should be used to acquire a reference to the instance of the 
## users inventory
func receive_inventory(inventory_instance: Inventory):
	_inventory = inventory_instance
	if _inventory.has_signal("inventory_changed"):
		_inventory.inventory_changed.connect(_inventory_modified)
	_inventory_modified()

## This function should be called whenever the user's inventory get's modified
## I clear any item slots inserted and then add them back in by setting their
## item data to what they should contain while also changing their graphic
## and slot margins
func _inventory_modified():
	#clear ui
	for child in item_collection.get_children():
		child.queue_free()
	
	#rebuild
	for slot: InventorySlot in _inventory.slots:
		var ui_slot: PanelContainer = slot_scene.instantiate()
		item_collection.add_child(ui_slot)
		if !ui_slot.has_method("set_slot_data") or !ui_slot.has_method("set_custom_min_max_size") or !ui_slot.has_method("set_panel_texture"):
			return
		ui_slot.set_slot_data(slot)
		ui_slot.set_panel_texture(slot_graphic_resource,_slot_margin)
		ui_slot.mouse_entered.connect(set_text_on_mouse.bind(slot.item))
		ui_slot.mouse_exited.connect(clear_text_on_mouse)

## This function should be connected to each inventory slot so that when the user inserts their
## their cursor on it, a tooltip appears which contains information about the item inside the
## element if it exists. It requires an item resource as input to get all the information from
func set_text_on_mouse(itm: Item) -> void:
	if itm != null:
		_mLabel.show()
		var text_t: String = "ID: %s \nNAME: %s \nDESCRIPTION: %s \nTYPE: %s" %[itm.id, itm.name, itm.description, itm.item_type]
		_mLabel.text = text_t
		_label_follow_mouse = true

## This function should be connected to each inventory slot so that when the user exits the element
## with their cursor then the tooltip which informs the user of the item inside the slot, is hidden
func clear_text_on_mouse() -> void:
	_mLabel.text = ""
	_label_follow_mouse = false
	_mLabel.hide()

## This function instantiates the pause menu and adds it to the canvas layer. It is used by another
## script so that the pause menu is created last and that way the user can insteract with it
## wherever they are on the scene
func add_pause() -> void:
	var pause_resource = load(_pause_menu_scene)
	_pause = pause_resource.instantiate()
	get_child(0).add_child(_pause)
	_pause.hide()
	if _pause.has_method("get_resume_button"):
		var res_button: Button = _pause.get_resume_button()
		res_button.pressed.connect(_perform_pause)
	if _pause.has_method("get_exit_button"):
		var ex_button: Button = _pause.get_exit_button()
		ex_button.pressed.connect(close_game)

## This function is responsible for pausing and resuming the game. Depending on the status of the
## game it either shows the pause menu and stops the appropriate processes or it hides the pause
## menu and resumes those processes
func _perform_pause() -> void:
	if get_tree().paused == false:
		_pause.show()
		get_tree().paused = true
	else:
		_pause.hide()
		get_tree().paused = false

func close_game() -> void:
	get_tree().quit()
