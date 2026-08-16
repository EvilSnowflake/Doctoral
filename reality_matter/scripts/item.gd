class_name Item
extends Resource

#This class functions as a way to shape an item's architecture.
#Any item needs to contain a value for the variables in thiss class

## The id of the item can be used as an easier way for other
## scripts to check if the user has a specific item without
## having a reference to that item
@export var id: String = ""
## An item's name is one of the two ways the user can recognise
## the item mentioned
@export var name: String = "DEFAULT"
## An item can have a description so that the user can understand
## it's function in the game but does not have to
@export var description: String = "NONE"
## For an item to be truly recognisable by the user it requires a
## graphic which is what this variable needs. The graphic should be
## a Texture2D
@export var icon: Texture2D
## Each item can have the ability to stack with itself. This variable
## contains how many times the item can stack, by default it cannot
## and if the number of the max_stack is more than 1 it can
@export var max_stack: int = 1
## The item_type variable can be used if we want to differentiate
## between items for quests or consumable items but is not yet used
@export var item_type: String = "KEY_ITEM"
