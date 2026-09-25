extends Control

#This script operates the scene where the user engages in battle with other npcs
#who can fight. It contains a graphical interface with the user and the npc's
#health and name, buttons for actions like attacking, defending and disengaging,
#a text box commentating on what is happening and various animations that
#complement the battle.

## This signal should be emmited when the commentary textbox disappears in order
## for the actions panel to show so that the user can continue to press buttons
signal engagement_text_hidden()
## During the end of the battle, this signal is used to inform other scripts
signal engagement_ended()

## This variable should contain a reference to the buttons that are going
## to hold the logic of the user's actions. The button scene doesn't hold the
## logic but it will receive it after creation.
@export var actions_button_scene: PackedScene
## This variable points to a sprite that the enemy could have if there is no
## available sprite for them
@export var enemy_sprite_default: Sprite2D
## This variable points to a combat statistics entity that the enemy can have if
## there is no available one during the encounter
@export var enemy_combat_stats_default: Combat_Stats
## This is a variable with the name the current enemy should have if there is
## no available one
@export var enemy_name_default: String
## This name should be used when the player does not have a name privided on the
## encounter
@export var player_name_default: String
## Those stats should be used for the player if they don't have any when the
## battle starts
@export var player_stats_default: Combat_Stats

## This variable points to the unique instance of the player name entity on the
## battle scene
@onready var player_name = %PlayerName
## This variable points to the unique instance of the player health bar on the
## battle scene
@onready var player_health_bar = %PlayerHealthBar
## This variable points to the unique instance of the height box for the actions
## on the battle scene
@onready var actions_data_h = %ActionsDataH
## This variable points to the unique instance of the enemy's health bar on the
## battle scene
@onready var enemy_health_bar = %EnemyHealthBar
## This variable points to the unique instance of the container holding the
## textbox related to the commentary of the battle on the scene
@onready var text_box_container = %TextBoxContainer
## This variable points to the unique instance of the commentary text box on the
## battle scene
@onready var engagement_label = %EngagementLabel
## This variable points to the unique instance of the container holding the
## panel with all the action buttons on the interface
@onready var actions_panel_container = %ActionsPanelContainer
## This variable points to the unique instance of the timer used in the script
## when we want to have a pause moment
@onready var await_timer = %AwaitTimer
## This variable points to the unique instance of the enemy character's sprite
@onready var enemy_sprite = %EnemySprite
## This variable points to the unique instance of the animation player that
## holds the battle's various animations
@onready var animation_player = %AnimationPlayer
## This variable points to the unique instance of the camera inside the battle
## scene
@onready var battle_camera = %BattleCamera
## This variable points to the unique instance of the panel signifying the end
## of the game after the user looses all of their health
@onready var game_end_panel = %GameEndPanel
## This variable points to the unique instance of the button closing the game
@onready var end_button = %EndButton
## This variable points to the unique instance of the panel under the commentary#
## text box
@onready var text_box_panel = %TextBoxPanel

