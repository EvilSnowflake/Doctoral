class_name Quest
extends Resource

#This resource operates as a way to condense the information of a quest in a simple structure that
#can be easily passed between scripts. A typical quest requires a title, a description, what steps
# the user should complete, the xp reward, the item rewards and the amount of item rewards. 

## The title of the quest is the first way to identify it and search for it
@export var title: String
## The quest's description is used to point the user to the correct direction towards completion
@export_multiline var description: String
## In order for the user to complete the quest there will be certain steps for them to complete.
## Inside this array all the necessary steps are contained in strings and the npc or item that give
## those steps should have them exactly as typed here in order for the quest to be completed
@export var steps: Array[String]
## This variable contains the amount of experience the quest will provide when completed
@export var reward_xp: int
## This array has all the item entities the user will receive after they complete the quest
@export var reward_items: Array[Item] = []
## This array is complementary to the reward_items array and informs the quest of how many items
## will be distributed to the user after completion. For each item entity in the other array, this
## array will have a number
@export var reward_item_quantity: Array[int] = []

## This function can be used by other scripts when creating a new quest. Normaly a quest can receive
## characteristics one by one by filling it's variables, but with set_details a dictionary can be
## given instead. The dictionary should contain a TITLE string, a DESCRIPTION string, a STEPS array
## of strings, a REWARD_XP array of ints, a REWARD_ITEMS array of items and a REWARD_ITEM_QUANTITY
## array of ints.
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
	if !dets.has("REWARD_ITEMS") or !dets.has("REWARD_ITEM_QUANTITY"):
		return
	for rew_it in dets["REWARD_ITEMS"]:
		var itm: Item = Item.new()
		itm = ItemManager.find_item_by_id(rew_it[0])
		reward_items.append(itm)
	for rew_it_q in dets["REWARD_ITEM_QUANTITY"]:
		reward_item_quantity.append(rew_it_q)
