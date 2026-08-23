extends CharacterBody2D

#This script should be assigned to the user's character and functions as a
#character controller, animator and interacting entity

## This signal should be emitted to give the player an Item to add to their
## inventory
signal add_item(item: Item)
## This signal should be emitted when we need to stop the user from moving
## or make them start moving again
signal adjust_moving(ability: bool)

## This Dictionary contains the inputs the user has in order for them to move.
## It currently contains the 4 directions: Up, Left, Down, Right
var inputs: Dictionary = {
	"Up" : Vector2.UP,
	"Left" : Vector2.LEFT,
	"Down" : Vector2.DOWN,
	"Right" : Vector2.RIGHT
}

## This dictionary contains the state the user can be at during the game
## pertaining to the character's animations, currently using idle and run
var State: Dictionary = {
	"IDLE": 0,
	"RUN": 1,
	"ATTACK": 2,
	"DEAD": 3
}

## This dictionary should contain all the user's animations and their names as
## keys
var TweenItems: Dictionary = {}

@export_category("Stats")
## This variable is given to the animations to point to how fast they are going
## to be
@export var animation_speed: int = 3
## This variable holds the current state of the user's animations. It is an
## integer because the citronary containing the states has integer values
@export var current_state: int
#########NEW SCRIPT
@export var character_name: String = "Player"
@export var user_combat_stats: Combat_Stats
#########NEW SCRIPT
@export_category("Components")
## This variable should point to the raycast component of the user. It is used
## the get informations about what is infront of the user when they move
@export var ray: RayCast2D
## This variable should point to the sprite used for the user's graphic design
@export var sprite: Sprite2D
@export_category("Exterior Items")
## In this variable we should give a reference to the last item collided with
## the player's raycast so that when the user tries to interact with it we
## know which item it is
@export var lastItemCollided: Area2D
## This variable holds the user's inventory
@export var inventory_list: Inventory
@export_category("Exterior Characters")
## In this variable we should give a reference to the last character the user
## collided with its raycast so that when the users tries to interact with it
## we know which character it was
@export var lastCharCollided: StaticBody2D


## This variable contains the default state of the user when they are created
## right now its set to IDLE
var _default_state: int = State.IDLE
## This variable should be set to wherever the user is going to go when they
## press a movement button. In this position we check if the player can go
## there, if there is an item or if there is a character
var _vector_position: Vector2 = Vector2.ZERO
## This variable informs the character if they are currently moving, we set it
## to true when they begin any movement and false when they stand still
var _moving: bool = false
## This variable informs the character if the user can move them, usually set
## to false when there is a dialogue in the process
var _moveability: bool = true

## This variable tells the character how big each tile is in the environment so
## that they know how big each step is going to be
var tilesize: int = 64
## This variable along with the vFrames variable informs the character how many
## sprites are contained in the sprite animation resource
var hFrames: int = 6
## This variable along with the hFrames variable informs the character how many
## sprites are contained in the sprite animation resource
var vFrames: int = 8
## This variable should be set to wherever the sprites of the user character
## are in the computer
var texturePath: Resource
## This variable shows the direction the user is currently facing after movement
var facing: Vector2
## This array contains the names of the animations of the character
var tweenNames: Array[String] = ["IdleTween", "RunTween"]
## This array contains what type of component the animation file is contained in
## the player's scene
var tweenComps: Array[String] = ["Sprite2D", "Sprite2D"]
## This array contains the properties of each animation the character has
var tweenProps: Array[String] = ["frame", "frame"]
## This array contains the beginning and end of each animation's frames
var tweenChanges: Array[Vector2i] = [Vector2i(0,5), Vector2i(6,11)]
## This array contains the time in seconds each animation should require to
## finish
var tweenDurations: Array[float] = [0.4, 0.4]

func _ready():
	#Here we check if the sprite variable is empty and if it is we try to find
	#the sprite component on the scene then we load the character texture and
	#add it to the sprite component while also breaking it down depending on the
	#hframes and vframes variables
	if sprite == null:
		sprite = find_child("Sprite2D")
	if sprite != null:
		texturePath =  load("res://assets/sprites/player/Warrior_Blue.png")
		sprite.texture = texturePath
		add_sprite(texturePath, sprite)
		sprite.hframes = hFrames
		sprite.vframes = vFrames
	
	#Here we create all the characters animations based on the variables we have
	#created
	for i in range(tweenNames.size()):
		var tween = get_tree().create_tween()
		tween.tween_property(get_node(tweenComps[i]),tweenProps[i], tweenChanges[i][1], tweenDurations[i]).from(tweenChanges[i][0])
		tween.set_loops()
		tween.stop()
		TweenItems[tweenNames[i]] = tween
	#We set the current character state to its default one and connect the
	#appropriate signals
	current_state = _default_state
	update_animation()
	add_item.connect(_add_item_to_inventory)
	adjust_moving.connect(change_moveability)