## This dictionary should contain the aniamtions of the enemy's sprite in tween
## form so that they can also be used during the battle
var TweenItems: Dictionary = {}
## This variable holds the fill size flag applied to the action buttons so that
## they take up as much space as possible in the panel
var _size_flag_actions: Variant = Control.SIZE_EXPAND_FILL
## This array contains all the names of the action buttons
var _button_array_names: Array[String] = ["ATTACK","DEFEND","RUN"]
## This Dictionary has the behaviour of each action button. Currently:
## DEAL DAMAGE NUM: causes damage based on the character's attack power with a
## modifier to increase the damage further
## STOP DAMAGE NUM: stops all damage directed to the user, can be modified but
## not currently
## DISENGAGE COMBAT NUM: stops the battle scene, can be modified but not yet
var _button_name_behaviour: Dictionary = {
	"ATTACK" : "DEAL_DAMAGE1",
	"DEFEND" : "STOP_DAMAGE1",
	"RUN" : "DISENGAGE_COMBAT1"
}
## This variable should hold the combat stats of the user in order for us to be
## able to engage with them properly
var _user_statistics: Combat_Stats
## This variable should contain the name of the user to show it in the interface
var _user_name: String
## This variable will have the enemy characters combat statistics so that we can
## deal damage to it properly
var _npc_statistics: Combat_Stats
## This will have the enemy's name to show the user
var _npc_name: String
## This variable will only be true if the user pressed the DEFEND button this
## turn. It will stop all damage for that long
var _is_defending: bool = false
## This variable informs the user if they can press the action buttons. Should
## be false during the commentary and the animations
var _can_press_buttons: bool = true
## This variable points to the theme file that is used by some of the Interface
## elements. Will be modified depending on the contents of the theme dictionary
var _theme: Theme = preload("res://assets/themes/game_theme.tres")
## The theme dictionary should contain any changes we want to make to the theme
## file in the game. As keys there should be the type of element we want to
## change and in the value there should be keys of the base type and/or variants
## In these base type/variants there should be the name of the characteristic
## we want to change along with the values we want
var _themes_dictionary = {
	"Panel" : {
		"BASE_TYPE" : {
			"panel" : {
				"THEME_STYLEBOX_TYPE" : "StyleBoxFlat",
				"THEME_BG_COLOR" : "BLACK",
				"THEME_BG_ALPHA" : 0.9,
				"THEME_BORDER_WIDTH" : [0,0,0,0],
				"THEME_BORDER_COLOR" : "GRAY"
					}
				},
		"PANEL_2" : {
			"panel" : {
				"THEME_STYLEBOX_TYPE" : "StyleBoxFlat",
				"THEME_BG_COLOR" : "DARK_GREEN",
				"THEME_BG_ALPHA" : 0.75,
				"THEME_BORDER_WIDTH" : [0,0,0,0],
				"THEME_BORDER_COLOR" : "DARK_GREEN"
				},
			"UI_ELEMENTS" : ["ActionsPanel", "PlayerPanel"]
			},
		"PANEL_TEXTBOX": {
			"panel": {
				"THEME_STYLEBOX_TYPE" : "StyleBoxFlat",
				"THEME_BG_COLOR" : "BLACK",
				"THEME_BG_ALPHA" : 1.0,
				"THEME_BORDER_WIDTH" : [2,2,2,2],
				"THEME_BORDER_COLOR" : "WHITE"
					},
			"UI_ELEMENTS" : ["TextBoxPanel"]
			},
		"PANEL_TEXTURE": {
			"panel" : {
			"THEME_STYLEBOX_TYPE" : "StyleBoxTexture",
			"THEME_TEXTURE_PATH" : "res://assets/sprites/uielements/TinySquareBlueButton.png",
			"THEME_TEXTURE_MARGIN" : [25.0,25.0,25.0,25.0]
			}
		}
	},
	"Button":{
		"BASE_TYPE" : {
			"font_color":{
				"THEME_COLOR" : "WHITE"
			},
			"font_pressed_color":{
				"THEME_COLOR" : "GRAY"
			},
			"font_hover_color": {
				"THEME_COLOR" : "BLACK"
			},
			"normal" :{
				"THEME_STYLEBOX_TYPE" : "StyleBoxFlat",
				"THEME_BG_COLOR" : "BLACK",
				"THEME_BG_ALPHA" : 1.0,
				"THEME_BORDER_WIDTH" : [2,2,2,2],
				"THEME_BORDER_COLOR" : "WHITE"
			},
			"pressed" :{
				"THEME_STYLEBOX_TYPE" : "StyleBoxFlat",
				"THEME_BG_COLOR" : "WHITE",
				"THEME_BG_ALPHA" : 1.0,
				"THEME_BORDER_WIDTH" : [0,0,0,0],
				"THEME_BORDER_COLOR" : "WHITE"
			},
			"hover" :{
				"THEME_STYLEBOX_TYPE" : "StyleBoxFlat",
				"THEME_BG_COLOR" : "FLORAL_WHITE",
				"THEME_BG_ALPHA" : 1.0,
				"THEME_BORDER_WIDTH" : [0,0,0,0],
				"THEME_BORDER_COLOR" : "WHITE"
			}
		}
	},
	"ProgressBar":{
		"BASE_TYPE":{
			"font_size":{
				"SIZE" : 16
			},
			"background":{
				"THEME_STYLEBOX_TYPE" : "StyleBoxFlat",
				"THEME_BG_COLOR" : "RED",
				"THEME_BG_ALPHA" : 1.0,
				"THEME_BORDER_WIDTH" : [2,2,2,2],
				"THEME_BORDER_COLOR" : "BLACK"
			},
			"fill":{
				"THEME_STYLEBOX_TYPE" : "StyleBoxFlat",
				"THEME_BG_COLOR" : "GREEN",
				"THEME_BG_ALPHA" : 1.0,
				"THEME_BORDER_WIDTH" : [2,2,2,2],
				"THEME_BORDER_COLOR" : "BLACK"
			}
		}
	},
	"Label":{
		"BASE_TYPE" : {
			"font_color":{
				"THEME_COLOR" : "WHITE"
			}
		},
		"SHADOW_LABELS":{
			"font_shadow_color":{
				"THEME_COLOR" : "BLACK"
			},
			"UI_ELEMENTS" : ["PlayerHealthValue","EnemyHealthValue"]
		}
	}
}

