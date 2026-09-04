extends Control

signal engagement_text_hidden()

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

# Called when the node enters the scene tree for the first time.
func _ready():
	text_box_container.hide()
	engagement_text_hidden.connect(_show_actions_panel)
	set_up_player(player_name_default, player_stats_default)
	for stri in _button_array_names:
		var act_button: Button = actions_button_scene.instantiate()
		actions_data_h.add_child(act_button)
		act_button.text = stri
		act_button.size_flags_horizontal = _size_flag_actions
		act_button.pressed.connect(_on_button_pressed.bind(act_button.text))
	setup_combat_second(enemy_sprite_default, enemy_name_default, enemy_combat_stats_default)
	#await engagement_text_hidden
	#actions_panel_container.show()

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
	pass
	#Here we setup the encounter after the user interacts with an enemy

func setup_combat_second(char_sprite: Sprite2D, char_name: String, char_stats: Combat_Stats):
	_set_bar_value(player_health_bar, _user_statistics.max_health, _user_statistics.health)
	enemy_sprite.texture = char_sprite
	_npc_statistics = char_stats
	enemy_sprite.texture = char_sprite.texture
	enemy_sprite.hframes = char_sprite.hframes
	enemy_sprite.vframes = char_sprite.vframes
	_set_bar_value(enemy_health_bar, _npc_statistics.max_health, _npc_statistics.health)
	_npc_name = char_name
	battle_camera.enabled = true
	_display_text("A wild " + _npc_name + " appears!")

func _on_button_pressed(button_name: String) -> void:
	print_debug(button_name + " BUTTON PRESSED!")
	var behaviour: String = _button_name_behaviour[button_name]
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
	_end_combat()

func _synthesize_attack(amount: int) -> void:
	_display_text("You start a devastating attack!")
	print_debug("Attack with " + str(amount))
	await engagement_text_hidden
	_deal_damage_to(amount*_user_statistics.attack_power, _npc_statistics, _npc_name)

func _stop_damage(amount: int) -> void:
	_is_defending = true
	_display_text("You try to defend")
	await engagement_text_hidden
	await_timer.start()
	await await_timer.timeout
	_enemy_turn()

func _set_bar_value(bar: ProgressBar, max_val: int, curr_val: int):
	bar.max_value = max_val
	bar.value = curr_val
	var bar_text: Label = bar.get_child(0)
	bar_text.text = "HP: " + str(curr_val) + "/" + str(max_val)

func _deal_damage_to(amount: int, person: Combat_Stats, charname: String):
	#_display_text("Person " + charname + " was dealt : " + str(amount))
	print_debug("Person " + charname + " was dealt : " + str(amount))
	var remaining_hp = person.deal_damage(amount)
	if charname == player_name.text:
		_set_bar_value(player_health_bar, person.max_health, remaining_hp)
		animation_player.play("shake")
		await animation_player.animation_finished
		_display_text(_npc_name + " dealt : " + str(amount) + " damage")
		await engagement_text_hidden
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
			_end_combat()
		
		_enemy_turn()

func _end_combat():
	battle_camera.enabled = false
	self.hide()
	
