extends Control

@onready var checkbox_h_box_container = $QuestShowcasePanel/VBoxContainer/CheckboxHBoxContainer
@onready var quest_title_label = $QuestShowcasePanel/VBoxContainer/QuestTitleLabel
@onready var quest_description_label = $QuestShowcasePanel/VBoxContainer/QuestDescriptionLabel
@onready var quest_showcase_panel: Panel = $QuestShowcasePanel

var quest_complete_style: StyleBoxFlat

func _ready() -> void:
	#quest_complete_style = StyleBoxFlat.new()
	#quest_complete_style.bg_color = Color.GREEN
	#quest_complete_style.bg_color.a = 0.75
	pass

func get_current_quest_title() -> String:
	return quest_title_label.text

func modify_quest_step(_step_text: String) -> void:
	for _child: CheckBox in checkbox_h_box_container.get_children():
		if _child.text == _step_text.to_lower():
			_child.button_pressed = true

func receive_quest_details(_title_text: String, _description_text: String,
_steps_array: Array[String], _completed_steps, _is_complete) -> void:
	quest_title_label.text = _title_text
	quest_description_label.text = _description_text
	for step in _steps_array:
		var step_checkbox: CheckBox = CheckBox.new()
		step_checkbox.mouse_filter = Control.MOUSE_FILTER_IGNORE
		step_checkbox.text = step.to_lower()
		if _completed_steps.has(step):
			step_checkbox.button_pressed = true
		if _is_complete:
			#quest_showcase_panel.add_theme_stylebox_override("panel", quest_complete_style)
			quest_title_label.add_theme_color_override("font_color",Color.GREEN)
			quest_description_label.add_theme_color_override("font_color",Color.GREEN)
		else:
			quest_title_label.remove_theme_color_override("font_color")
			quest_description_label.remove_theme_color_override("font_color")
		checkbox_h_box_container.add_child(step_checkbox)

func clear_details() -> void:
	quest_title_label.text = ""
	quest_description_label.text = ""
	for _child in checkbox_h_box_container.get_children():
		_child.queue_free()
	