# Called when the node enters the scene tree for the first time.
func _ready():
	#During the creation of the scene we have to perform a routine to set the environemnt up for
	#combat.
	#First we connect the act of hiding the commentary textbox with the function that shows the
	#actions panel. Then we create all the action buttons depending on the names added to the
	#appropriate array variable and connect them to the correct function depending on the number
	#next to their name
	text_box_container.hide()
	game_end_panel.hide()
	engagement_text_hidden.connect(_show_actions_panel)
	for stri in _button_array_names:
		var act_button: Button = actions_button_scene.instantiate()
		actions_data_h.add_child(act_button)
		act_button.text = stri
		act_button.size_flags_horizontal = _size_flag_actions
		act_button.pressed.connect(_on_button_pressed.bind(act_button.text))
	#Then we read the theme dictionary in order to set up the modifications specified inside
	for key in _themes_dictionary.keys():
		_set_up_theme(_themes_dictionary[key], _theme, key)

#This input function checks for the player's use of the Interact button or the mouse click in order
#to move on with the commentary textbox's recounting of what happened after their action.
func _input(_event):
	#if !text_box_container.is_visible_in_tree():
	#	return
	if Input.is_action_just_pressed("Interact") or Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		text_box_container.hide()
		engagement_text_hidden.emit()

## This function is responsible for showing the user text during the combat encounter. It shows the
## commentary textbox component before also adding text to it depending on the input given
func _display_text(text: String) -> void:
	text_box_container.show()
	actions_panel_container.hide()
	engagement_label.text = text

## This function represent the enemy npc's attempt to counter attack after the user picks their
## action. Currently it only plays an animation and also deals damage to the user unless they are
## currently defending this turn.
func _enemy_turn() -> void:
	if _is_defending:
		_is_defending = false
		animation_player.play("mini_shake")
		await animation_player.animation_finished
		_display_text("You defended succesfully!")
		await engagement_text_hidden
		_show_actions_panel()
		_can_press_buttons = true
		return
	
	_display_text(_npc_name + " attacks you!")
	await engagement_text_hidden
	_deal_damage_to(_npc_statistics.attack_power, _user_statistics, _user_name)

## This function should be connected with the hide text box panel signal so that when the textbox
## disappears we show the user the actions available to them.
func _show_actions_panel() -> void:
	actions_panel_container.show()

