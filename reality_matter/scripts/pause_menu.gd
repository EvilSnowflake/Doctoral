extends Control

@onready var resume_button: Button = %ResumeButton
@onready var exit_button: Button = %ExitButton
@onready var quest_vbox = %QuestVbox

func _ready() -> void:
	var quests: Array[Quest] = QuestManager.get_quests()
	for q in quests:
		#print_debug(q.title)d
		var print_label: Button = Button.new()
		print_label.text = q.title
		quest_vbox.add_child(print_label)
		#The buttons should open a tooltip that shows the description and the steps required

func get_resume_button() -> Button:
	return resume_button

func get_exit_button() -> Button:
	return exit_button

func update_qeust_list() -> void:
	pass
