extends StaticBody2D

#This script gives non player characters the lgoic required to
#converse with the player when interacted with

## This signal is emitted when the interactable component of the
## npc is infront of the player character after they move towards
## it
signal player_collided
## This signal is emitted if they players moves away from the
## character after the interactable component has noticed them
## moving towards it
signal player_left
######NEW SCRIPT
signal interacted(player: CharacterBody2D)
######NEW SCRIPT
## This signal is emitted by the player when they begin interacting
## with the npc, its requires the user as input
signal start_conversation(player: CharacterBody2D)
## This signal is used to give an item to the npc to hold so that
## they can then give it to the player
signal assign_item_to_give(item: Item)
## This signal is emitted from the npc when the dialogue starts
## It takes the npc as an argument which then passes on to the
## User Interface so that it knows which character is conversing
signal initiate_dialogue(npc: StaticBody2D)
## This signal should be emitted when the dialogue between the user
## and the npc ends. It is required so that the UI stops showing the
## dialogue.
signal end_dialogue()
## This signal is used to send the UI the text currently said by
## the character talking.
signal show_dialogue_text(text: String)
## This signal is required to show the user any options given
## with the current conveersation. Th first argument is the
## dictionary containing the options and the second is the
## number of options that we want to show the user
signal add_options(options: Dictionary, num: int)
## The await_user_input signal is emitted when the npc presents
## what thy have to say to the user and any options if any and
## then needs to wait for the user to either pick an option
## or just press a button to continue with the conversation
signal await_user_input()
## After emitting the await user input signal the character then
## waits for the interface to emit the continue_dialogue signal
## so that it can then move on to the next peice of dialogue
signal continue_dialogue()
######NEW SCRIPT
signal engage_battle(char: StaticBody2D, user: CharacterBody2D)
######NEW SCRIPT

## This variable contains the animations for the character as a
## dictionary. It gets filled with tweens that when played should
## animate the character accordingly and the key for each tween
## is the name of the animation for example Idle, Run, Die, etc.
var TweenItems: Dictionary = {}
## This variable should contain any dialogue the character has
## towards the player in dictionary form. The structure of the
## dialogue needs to be: {STARTING DIALOGUE: WORD#1: OPTION_1#1,
## OPTION2#1, OPTION_1#1:WORD#2:OPTION_1#2, OPTION_2#2, OPTION_2#1...
## OPTION_2#2:ENDING_CONVERSATION}
## The character dialogue can have multiple dialogues and the character will
## start from the last dialogue and move on to the next every time the user
## converses with them. The first word should be contained in the STARTING
## DIALOGUE key and the dialogue ends in ENDING DIALOGUE, GIVE ITEM, TAKE ITEM
var CharacterDialogue: Dictionary = {}

#######NEW SCRIPT
@export_category("Stats")
@export var character_name: String = "Default"
@export var character_stats: Combat_Stats
@export var can_combat: bool = false
#######NEW SCRIPT
@export_category("Components")
## This variable should hold a reference to the sprite of the npc
@export var sprite: Sprite2D
## This variable should point to the label that shows informs the
## user that the character can be interacted with
@export var dialogue_label: Label
## This variable should hold the item the character gives to the
## user 
@export var item_to_give: Item

## This variable along with vframes informs the animation and sprite
## how many frames the character sprite file contains
var hFrames: int = 7
## This variable along with hframes informs the animation and sprite
## how many frames the character sprite file contains
var vFrames: int = 5
## This variable shows how big each tile on the world is
var tilesize: int = 64
## This array should contain the name of each animation
var tweenNames: Array[String] = ["IdleTween"]
## This array should contain the type of the animation component
var tweenComps: Array[String] = ["Sprite2D"]
## This array should contain the property type of each animation
var tweenProps: Array[String] = ["frame"]
## This array should hold the starting and ending frame of each
## animation in a vector2i
var tweenChanges: Array[Vector2i] = [Vector2i(0,6)]
## This array should hold the duration for each animation
var tweenDurations: Array[float] = [0.7]
## This variable should contain the number for the option chosen
## for the dialogue when the user presses one
var option_chosen: int