## Using this function, another script can give the appropriate characteristics to the user on this
## scene. It needs the user's name and their combat statistics and it should be called once at the
## beginning of the game since the user should not change during it.
func set_up_player(user_name: String, player_stats: Combat_Stats) -> void:
	_user_name = user_name
	player_name.text = _user_name
	_user_statistics = player_stats

## This function should be initiated by a different script when combat begins with an npc. It
## requires the npc's sprite, name, stats and animations in tween form. This is important so that
## we can give form to the npc, make them animated during the encounter and set their health bar
## properly. We also need to enable the camera contained inside the battle so that the appropriate
## animations are played when an action occurs
func setup_combat_second(char_sprite: Sprite2D, char_name: String, char_stats: Combat_Stats, _tweens: Dictionary = {}):
	_set_bar_value(player_health_bar, _user_statistics.max_health, _user_statistics.health)
	_npc_statistics = char_stats
	enemy_sprite.texture = char_sprite.texture
	enemy_sprite.hframes = char_sprite.hframes
	enemy_sprite.vframes = char_sprite.vframes
	_set_bar_value(enemy_health_bar, _npc_statistics.max_health, _npc_statistics.health)
	_npc_name = char_name
	battle_camera.enabled = true
	for i in range(_tweens["TWEEN_NAMES"].size()):
		var tween = get_tree().create_tween()
		tween.tween_property(enemy_sprite,_tweens["TWEEN_PROPS"][i], _tweens["TWEEN_CHANGES"][i][1], _tweens["TWEEN_DURATIONS"][i]).from(_tweens["TWEEN_CHANGES"][i][0])
		tween.set_loops()
		tween.stop()
		TweenItems[_tweens["TWEEN_NAMES"][i]] = tween
	if TweenItems.size() == 1:
		TweenItems[_tweens["TWEEN_NAMES"][0]].play()
	_display_text("A wild " + _npc_name + " appears!")

## This function should be connect to all the action buttons so they have the appropriate behaviour.
## It requires the button's name as input and depending on the name it calls the right function
func _on_button_pressed(button_name: String) -> void:
	if !_can_press_buttons:
		return
	var behaviour: String = _button_name_behaviour[button_name]
	_can_press_buttons = false
	if behaviour.contains("DISENGAGE_COMBAT"):
		var number: int = int(behaviour.trim_prefix("DISENGAGE_COMBAT"))
		_disengage_combat(number)
	elif behaviour.contains("DEAL_DAMAGE"):
		var number: int = int(behaviour.trim_prefix("DEAL_DAMAGE"))
		_synthesize_attack(number)
	elif behaviour.contains("STOP_DAMAGE"):
		var number: int =  int(behaviour.trim_prefix("STOP_DAMAGE"))
		_stop_damage(number)

## This function is one of the behaviours that is given to the action buttons during combat.
## The specific action ends the current encounterafter a brief pause. It also takes a number as
## input which can be used to increase the user's ability to disengage and with it we can also
## refuse to let them run
func _disengage_combat(amount: int) -> void:
	_display_text("Got away safely with number : " + str(amount))
	await engagement_text_hidden
	await_timer.start()
	await await_timer.timeout
	_user_statistics.char_run.emit()
	_npc_statistics.char_run.emit()
	_end_combat()

## This function is one of the behaviours that is given to the action buttons during combat.
## This action deals damage to the enemy using the user's attack power times the amount given as
## input
func _synthesize_attack(amount: int) -> void:
	_display_text("You start a devastating attack!")
	await engagement_text_hidden
	_deal_damage_to(amount*_user_statistics.attack_power, _npc_statistics, _npc_name)

## This function is one of the behaviours that is given to the action buttons during combat.
## This action enables the user to block all damage during this turn by making is_defending true.
## By using the input number we can also limit how much damage the user blocks
func _stop_damage(amount: int) -> void:
	_is_defending = true
	_display_text("You try to defend with number %s" % [str(amount)])
	await engagement_text_hidden
	await_timer.start()
	await await_timer.timeout
	_enemy_turn()

