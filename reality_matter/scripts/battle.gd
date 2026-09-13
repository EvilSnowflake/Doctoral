extends Control

signal engagement_text_hidden()
signal engagement_ended()

@export var actions_button_scene: PackedScene
@export var enemy_sprite_default: Sprite2D
@export var enemy_combat_stats_default: Combat_Stats
@export var enemy_name_default: String
@export var player_name_default: String
@export var player_stats_default: Combat_Stats

@onready var player_name = %PlayerName
@onready var player_health_bar = %PlayerHealthBar
@onready var actions_data_h = %ActionsDataH
@onready var enemy_health_bar = %EnemyHealthBar
@onready var text_box_container = %TextBoxContainer
@onready var engagement_label = %EngagementLabel
@onready var actions_panel_container = %ActionsPanelContainer
@onready var await_timer = %AwaitTimer
@onready var enemy_sprite = %EnemySprite
@onready var animation_player = %AnimationPlayer
@onready var battle_camera = %BattleCamera
@onready var game_end_panel = %GameEndPanel
@onready var end_button = %EndButton
@onready var text_box_panel = %TextBoxPanel

var TweenItems: Dictionary = {}
var _size_flag_actions: Variant = Control.SIZE_EXPAND_FILL
var _button_array_names: Array[String] = ["ATTACK","DEFEND","RUN"]
var _button_name_behaviour: Dictionary = {
	"ATTACK" : "DEAL_DAMAGE1",
	"DEFEND" : "STOP_DAMAGE1",
	"RUN" : "DISENGAGE_COMBAT1"
}
var _user_statistics: Combat_Stats
var _user_name: String
var _npc_statistics: Combat_Stats
var _npc_name: String
var _is_defending: bool = false
var _can_press_buttons: bool = true
var _theme: Theme = preload("res://assets/themes/game_theme.tres")
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
	text_box_container.hide()
	game_end_panel.hide()
	engagement_text_hidden.connect(_show_actions_panel)
	#set_up_player(player_name_default, player_stats_default)
	for stri in _button_array_names:
		var act_button: Button = actions_button_scene.instantiate()
		actions_data_h.add_child(act_button)
		act_button.text = stri
		act_button.size_flags_horizontal = _size_flag_actions
		act_button.pressed.connect(_on_button_pressed.bind(act_button.text))
	#setup_combat_second(enemy_sprite_default, enemy_name_default, enemy_combat_stats_default)
	for key in _themes_dictionary.keys():
		_set_up_theme(_themes_dictionary[key], _theme, key)

func _input(_event):
	if !text_box_container.is_visible_in_tree():
		return
	if Input.is_action_just_pressed("Interact") or Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		text_box_container.hide()
		engagement_text_hidden.emit()

func _display_text(text: String):
	text_box_container.show()
	actions_panel_container.hide()
	engagement_label.text = text

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

func _show_actions_panel() -> void:
	actions_panel_container.show()

func set_up_player(user_name: String, player_stats: Combat_Stats) -> void:
	_user_name = user_name
	player_name.text = _user_name
	_user_statistics = player_stats

func setup_combat(charac: StaticBody2D) -> void:
	if !charac.has_method("get_sprite") or !charac.has_method("get_character_name") or !charac.has_method("get_npc_combat"):
		print_debug("NPC does not have a get sprite method or get name or get combat")
		return

func setup_combat_second(char_sprite: Sprite2D, char_name: String, char_stats: Combat_Stats, _tweens: Dictionary = {}):
	_set_bar_value(player_health_bar, _user_statistics.max_health, _user_statistics.health)
	#enemy_sprite.texture = char_sprite
	#enemy_sprite.get_parent().add_child(char_sprite)
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

func _on_button_pressed(button_name: String) -> void:
	#print_debug(button_name + " BUTTON PRESSED!")
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

func _disengage_combat(amount: int) -> void:
	_display_text("Got away safely with number : " + str(amount))
	await engagement_text_hidden
	await_timer.start()
	await await_timer.timeout
	_user_statistics.char_run.emit()
	_npc_statistics.char_run.emit()
	_end_combat()

func _synthesize_attack(amount: int) -> void:
	_display_text("You start a devastating attack!")
	#print_debug("Attack with " + str(amount))
	await engagement_text_hidden
	_deal_damage_to(amount*_user_statistics.attack_power, _npc_statistics, _npc_name)

func _stop_damage(amount: int) -> void:
	_is_defending = true
	_display_text("You try to defend with number %s" % [str(amount)])
	await engagement_text_hidden
	await_timer.start()
	await await_timer.timeout
	_enemy_turn()

func _set_bar_value(bar: ProgressBar, max_val: int, curr_val: int):
	#print_debug("Bar %s now has max health: %s and current health: %s" % [str(bar), str(max_val), str(curr_val)])
	bar.max_value = max_val
	bar.value = curr_val
	var bar_text: Label = bar.get_child(0)
	bar_text.text = "HP: " + str(curr_val) + "/" + str(max_val)

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

func _setup_stylebox_texture(theme_dictionary: Dictionary, theme_source: Theme, theme_name: String, theme_type: String):
	#print_debug(theme_dictionary)
	var thm_texture_path: String = theme_dictionary["THEME_TEXTURE_PATH"]
	var thm_texture_margin: Array = theme_dictionary["THEME_TEXTURE_MARGIN"]
	var stylebox_theme: StyleBoxTexture = StyleBoxTexture.new()
	stylebox_theme.texture = load(thm_texture_path)
	stylebox_theme.set_texture_margin(SIDE_LEFT, thm_texture_margin[0])
	stylebox_theme.set_texture_margin(SIDE_BOTTOM, thm_texture_margin[1])
	stylebox_theme.set_texture_margin(SIDE_RIGHT, thm_texture_margin[2])
	stylebox_theme.set_texture_margin(SIDE_BOTTOM, thm_texture_margin[3])
	#print_debug(" Theme %s of type %s changed stylebox" % [theme_name, theme_type])
	theme_source.set_stylebox(theme_name, theme_type, stylebox_theme)

func _setup_stylebox_flat(theme_dictionary: Dictionary, theme_source: Theme, theme_name: String, theme_type: String):
	#print_debug(theme_dictionary)
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
