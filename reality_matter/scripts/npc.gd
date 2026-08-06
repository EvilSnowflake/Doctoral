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
var CharacterDialogue: Dictionary = {
	"Dialogue_2":{
		"STARTING_CONVERSATION" :
			{"Hello#1": 
				{"OPTION_1": "Hi there#1",
				"OPTION_2": "Hello to you too!#1"
				}
			},
		"Hi there#1":
			{"Here' an item for you#2":
				{"OPTION_1": "Thanks#2",
				"OPTION_2": "Bye#2"
				}
			},
		"Hello to you too!#1":
			{"Goodbye#2":
				{"OPTION_1": "Bye#2",
				"OPTION_2": "Sure#2"
				}
			},
		"Bye#2":"ENDING_CONVERSATION",
		"Goodbye#2": "ENDING_CONVERSATION",
		"Sure#2": "ENDING_CONVERSATION",
		"Thanks#2": "GIVE_ITEM"
	},
	"Dialogue_1":{
		"STARTING_CONVERSATION" : "I already said hi go away#1",
		"I already said hi go away#1": "ENDING_CONVERSATION"
	}
}

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

var _texturePath: Resource
var _can_interact_text: String = "Press key to interact"
var _dialogues_num: int
var option_chosen: int

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
	
	_dialogues_num = CharacterDialogue.keys().size()
	
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
	if _dialogues_num > 1:
		_dialogues_num -= 1
	print_debug("ending conversation")
	end_dialogue.emit()
	if player_character.has_signal("adjust_moving"):
		player_character.emit_signal("adjust_moving",true)

#This function gets called when the user selects an option or just presses
#continue. We receive the option number or if there is none we don't
func _on_dialogue_continue(option: int = 0) -> void:
	if option != 0:
		option_chosen = option