## This variable should contain the path for the character texture
var _texturePath: Resource
## This variable is the text the character shows when we want the
## user to know they can be interacted with.
var _can_interact_text: String = "Press key to interact"
## This variable should contain the which dialogue the character
## is currently in, if it is on 1 then the character uses the
## first dialogue
var _dialogues_num: int
## This variable informs the character that after conversing with
## the user they can move on to the next dialogue if it has more
var _move_on_dialogue: bool = true
########NEW SCRIPT
var _can_battle_text: String = "Press key to begin battle"
########NEW SCRIPT

# Called when the node enters the scene tree for the first time.
func _ready():
	#During the ready function we locate the character's sprite
	#then we set up the character's animations using tweens and
	#the connect the character's signals with the appropriate
	#functions 
	if sprite == null:
		sprite = find_child("Sprite2D")
	if sprite != null:
		_texturePath =  load("res://assets/sprites/characters/Torch_Blue.png")
		add_sprite(_texturePath, sprite)
		sprite.hframes = hFrames
		sprite.vframes = vFrames
		#Create animations
	for i in range(tweenNames.size()):
		var tween = get_tree().create_tween()
		tween.tween_property(get_node(tweenComps[i]),tweenProps[i], tweenChanges[i][1], tweenDurations[i]).from(tweenChanges[i][0])
		tween.set_loops()
		tween.stop()
		TweenItems[tweenNames[i]] = tween
	
	if TweenItems.size() == 1:
		TweenItems[tweenNames[0]].play()
	
	if dialogue_label == null:
		dialogue_label = find_child("DialogueLabel")
	
	player_collided.connect(_on_player_collided_with_char)
	player_left.connect(_on_player_left_char)
	start_conversation.connect(_on_player_start_conversing)
	interacted.connect(_on_player_interacted_with)
	assign_item_to_give.connect(_on_assign_item_to_give)
	continue_dialogue.connect(_on_dialogue_continue)
	_on_player_left_char()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

## This function should be called when we want to add a sprite to the character
## As input it takes a loaded sprite resource and the sprite component of the
## npc
func add_sprite(spritePath: Resource, sprite_comp: Sprite2D = null) -> void:
	if sprite_comp == null and sprite != null:
		sprite.texture = spritePath
		return
	if spritePath != null and sprite_comp != null:
		sprite_comp.texture = spritePath

## This function is used by other scripts to give the npc dialogue. When adding
## the dialogue we search how many dialogues are contained so that we start with
## the last one
func add_dialogue(dial: Dictionary) -> void:
	CharacterDialogue = dial
	_dialogues_num = CharacterDialogue.keys().size()
######NEW SCRIPT
func set_char_name(nm: String) -> void:
	character_name = nm

func set_npc_combat(com_stat: Combat_Stats, combability: bool):
	character_stats = com_stat
	can_combat = combability
######NEW SCRIPT
## This function should be connected to the instance of the player colliding
## with the interactable component of the character
func _on_player_collided_with_char() -> void:
	#print_debug("Colliding player")
	#############NEW SCRIPT
	if can_combat:
		dialogue_label.text= _can_battle_text
		return
	#############NEW SCRIPT
	dialogue_label.text = _can_interact_text

## This function should be connected to the instance of the player leaving the
## collision state of the character's interactable component
func _on_player_left_char() -> void:
	#print_debug("Player left collision")
	dialogue_label.text = ""

## This function can be used to give the character an item that they can then
## pass it on to the player
func _on_assign_item_to_give(item: Item):
	if item != null:
		item_to_give = item

############NEW SCRIPT
func _on_player_interacted_with(player_character: CharacterBody2D) -> void:
	print_debug("Player interacted with me")
	if can_combat:
		print_debug("Begin combat here")
	else:
		_on_player_start_conversing(player_character)
##############NEW SCRIPT

