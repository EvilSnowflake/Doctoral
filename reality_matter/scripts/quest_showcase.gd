extends Control

@onready var checkbox_h_box_container = $Panel/VBoxContainer/CheckboxHBoxContainer
@onready var quest_title_label = $Panel/VBoxContainer/QuestTitleLabel
@onready var quest_description_label = $Panel/VBoxContainer/QuestDescriptionLabel

func get_current_quest_title() -> String:
	return quest_title_label.text

func modify_quest_step(_step_text: String) -> void:
	for _child: CheckBox in checkbox_h_box_container.get_children():
		if _child.text == _step_text.to_lower():
			_child.button_pressed = true

func receive_quest_details(_title_text: String, _description_text: String, _steps_array: Array[String], _completed_steps = []) -> void:
	quest_title_label.text = _title_text
	quest_description_label.text = _description_text
	for step in _steps_array:
		var step_checkbox: CheckBox = CheckBox.new()
		step_checkbox.mouse_filter = Control.MOUSE_FILTER_IGNORE
		step_checkbox.text = step.to_lower()
		if _completed_steps.has(step):
			step_checkbox.button_pressed = true
		checkbox_h_box_container.add_child(step_checkbox)

func clear_destails() -> void:
	quest_title_label.text = ""
	quest_description_label.text = ""
	for _child in checkbox_h_box_container.get_children():
		_child.queue_free()
	