## This function should be utilised when we want to modify any character's health bar for when we
## deal damage to them or set them up. It requires the specific bar as input along with the
## character's max hp and current hp.
func _set_bar_value(bar: ProgressBar, max_val: int, curr_val: int):
	#print_debug("Bar %s now has max health: %s and current health: %s" % [str(bar), str(max_val), str(curr_val)])
	bar.max_value = max_val
	bar.value = curr_val
	var bar_text: Label = bar.get_child(0)
	bar_text.text = "HP: " + str(curr_val) + "/" + str(max_val)

## This function is responsible for any damage dealt to any character during combat. For it to work
## it requires an amount of damage dealt, the characters combat statistics and their name as input.
## It modifies the character's healthbar, plays an animation depending on what character is dealt
## the damage, shows the appropriate text and if their health reaches 0 the combat ends. If the
## character that died was the enemy then we also give control back to the user and move on to the
## enemy turn in order for the other character to finish their functions
func _deal_damage_to(amount: int, person: Combat_Stats, charname: String):
	var remaining_hp = person.deal_damage(amount)
	if charname == player_name.text:
		_set_bar_value(player_health_bar, person.max_health, remaining_hp)
		animation_player.play("shake")
		await animation_player.animation_finished
		_display_text(_npc_name + " dealt : " + str(amount) + " damage")
		await engagement_text_hidden
		if person.health == 0:
			_end_combat(true)
	else:
		_set_bar_value(enemy_health_bar, person.max_health, remaining_hp)
		animation_player.play("enemy_damaged")
		await animation_player.animation_finished
		_display_text("You dealt : " + str(amount) + " damage")
		await engagement_text_hidden
		if person.health == 0:
			_display_text(charname + " was defeated!")
			await engagement_text_hidden
			animation_player.play("enemy_died")
			await animation_player.animation_finished
			_can_press_buttons = true
			_end_combat()
			return
		_can_press_buttons = true
		_enemy_turn()

## This function is responsible for finishing the battle currently happening. Firstly it destroy's
## the npc's created tweens so that they don't remain afterwards and drain resources, it disables
## the battle camera and if the player died we play an animation, show the end screen and after the
## user presses the end button the game stops
func _end_combat(pl_died: bool = false):
	_can_press_buttons = true
	if !TweenItems.keys().is_empty():
		for twen: Tween in TweenItems.values():
			twen.kill()
	TweenItems.clear()
	if pl_died:
		game_end_panel.show()
		animation_player.play("pl_death_animation")
		await animation_player.animation_finished
		await end_button.pressed
		get_tree().quit()
	battle_camera.enabled = false
	engagement_ended.emit()

## This function is responsible for changing the central theme for the game. The theme itself does
## not have any overrides to the User Interface elements but if we provide this function with a
## dictionary containing any changes to the theme we want along with the theme and what type of
## element we want to modify, the function then reads the type of change we want to occur and
## does the appropriate action. The typical structure of the dictionary we need to provide is the
## name of the variant we want to create and which elements should get that variant or if we want to
## change the base one we just write BASE TYPE and inside we write what we want to change inside
## like the color, font size etc.
func _set_up_theme(theme_dictionary: Dictionary, theme_source: Theme, current_theme_type: String) -> void:
	for theme_type_key in theme_dictionary.keys():
		var shared_theme_dictionary: Dictionary = theme_dictionary[theme_type_key]
		var shared_theme_type: String = ""
		if theme_type_key != "BASE_TYPE":
			theme_source.add_type(theme_type_key)
			theme_source.set_type_variation(theme_type_key, current_theme_type)
			shared_theme_type = theme_type_key
		else:
			shared_theme_type = current_theme_type
		for theme_name_key in shared_theme_dictionary.keys():
			var theme_name_dictionary = shared_theme_dictionary[theme_name_key]
			if theme_name_dictionary.has("THEME_COLOR"):
				var theme_color: Color = Color(theme_name_dictionary["THEME_COLOR"])
				theme_source.set_color(theme_name_key, shared_theme_type, theme_color)
			elif theme_name_dictionary.has("THEME_STYLEBOX_TYPE"):
				var thm_stylebox_type: String = theme_name_dictionary["THEME_STYLEBOX_TYPE"]
				if thm_stylebox_type == "StyleBoxTexture":
					_setup_stylebox_texture(theme_name_dictionary, theme_source, theme_name_key, shared_theme_type)
				if thm_stylebox_type == "StyleBoxFlat":
					_setup_stylebox_flat(theme_name_dictionary, theme_source, theme_name_key, shared_theme_type)
			if shared_theme_dictionary.has("UI_ELEMENTS"):
				for var_name in shared_theme_dictionary["UI_ELEMENTS"]:
					var element = find_child(var_name)
					#print_debug(element)
					element.theme_type_variation = theme_type_key

