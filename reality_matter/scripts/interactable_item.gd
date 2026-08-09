extends Node2D

#This script gives functionality to items that the user can interact with
#usually to pick them up

## This signal gives the entity an item to hold so that it knows what to give
## to the player
signal assign_item_contained(it: Item)

## This variable contains the interactable component that check when the player
## collides or interacts with us
@export var interactable: Area2D
## This variable contains the label for notifying the user about the item's
## interactability
@export var interact_label: Label
@export_category("Item Characteristics")
## This variable contains the entity's sprite
@export var sprite: Sprite2D
## This variable contains the entity's item
@export var item_contained: Item

## This variable contains the text that we show the user when they collide with
## us
var _can_interact_text = "Press key to interact"

# Called when the node enters the scene tree for the first time.
func _ready():
	#Here we find the sprite and interact label components of the scene and we
	#add them as variables if the variables don't already contain them
	if sprite == null:
		sprite = find_child("ItemSprite")
	if interact_label == null:
		interact_label = find_child("InteractLabel")
	
	#Here we call a function that informs the entity that the user isn't
	#currently colliding
	_on_player_left_interactable()
	
	#Here we connect signals that the entity needs for its interactivity to
	#function like player collided, left or interacted, when these signals
	#are emited from the interactable component we get notified
	if interactable.has_signal("player_collided"):
		interactable.player_collided.connect(_on_player_collided_with_interactable)
	if interactable.has_signal("player_left"):
		interactable.player_left.connect(_on_player_left_interactable)
	if interactable.has_signal("interacted"):
		interactable.interacted.connect(_on_player_interacted)
	#Here we connect the signal to assign the item contained, the signal is
	#emitted by the parent so that the item knows what it holds
	assign_item_contained.connect(_assign_item_contained)

## This function should be connected with the interactable component when the
## user collides with it, it informs the user that it can be interacted with
func _on_player_collided_with_interactable() -> void:
	#print_debug("Colliding player")
	interact_label.text = _can_interact_text

## This function should be connected with the interactable component when the
## user moves away from it, we then hide the text that informs them that we can
## be interacted with
func _on_player_left_interactable() -> void:
	#print_debug("Player left collision")
	interact_label.text = ""

## This function should be connected with the interactable component when the
## user begins interacting with it. We just add the item we hold to the player
## and then dissapear
func _on_player_interacted(player: CharacterBody2D) -> void:
	#print_debug("Player picked item with id: " + str(item_id))
	if player.has_signal("add_item"):
		player.emit_signal("add_item",item_contained)
	self.queue_free()

## This function should be called when we want to give this entity an item
## from outside of it
func _assign_item_contained(it: Item) -> void:
	item_contained = it
	add_sprite(it.icon, sprite)

## This function should be called so that the entity receives a sprite from
## outside of it
func add_sprite(spritePath: Resource, sprite_comp: Sprite2D) -> void:
	if sprite_comp == null and sprite != null:
		sprite.texture = spritePath
		return
	if spritePath != null and sprite_comp != null:
		sprite_comp.texture = spritePath
