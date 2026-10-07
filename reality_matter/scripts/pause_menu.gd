extends Control

@onready var resume_button: Button = %ResumeButton
@onready var exit_button: Button = %ExitButton
@onready var quest_vbox = %QuestVbox
@onready var quest_panel = %QuestPanel
@onready var quest_showcase = %QuestShowcase
@onready var ex_button = %ExButton

#var quest_showcase_path: String = "res://scenes/quest_showcase.tscn"

#var _quest_showcase_scene: Resource

func _ready() -> void:
	#_quest_showcase_scene = load(quest_showcase_path)
	ex_button.pressed.connect(_stop_showcase)
	var quests: Array[Dictionary] = QuestManager.get_current_quests()
	for q in quests:
		#print_debug(q.title)d
		var quest_button: Button = Button.new()
		quest_button.text = q["TITLE"]
		quest_button.pressed.connect(_showcase_quest.bind(q))
		quest_vbox.add_child(quest_button)
		#The buttons should open a tooltip that shows the description and the steps required

func get_resume_button() -> Button:
	return resume_button

func get_exit_button() -> Button:
	return exit_button

func update_quest_list() -> void:
	pass

func _showcase_quest(_quest: Dictionary) -> void:
	quest_panel.show()
	var this_quest: Quest = QuestManager.find_quest_by_title(_quest["TITLE"])
	quest_showcase.receive_quest_details(this_quest.title, this_quest.description, this_quest.steps, _quest["COMPLETED_STEPS"])

func _stop_showcase() -> void:
	if quest_showcase.has_method("clear_destails"):
		quest_showcase.clear_destails()
	quest_panel.hide()
