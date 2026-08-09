extends PanelContainer

@onready var icon: TextureRect = $Icon
@onready var quantity_label: Label = $QuantityLabel

#This function sets what item the slot contains, changing the icon and the
#quantity if its more than 1
func set_slot_data(slot: InventorySlot) -> void:
	if icon == null or quantity_label == null:
		print_debug("no icon or quantity label")
		return
	if slot.is_empty():
		icon.texture = null
		quantity_label.text = ""
	else:
		icon.texture = slot.item.icon
		quantity_label.text = str(slot.quantity) if slot.quantity > 1 else ""

#This function can be called if we need to change how big the slot is
func set_custom_min_max_size(x: float, y: float):
	custom_minimum_size = Vector2(x,y)
	custom_maximum_size = Vector2(x,y)
