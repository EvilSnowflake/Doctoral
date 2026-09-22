class_name Quest
extends Resource

@export var title: String
@export_multiline var description: String
@export var steps: Array[String]
@export var reward_xp: int
@export var reward_items: Array[Item] = []
@export var reward_item_quantity: Array[int] = []

func set_details(dets: Dictionary) -> void:
	if !dets.has("TITLE"):
		print_debug("No title given for quest")
		return
	title = dets["TITLE"]
	if !dets.has("DESCRIPTION"):
		return
	description = dets["DESCRIPTION"]
	if !dets.has("STEPS"):
		return 
	for step in dets["STEPS"]:
		steps.append(step)
	if !dets.has("REWARD_XP"):
		return
	reward_xp = dets["REWARD_XP"]
	if !dets.has("REWARD_ITEMS"):
		return
	for rew_it in dets["REWARD_ITEMS"]:
		var itm: Item = Item.new()
		itm = ItemManager.find_item_by_id(rew_it[0])
		reward_items.append(itm)
	for rew_it_q in dets["REWARD_ITEM_QUANTITY"]:
		reward_item_quantity.append(rew_it_q)