## This function is currently unused but can be if we have issues with input
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
			#Here we check if there was an item or characeter we had collided
			#with and we clear it before we start to move in order to then check
			#if there is a new one in front
			if (lastItemCollided != null ):
				if (lastItemCollided.has_signal("player_left")):
					lastItemCollided.emit_signal("player_left")
					lastItemCollided = null
			if (lastCharCollided != null):
				if (lastCharCollided.has_signal("player_left")):
					lastCharCollided.emit_signal("player_left")
					lastCharCollided = null
			#We then call the move function to try to move the character
			move(dir)
			#and also change the facing variable
			facing = inputs[dir]
			return
	#Then if there are no buttons pressed for movement we change our animation
	#state to IDLE
	if current_state != State.IDLE:
		current_state = State.IDLE
		update_animation()
	#If the player then presses the interact function we call the iteract
	if Input.is_action_just_pressed("Interact"):
		_interact()

## This function is used to modify the users position when they press a key.
func move(dir: String) -> void:
	#Check if we can move to the direction
	_vector_position = inputs[dir]*tilesize
	ray.target_position = _vector_position
	ray.force_raycast_update()
	#change the way the sprite is facing depending on the direciton
	if inputs[dir] == Vector2.LEFT:
		sprite.flip_h = true
	elif inputs[dir] == Vector2.RIGHT:
		sprite.flip_h = false
	#If the raycast does not collide with anything we try to move
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
		#Then we check the tile after the one we moved to
		_vector_position = inputs[dir]*tilesize
		ray.target_position = _vector_position
		ray.force_raycast_update()
		#If we don't find anything we move on
		if ray.get_collider() == null:
			return
		#If we find an area 2d its a character and inform them that we collided
		#with them
		if ray.get_collider().get_class() == "Area2D":
			lastItemCollided = ray.get_collider()
			if lastItemCollided.has_signal("player_collided"):
				lastItemCollided.emit_signal("player_collided")
		#If it is a staticbody2d then its an item and we inform thme as well
		elif ray.get_collider().get_class() == "StaticBody2D":
			lastCharCollided = ray.get_collider()
			if lastCharCollided.has_signal("player_collided"):
				lastCharCollided.emit_signal("player_collided")
	#If it is colliding then we check if the item we are colliding with is an
	#area2d (npc) or a staticbody2d (item) and we act accordingly
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

## This function is called when the user presses the Interact button, if we are
## not moving and we have the ability to move then we check if we collided with
## an item or an npc and we emit a signal to them signifying that the user wants
## to interact with it
func _interact() -> void:
	if _moving or !_moveability:
		return
	
	#Interact with lastItemCollided!!!
	if lastItemCollided != null:
		#When interacting, give the player as an argument
		if lastItemCollided.has_signal("interacted"):
			lastItemCollided.emit_signal("interacted",self)
	elif lastCharCollided != null:
		if lastCharCollided.has_signal("interacted"):
			lastCharCollided.emit_signal("interacted",self)

## Funciton to add an item to the ivnentory
func _add_item_to_inventory(item: Item) -> void:
	inventory_list.add_item(item)
	#print_debug("User picked up an item, has inventory: " + str(inventory_list))

## Function that places the sprite resource in the sprite of the player
func add_sprite(spritePath: Resource, sprite_comp: Sprite2D) -> void:
	if sprite_comp == null and sprite != null:
		sprite.texture = spritePath
		return
	if spritePath != null and sprite != null:
		sprite_comp.texture = spritePath

## Function that gets a true or false as input and either takes the user's
## ability to move or gives it back
func change_moveability(ability: bool):
	_moveability = ability

## Function to get a copy of the inventory
func receive_inventory(inventory_instance: Inventory):
	inventory_list = inventory_instance

## Called by characters to try and take an item from the user. If they have the
## specified item id given then it returns true
func give_item(item_id: String) -> bool:
	return inventory_list.remove_item(item_id)
######NEW SCRIPT
func receive_combat_stats(com_stats: Combat_Stats):
	user_combat_stats = com_stats
######NEW SCRIPT
## Function to change our current animation to our state. There is no input
## because we first need to update the current state variable and depending on
## its integer we invoke the appropriate tween item
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
