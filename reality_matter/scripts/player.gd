extends CharacterBody2D

signal add_item(item: Item)
signal adjust_moving(ability: bool)

var inputs: Dictionary = {
	"Up" : Vector2.UP,
	"Left" : Vector2.LEFT,
	"Down" : Vector2.DOWN,
	"Right" : Vector2.RIGHT
}

var State: Dictionary = {
	"IDLE": 0,
	"RUN": 1,
	"ATTACK": 2,
	"DEAD": 3
}

var TweenItems: Dictionary = {}

@export_category("Stats")
@export var animation_speed: int = 3
@export var current_state: int
@export_category("Components")
@export var ray: RayCast2D
@export var sprite: Sprite2D
@export_category("Exterior Items")
@export var lastItemCollided: Area2D
@export var inventory_list: Inventory
@export_category("Exterior Characters")
@export var lastCharCollided: StaticBody2D

var _default_state: int = State.IDLE
var _vector_position: Vector2 = Vector2.ZERO
var _moving: bool = false
var _moveability: bool = true

var tilesize: int = 64
var hFrames: int = 6
var vFrames: int = 8
var texturePath: Resource
var facing: Vector2
var tweenNames: Array[String] = ["IdleTween", "RunTween"]
var tweenComps: Array[String] = ["Sprite2D", "Sprite2D"]
var tweenProps: Array[String] = ["frame", "frame"]
var tweenChanges: Array[Vector2i] = [Vector2i(0,5), Vector2i(6,11)]
var tweenDurations: Array[float] = [0.4, 0.4]

func _ready():
	if sprite == null:
		sprite = find_child("Sprite2D")
	if sprite != null:
		texturePath =  load("res://assets/sprites/player/Warrior_Blue.png")
		sprite.texture = texturePath
		add_sprite(texturePath, sprite)
		sprite.hframes = hFrames
		sprite.vframes = vFrames
	
	#Create animations
	for i in range(tweenNames.size()):
		var tween = get_tree().create_tween()
		tween.tween_property(get_node(tweenComps[i]),tweenProps[i], tweenChanges[i][1], tweenDurations[i]).from(tweenChanges[i][0])
		tween.set_loops()
		tween.stop()
		TweenItems[tweenNames[i]] = tween
		#TweenItems[tweenNames[0]].play()
	
	current_state = _default_state
	update_animation()
	add_item.connect(_add_item_to_inventory)
	adjust_moving.connect(change_moveability)
	#var new_anim = Animation.new()
	#var spri_track_index = new_anim.add_track(Animation.TYPE_VALUE)
	#new_anim.track_set_path(spri_track_index,sprite.get_path())
	#new_anim.track_insert_key(spri_track_index, 0.0, sprite)

func _unhandled_input(_event: InputEvent) -> void:
	pass

func _physics_process(_delta):
	#If we are currently moving, the user can't engage with the controller
	if _moving or !_moveability:
		return
	#For each input we have added in the dictionary, we check if the user is pressing any
	for dir in inputs.keys():
		#If something is pressed we go to that direction
		if Input.is_action_just_pressed(dir):
			#
			#
			if (lastItemCollided != null):
				if (lastItemCollided.has_signal("player_left")):
					lastItemCollided.emit_signal("player_left")
					lastItemCollided = null
			if (lastCharCollided != null):
				if (lastCharCollided.has_signal("player_left")):
					lastCharCollided.emit_signal("player_left")
					lastCharCollided = null
				
			move(dir)
			facing = inputs[dir]
			return
	#Then if there are no buttons pressed we change our animation state to IDLE
	if current_state != State.IDLE:
		current_state = State.IDLE
		update_animation()
	
	if Input.is_action_just_pressed("Interact"):
		
		_interact()

