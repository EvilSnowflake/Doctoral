extends StaticBody2D

signal player_collided
signal player_left
signal start_conversation(player: CharacterBody2D)
signal assign_item_to_give(item: Item)
signal initiate_dialogue(npc: StaticBody2D)
signal end_dialogue()
signal show_dialogue_text(text: String)
signal add_options(options: Dictionary, num: int)
signal await_user_input()
signal continue_dialogue()


var TweenItems: Dictionary = {}
var CharacterDialogue: Dictionary = {}

@export_category("Components")
@export var sprite: Sprite2D
@export var dialogue_label: Label
@export var item_to_give: Item

var hFrames: int = 7
var vFrames: int = 5
var tilesize: int = 64
var tweenNames: Array[String] = ["IdleTween"]
var tweenComps: Array[String] = ["Sprite2D"]
var tweenProps: Array[String] = ["frame"]
var tweenChanges: Array[Vector2i] = [Vector2i(0,6)]
var tweenDurations: Array[float] = [0.7]
var option_chosen: int

var _texturePath: Resource
var _can_interact_text: String = "Press key to interact"
var _dialogues_num: int
var _move_on_dialogue: bool = true

# Called when the node enters the scene tree for the first time.
func _ready():
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
	assign_item_to_give.connect(_on_assign_item_to_give)
	continue_dialogue.connect(_on_dialogue_continue)
	_on_player_left_char()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func add_sprite(spritePath: Resource, sprite_comp: Sprite2D = null) -> void:
	if sprite_comp == null and sprite != null:
		sprite.texture = spritePath
		return
	if spritePath != null and sprite_comp != null:
		sprite_comp.texture = spritePath

func add_dialogue(dial: Dictionary) -> void:
	CharacterDialogue = dial
	_dialogues_num = CharacterDialogue.keys().size()

func _on_player_collided_with_char() -> void:
	#print_debug("Colliding player")
	dialogue_label.text = _can_interact_text

func _on_player_left_char() -> void:
	#print_debug("Player left collision")
	dialogue_label.text = ""

func _on_assign_item_to_give(item: Item):
	if item != null:
		item_to_give = item

#This funciton determines what happens when the users attempts to converse with
#the character
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

#This function gets called when the user selects an option or just presses
#continue. We receive the option number or if there is none we don't
func _on_dialogue_continue(option: int = 0) -> void:
	if option != 0:
		option_chosen = option
