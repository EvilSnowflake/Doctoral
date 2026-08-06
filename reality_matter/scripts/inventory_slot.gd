class_name InventorySlot
extends Resource

var item: Item = null
var quantity: int = 0

func is_empty() -> bool:
	return item == null

func can_stack(new_item: Item) -> bool:
	if item == null:
		return false
	return item.id == new_item.id and quantity < item.max_stack
