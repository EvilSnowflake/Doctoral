extends Node2D

signal assign_item_contained(id: int)

@export var interactable: Area2D
@export var interact_label: Label
@export_category("Item Characteristics")
@export var sprite: Sprite2D
@export var item_contained: Item

var _can_interact_text = "Press key to interact"
#var _sprite_resource = load("res://assets/sprites/items/14.png")

# Called when the node enters the scene tree for the first time.
func _ready():
	if sprite == null:
		sprite = find_child("ItemSprite")
	if interact_label == null:
		interact_label = find_child("InteractLabel")
	#add_sprite(item_contained.icon, sprite)
	_on_player_left_interactable()
	if interactable.has_signal("player_collided"):
		interactable.player_collided.connect(_on_player_collided_with_interactable)
	if interactable.has_signal("player_left"):
		interactable.player_left.connect(_on_player_left_interactable)
	if interactable.has_signal("interacted"):
		interactable.interacted.connect(_on_player_interacted)
	assign_item_contained.connect(_assign_item_contained)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func _on_player_collided_with_interactable() -> void:
	#print_debug("Colliding player")
	interact_label.text = _can_interact_text

func _on_player_left_interactable() -> void:
	#print_debug("Player left collision")
	interact_label.text = ""

func _on_player_interacted(player: CharacterBody2D) -> void:
	#print_debug("Player picked item with id: " + str(item_id))
	if player.has_signal("add_item"):
		player.emit_signal("add_item",item_contained)
	self.queue_free()

func _assign_item_contained(it: Item) -> void:
	item_contained = it
	add_sprite(it.icon, sprite)

func add_sprite(spritePath: Resource, sprite_comp: Sprite2D) -> void:
	if sprite_comp == null and sprite != null:
		sprite.texture = spritePath
		return
	if spritePath != null and sprite_comp != null:
		sprite_comp.texture = spritePath
