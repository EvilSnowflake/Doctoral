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

var _size_flag_actions: Variant = Control.SIZE_EXPAND_FILL
var _button_array_names: Array[String] = ["ATTACK","DEFEND","RUN"]
var _button_name_behaviour: Dictionary = {
	"ATTACK" : "DEAL_DAMAGE1",
	"DEFEND" : "STOP_DAMAGE1",
	"RUN" : "DISENGAGE_COMBAT1"
}
var _user_statistics: Combat_Stats
var _npc_statistics: Combat_Stats

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
		act_button.button_down.connect(_on_button_pressed.bind(act_button.text))
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

func _show_actions_panel() -> void:
	actions_panel_container.show()

func set_up_player(user_name: String, player_stats: Combat_Stats) -> void:
	player_name.text = user_name
	_user_statistics = player_stats

func setup_combat(char: StaticBody2D) -> void:
	if !char.has_method("get_sprite") or !char.has_method("get_character_name") or !char.has_method("get_npc_combat"):
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
	_display_text("A wild " + char_name + " appears!")
	

func _on_button_pressed(button_name: String) -> void:
	print_debug(button_name + " BUTTON PRESSED!")
	var behaviour: String = _button_name_behaviour[button_name]
	if behaviour.contains("DISENGAGE_COMBAT"):
		var number: int = int(behaviour.trim_prefix("DISENGAGE_COMBAT"))
		_disengage_combat(number)

func _disengage_combat(amount: int) -> void:
	_display_text("Got away safely with number : " + str(amount))
	await engagement_text_hidden
	await_timer.start()
	await await_timer.timeout
	self.queue_free()

func _set_bar_value(bar: ProgressBar, max_val: int, curr_val: int):
	bar.max_value = max_val
	bar.value = curr_val
	var bar_text: Label = bar.get_child(0)
	bar_text.text = "HP: " + str(max_val) + "/" + str(curr_val)

func _deal_damage_to(amount: int, person: Combat_Stats, name: String):
	_display_text("Person " + name + " was dealt : " + str(amount))
	var remaining_hp = person.deal_damage(amount)
	if name == player_name.text:
		#player_health_bar.value = remaining_hp
		_set_bar_value(player_health_bar, remaining_hp, person.max_health)
	else:
		#enemy_health_bar = remaining_hp
		_set_bar_value(enemy_health_bar, remaining_hp, person.max_health)
