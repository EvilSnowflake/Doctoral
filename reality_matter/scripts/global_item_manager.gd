extends Node

#This script works globaly in order for all the items we create to be correctly used. By giving it
#the name of an item or it's id we can get back the item itself as an entity. Also we can add items
#to the item collection.

## This variable holds all items we have created in Item form into an array.
var _item_entities: Array[Item]

## This function can be used to initiate item entities for use during the current game. As input
## it accepts a dictionary containing certain characteristics for the item to be created. Firstly
## we require an id with which we initiate a check in order for the id to not already be present.
## The id is in String form too in order for most characters to be accepted. Then we need a name
## which does not have to be unique in string form too. After that we need the path leading to
## texture 2D file, a number for the max stack and a string categorising what type of item it
## is. Common types include KEY_ITEM and BATTLE_ITEM.
func set_items(_items: Dictionary) -> void:
	for item_keys in _items.keys():
		if find_item_by_id(_items[item_keys]["ID"]) != null:
			print_debug("This item id already exists!")
			continue
		var new_item: Item = Item.new()
		new_item.id = _items[item_keys]["ID"]
		new_item.name = _items[item_keys]["NAME"]
		new_item.icon = load(_items[item_keys]["ICON"])
		new_item.max_stack = _items[item_keys]["MAX_STACK"]
		new_item.item_type = _items[item_keys]["ITEM_TYPE"]
		_item_entities.append(new_item)
	print_debug("Items added. Total items: %s" %[str(_item_entities.size())])

## This function can be used by other scripts to identify an item. Typically since we can't create
## items using text easily, we can just hold the ID of the item and by giving it to this function
## the script gets the full item back as an entity.
func find_item_by_id(_id: String) -> Item:
	for item in _item_entities:
		if item.id == _id:
			return item
	return null

## This function can be used by other scripts to identify an item. By using the inputed name it
## returns whatever is found in Item form
func find_item_by_name(_name: String) -> Item:
	for item in _item_entities:
		if item.name == _name:
			return item
	return null

## This function can be used by other scripts to identify an item. By using the inputed item type
## it returns an array of all items that have that specific type.
func find_items_by_type(_type: String) -> Array[Item]:
	var _items_to_return: Array[Item] = []
	for item in _item_entities:
		if item.item_type == _type:
			_items_to_return.append(item)
	return _items_to_return