#Function to move in the environment
func move(dir: String) -> void:
	#Check if we can move to the direction
	_vector_position = inputs[dir]*tilesize
	ray.target_position = _vector_position
	ray.force_raycast_update()
	if inputs[dir] == Vector2.LEFT:
		sprite.flip_h = true
	elif inputs[dir] == Vector2.RIGHT:
		sprite.flip_h = false
	#If we can then change the direction we face
	if !ray.is_colliding():
		#We update our animations only if the user was idle before and
		#if we can move
		if inputs[dir] != Vector2.ZERO and current_state == State.IDLE:
			current_state = State.RUN
			update_animation()
		#And create a tween that moves the player from starting position to final position
		var tween = create_tween()
		tween.tween_property(self, "position", position + _vector_position, 1.0/animation_speed).set_trans(Tween.TRANS_SINE)
		_moving = true
		await tween.finished
		_moving = false
		_vector_position = inputs[dir]*tilesize
		ray.target_position = _vector_position
		ray.force_raycast_update()
		if ray.get_collider() == null:
			return
		if ray.get_collider().get_class() == "Area2D" :
			#print_debug(ray.get_collider())
			lastItemCollided = ray.get_collider()
			if lastItemCollided.has_signal("player_collided"):
				lastItemCollided.emit_signal("player_collided")
		elif ray.get_collider().get_class() == "StaticBody2D":
			lastCharCollided = ray.get_collider()
			if lastCharCollided.has_signal("player_collided"):
				lastCharCollided.emit_signal("player_collided")
	else:
		ray.target_position = _vector_position
		ray.force_raycast_update()
		if ray.get_collider() == null:
			return
		if ray.get_collider().get_class() == "Area2D" :
			print_debug(ray.get_collider())
			lastItemCollided = ray.get_collider()
			if lastItemCollided.has_signal("player_collided"):
				lastItemCollided.emit_signal("player_collided")
		elif ray.get_collider().get_class() == "StaticBody2D":
			print_debug(ray.get_collider())
			lastCharCollided = ray.get_collider()
			if lastCharCollided.has_signal("player_collided"):
				lastCharCollided.emit_signal("player_collided")

func _interact() -> void:
	#pass
	if _moving or !_moveability:
		return
	
	#Interact with lastItemCollided!!!
	if lastItemCollided != null:
		#When interacting, give the player as an argument
		if lastItemCollided.has_signal("interacted"):
			lastItemCollided.emit_signal("interacted",self)
	elif lastCharCollided != null:
		if lastCharCollided.has_signal("start_conversation"):
			lastCharCollided.emit_signal("start_conversation",self)
	#var facing_position = facing*tilesize
	#ray.target_position = facing_position
	#ray.force_raycast_update()
	#if ray.get_collider() == null:
	#	return
	#if ray.get_collider().get_class() == "Area2D" :
	#	print_debug(ray.get_collider())
	#	lastItemCollided = ray.get_collider()
	#	if lastItemCollided.has_signal("player_collided"):
	#		lastItemCollided.emit_signal("player_collided")

#Funciton to add an item to the item list
func _add_item_to_inventory(item: Item) -> void:
	inventory_list.add_item(item)
	#print_debug("User picked up an item, has inventory: " + str(inventory_list))

#Function that places the sprite resource in the sprite of the player
func add_sprite(spritePath: Resource, sprite_comp: Sprite2D) -> void:
	if sprite_comp == null and sprite != null:
		sprite.texture = spritePath
		return
	if spritePath != null and sprite != null:
		sprite_comp.texture = spritePath

func change_moveability(ability: bool):
	_moveability = ability

func receive_inventory(inventory_instance: Inventory):
	inventory_list = inventory_instance

#Function to change our current animation to our state
func update_animation() -> void:
	
	if TweenItems.is_empty() or State.is_empty():
		return
		
	match current_state:
		State.IDLE:
			for key in TweenItems:
				TweenItems[key].stop()
			TweenItems.values()[0].play()
			#an_player.play("idle")
		State.RUN:
			for key in TweenItems:
				TweenItems[key].stop()
			TweenItems.values()[1].play()
			#an_player.play("run")
