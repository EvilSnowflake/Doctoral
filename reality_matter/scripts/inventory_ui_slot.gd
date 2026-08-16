extends PanelContainer

#This script contains the logic for the item slots in the user interface.

## The varible icon points to the texture that shows what item is contained
## in the scene tree during the ready function.
@onready var icon: TextureRect = $Icon
## This variable references the label showing how many of the item presented
## are contained in this slot after the ready function.
@onready var quantity_label: Label = $QuantityLabel

## This function sets what item the slot contains, changing the icon and the
## quantity if its more than 1
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

## This function can be called if we need to change how big the slot is
func set_custom_min_max_size(x: float, y: float):
	custom_minimum_size = Vector2(x,y)
	custom_maximum_size = Vector2(x,y)

## This function can be used to change the inventory slot's graphic
func set_panel_texture(texture: Texture2D, margin: Vector4) -> void:
	var style = get_theme_stylebox("panel")
	style.texture = texture
	style.texture_margin_left = margin[0]
	style.texture_margin_top = margin[1]
	style.texture_margin_right = margin[2]
	style.texture_margin_bottom = margin[3]
	add_theme_stylebox_override("panel",style)
