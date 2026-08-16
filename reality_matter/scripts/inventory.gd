class_name Inventory
extends Resource

#This class contains the functionality of the inventory. The inventory is a
#resource which happens to be more lightweight than a regular node something
#that makes it easier to move as a reference.

## The inventory contains a signal that when called informs other nodes that
## it just got changed
signal inventory_changed

## Inside the inventory exist item slots that can contain items. The slots
## are inside an array and they are a seprate class indipendant of the
## inventory resource.
var slots: Array[InventorySlot] = []
## The slots of the inventory can have a limited number so that it does not
## overflow, as default that number is 20 but can be changed.
var max_slots: int = 20

#The init function is called before the ready function and it creates the item
#slots one by one depending on the maxnumber of slots
func _init() -> void:
	for i in range(max_slots):
		slots.append(InventorySlot.new())

## This function is used by other scripts to modify the maximum number of items
## that the inventory can contain. Initialy it checks if the new number of
## slots happens to be bigger than the default one and if it is then we add
## slots based on the difference and then set the max number of slots as the
## new number. If the number is less than the default one we delete the last
## slot in the array a number of times based on the difference and then chnge
## the max number of slots accordingly. Regardless of the number we emit the
## signal that the inventory has been changed.
func change_max_slots(num: int) -> void:
	if num > max_slots:
		for i in range(num-max_slots):
			slots.append(InventorySlot.new())
		max_slots = num
	else:
		for i in range(max_slots-num):
			slots.pop_back()
		max_slots = num
	inventory_changed.emit()

## This function is responsible for placing items in the inventory. When
## another script calls it with an item and a quantity we first try to
## check if the item already exists in the inventory in which case we try
## to stack the item depending on the amount given if it stackable.
## If it does not already exist we try to fill the next item slot if it
## exists and the try to stack it if the amount is bigger than 1. We then
## notify the other scripts that the inventory changed and if there were
## any items remaining from this process then we return the amount left
## to the script that called this function.
func add_item(new_item: Item, amount: int = 1) -> int:
	var remaining: int = amount
	
	#first pass: try to stack with existing slots
	for slot in slots:
		if remaining <= 0:
			break
		if slot.can_stack(new_item):
			var space: int = new_item.max_stack - slot.quantity
			var to_add: int = mini(remaining, space)
			slot.quantity += to_add
			remaining -= to_add
	
	#second pass: fill empty slots
	for slot in slots:
		if remaining <= 0:
			break
		if slot.is_empty():
			slot.item = new_item
			var to_add := mini(remaining, new_item.max_stack)
			slot.quantity = to_add
			remaining -= to_add
	
	inventory_changed.emit()
	return remaining #returns whatever didn't manage to get in the inventory

#THIS FUNCTION CURRENTLY TAKES ITEMS EVEN IF WE ASK FOR MORE THAN IT HAS
#THEREFORE IF A QUESTS ASKS FOR 5 ITEM AND WE HAVE 3 IT TAKES ALL 3
#BUT IT WILL RETURN FALSE BECAUSE REMAINING WILL BE MORE THAN 0
## This function operates as a way to take an item out of the inventory.
## Such a thing could happen when another character needs to check if the
## user holds a specific item for a quest or if the user wants to take an item
## out of the inventory to add another. The first argument it takes is the item
## which doesn't have to be of type Item, because it can also be a String. If it
## is an Item we just have to check every item slot the inventory has and if
## the items match we delete the quantity given as a second argument. If it is a
## string though instead of checking the items as a type we try to match their ID
## and see if those match and then we remove the appropriate amount. At the end
## we check if we removed the correct amount of that item in which case we inform
## the caller that the function was a success, otherwise if the quantity was bigger
## than what the user was carrying we return false.
func remove_item(target_item, amount: int = 1) -> bool:
	var remaining: int = amount
	
	for slot in slots:
		if remaining <= 0:
			break
		if target_item is String and slot.item != null:
			if slot.item.id == target_item:
				var to_remove: int = mini(remaining, slot.quantity)
				slot.quantity -= to_remove
				remaining -= to_remove
				if slot.quantity <= 0:
					slot.item = null
					slot.quantity = 0
		elif target_item is Item:
			if slot.item == target_item:
				var to_remove: int = mini(remaining, slot.quantity)
				slot.quantity -= to_remove
				remaining -= to_remove
				if slot.quantity <= 0:
					slot.item = null
					slot.quantity = 0
	
	inventory_changed.emit()
	return remaining <= 0 #true if we removed everything requested
