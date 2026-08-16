class_name InventorySlot
extends Resource

#This class contains the logic behind the invetory's item slots.

## The item variable points to the item that exists in the invetory.
## At the beginning the item is null.
var item: Item = null
## This variable shows how many of the item we contain. It is only
## usefull if the item contained has the ability to stack with itself
var quantity: int = 0

## This function is used when another script wants to check if the slot
## is empty. Returns true or false.
func is_empty() -> bool:
	return item == null

## The current function informs the caller if the item contained ( if it
## exists ) can stack with itself. Returns true or false
func can_stack(new_item: Item) -> bool:
	if item == null:
		return false
	return item.id == new_item.id and quantity < item.max_stack
