class_name Inventory
extends Resource

signal inventory_changed

var slots: Array[InventorySlot] = []
var max_slots: int = 20

func _init() -> void:
	for i in range(max_slots):
		slots.append(InventorySlot.new())

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

func remove_item(target_item: Item, amount: int = 1) -> bool:
	var remaining: int = amount
	
	for slot in slots:
		if remaining <= 0:
			break
		if slot.item == target_item:
			var to_remove: int = mini(remaining, slot.quantity)
			slot.quantity -= to_remove
			if slot.quantity <= 0:
				slot.item = null
				slot.quantity = 0
	inventory_changed.emit()
	return remaining <= 0 #true if we removed everything requested
