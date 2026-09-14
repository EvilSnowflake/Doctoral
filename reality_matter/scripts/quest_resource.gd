class_name Quest
extends Resource

@export var title: String
@export_multiline var description: String
@export var steps: Array[String]
@export var reward_xp: int
@export var reward_items: Array[Item] = []

func set_details(dets: Dictionary, _it_rewards: Array[Item] = []) -> void:
	if !dets.has("TITLE"):
		print_debug("No title given for quest")
		return
	title = dets["TITLE"]
	if !dets.has("DESCRIPTION"):
		return
	description = dets["DESCRIPTION"]
	if !dets.has("STEPS"):
		return
	steps = dets["STEPS"]
	if !dets.has("REWARD_XP"):
		return
	reward_xp = dets["REWARD_XP"]
	if _it_rewards != []:
		reward_items = _it_rewards
