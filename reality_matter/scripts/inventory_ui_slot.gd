extends PanelContainer

#@onready var icon: TextureRect = $Icon
@onready var icon: TextureRect = $InventoryDataContainer/Icon
@onready var quantity_label: Label = $InventoryDataContainer/QuantityLabel


func set_slot_data(slot: InventorySlot) -> void:
	#icon = get_child(0)
	#quantity_label = get_child(1)
	if icon == null or quantity_label == null:
		print_debug("no icon or quantity label")
		return
	if slot.is_empty():
		icon.texture = null
		quantity_label.text = ""
	else:
		icon.texture = slot.item.icon
		quantity_label.text = str(slot.quantity) if slot.quantity > 1 else ""
