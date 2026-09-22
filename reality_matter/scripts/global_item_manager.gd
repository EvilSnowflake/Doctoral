extends Node

var item_entities: Array[Item]

var _items_dictionary_test : Dictionary = {
	"ITEM_1" : {
		"ID" : "1",
		"NAME" : "Bone",
		"ICON" : "res://assets/sprites/items/14.png",
		"MAX_STACK" : 5,
		"ITEM_TYPE" : "KEY_ITEM"
	}
}

func _ready() -> void:
	set_items(_items_dictionary_test)

func set_items(_items: Dictionary) -> void:
	for item_keys in _items:
		var new_item: Item = Item.new()
		new_item.id = _items[item_keys]["ID"]
		new_item.name = _items[item_keys]["NAME"]
		new_item.icon = load(_items[item_keys]["ICON"])
		new_item.max_stack = _items[item_keys]["MAX_STACK"]
		new_item.item_type = _items[item_keys]["ITEM_TYPE"]
		item_entities.append(new_item)

func find_item_by_id(_id: String) -> Item:
	for item in item_entities:
		if item.id == _id:
			return item
	return null

func find_item_by_name(_name: String) -> Item:
	for item in item_entities:
		if item.name == _name:
			return item
	return null

func find_items_by_type(_type: String) -> Array[Item]:
	var _items_to_return: Array[Item] = []
	for item in item_entities:
		if item.item_type == _type:
			_items_to_return.append(item)
	return _items_to_return