## This function is called when the player starts interaction with the character
## For this type of npcs the interaction involves conversing with the user
## using the User Interface as a way to show their dialogue. THe dialogue can
## involve giving an item, taking items from the user or just showing text
func _on_player_start_conversing(player_character: CharacterBody2D) -> void:
	print_debug("Player " + str(player_character) + " started conversation with current dialogue num : " + str(_dialogues_num))
	initiate_dialogue.emit(self)
	dialogue_label.text = ""
	
	#First we disable the players movement with a signal
	if player_character.has_signal("adjust_moving"):
		player_character.emit_signal("adjust_moving",false)
	
	#Then we assign the first dialogue in the dictionary
	var current_dialogue = CharacterDialogue["Dialogue_"+str(_dialogues_num)]
	var word: String = "STARTING_CONVERSATION"
	var word_to_say: String
	
	#After that we cycle through all the words the character can say with a for
	#loop, the range isn't particularly important, we just have to make sure
	#that the character loops through all the possible words but since
	#there are a lot of options usually the conversation will end much sooner
	#than all the keys in the dictionary dialogue
	for i in range(current_dialogue.keys().size()):
		var curr_word = current_dialogue[word]
		#If the word that the character should say doesn't have any options we
		#either end the conversation, give him an item and then end the conversation
		#or we say that word and move on
		if curr_word is String:
			if curr_word == "ENDING_CONVERSATION":
				#If the current word contains an ENDING CONVERSATION inside
				#we break the conversation
				print_debug("Conversation Ended!")
				break
			elif curr_word == "GIVE_ITEM" and item_to_give != null and player_character.has_signal("add_item"):
				player_character.emit_signal("add_item",item_to_give)
				item_to_give = null
				break
			elif curr_word == "GIVE_ITEM" and item_to_give != null:
				break
			#Also if the dialogue wants the user to give an item we check if the
			#user has the ability to give items and then ask for the spesific
			#item id written in the dialogue. If the user's function returns
			#false the the user didnt have the asked for ite, and if its true
			#he did. Depending on the answer we either move on with the dialogue
			#or we don't
			elif curr_word.begins_with("TAKE_ITEM") and player_character.has_method("give_item"):
				var item_to_take: String = curr_word.trim_prefix("TAKE_ITEM_")
				print_debug("Item to take: " + item_to_take)
				_move_on_dialogue = player_character.give_item(item_to_take)
				#this should try and take the item from the user's interface
				#and if it takes it we move the conversation, otherwise
				#we stay in the same conversation
				break
			#If the dialogue had the prerequisite that the user give an item
			#we give the ability for the user to refuse and if he does we
			#dont continue to the next conversation if we have one
			elif curr_word == "NOT_TAKE_ITEM":
				print_debug("I wont take any items from the player")
				_move_on_dialogue = false
				#This should not move the conversation to the next dialogue
				break
			else:
				#This part is appropriate when the current word spoken has no
				#options and thus the user just has to press interact to
				#continue
				word_to_say = curr_word
				show_dialogue_text.emit(word_to_say.trim_suffix("#"+str(i+1)))
				await get_tree().create_timer(0.5).timeout
				await_user_input.emit()
				await continue_dialogue
				word = curr_word
				continue
		
		#if its not just a string we present the options that the word says
		elif curr_word is not String:
			word_to_say = curr_word.keys()[0]
		#We send the ui the word
		show_dialogue_text.emit(word_to_say.trim_suffix("#"+str(i+1)))
		await get_tree().create_timer(1.0).timeout
		
		#We show the options one by one with a pause
		add_options.emit(curr_word[word_to_say], i+1)
		
		#and currently we select the first option because we have yet to create
		#a way for the options to be shown
		await_user_input.emit()
		await continue_dialogue
		
		#Then we move on to that option's words
		word = curr_word[word_to_say]["OPTION_"+str(option_chosen)]
		option_chosen = 0
	
	#After ending the conversation we hide the text and signal the player to move
	#again
	dialogue_label.text = ""
	if _dialogues_num > 1 and _move_on_dialogue:
		#print_debug("Moved on the next dialogue")
		_dialogues_num -= 1
	#print_debug("ending conversation")
	end_dialogue.emit()
	if player_character.has_signal("adjust_moving"):
		player_character.emit_signal("adjust_moving",true)

## This function gets called when the user selects an option or just presses
## continue. We receive the option number or if there is none we don't
func _on_dialogue_continue(option: int = 0) -> void:
	if option != 0:
		option_chosen = option