## This function is used by the set up theme function and is specifically responsible for modifying
## the stylebox texture of a theme element. It requires the theme dictionary, the theme to change,
## the theme name and what type of element it is we change. The dictionary needs a path to the
## texture we want to apply along with its texture margins. The margin value requires an array with
## 4 elements like: [LEFT,TOP,RIGHT,BOTTOM]
func _setup_stylebox_texture(theme_dictionary: Dictionary, theme_source: Theme, theme_name: String, theme_type: String):
	var thm_texture_path: String = theme_dictionary["THEME_TEXTURE_PATH"]
	var thm_texture_margin: Array = theme_dictionary["THEME_TEXTURE_MARGIN"]
	var stylebox_theme: StyleBoxTexture = StyleBoxTexture.new()
	stylebox_theme.texture = load(thm_texture_path)
	stylebox_theme.set_texture_margin(SIDE_LEFT, thm_texture_margin[0])
	stylebox_theme.set_texture_margin(SIDE_TOP, thm_texture_margin[1])
	stylebox_theme.set_texture_margin(SIDE_RIGHT, thm_texture_margin[2])
	stylebox_theme.set_texture_margin(SIDE_BOTTOM, thm_texture_margin[3])
	#print_debug(" Theme %s of type %s changed stylebox" % [theme_name, theme_type])
	theme_source.set_stylebox(theme_name, theme_type, stylebox_theme)

## This function is used by the set up theme function and is specifically responsible for modifying
## the flat stylebox of a theme element. It requires the theme dictionary, the theme to change,
## the theme name and what type of element it is we change. The dictionary requires a background
## alpha value, a background color value, a border width value and a border color value. The alpha
## is just a float, while the colors only require the name of the color as written in the Godot
## Engine Documentation. The width on the other hand needs an array of 4 elements like: [LEFT,TOP,
##RIGHT,BOTTOM]
func _setup_stylebox_flat(theme_dictionary: Dictionary, theme_source: Theme, theme_name: String, theme_type: String):
	var thm_bg_alpha: float = theme_dictionary["THEME_BG_ALPHA"]
	var thm_bg_color: Color = Color(theme_dictionary["THEME_BG_COLOR"],thm_bg_alpha)
	var thm_border_width: Array = theme_dictionary["THEME_BORDER_WIDTH"]
	var thm_border_color: Color = Color(theme_dictionary["THEME_BORDER_COLOR"])
	var stylebox_theme: StyleBoxFlat = StyleBoxFlat.new()
	stylebox_theme.bg_color = thm_bg_color
	stylebox_theme.border_width_left = thm_border_width[0]
	stylebox_theme.border_width_top = thm_border_width[1]
	stylebox_theme.border_width_right = thm_border_width[2]
	stylebox_theme.border_width_bottom = thm_border_width[3]
	stylebox_theme.border_color = thm_border_color
	#print_debug(" Theme %s of type %s changed stylebox" % [theme_name, theme_type])
	theme_source.set_stylebox(theme_name, theme_type,stylebox_theme)
