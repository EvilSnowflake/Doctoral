extends CharacterBody2D

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

@export_category("Stats")
@export var animation_speed: int = 3
@export var current_state: int
@export_category("Components")
@export var an_player: AnimationPlayer
@export var ray: RayCast2D
@export var sprite: Sprite2D

var _default_state: int = State.IDLE
var _vector_position: Vector2 = Vector2.ZERO

var tilesize: int = 64
var moving = false

func _ready():
	current_state = _default_state

func _unhandled_input(_event: InputEvent) -> void:
	pass

func _physics_process(_delta):
	#If we are currently moving, the user can't engage with the controller
	if moving:
		return
	#For each input we have added in the dictionary, we check if the user is pressing any
	for dir in inputs.keys():
		#If something is pressed we go to that direction
		if Input.is_action_pressed(dir):
			#We update our animations only if the user was idle before
			if inputs[dir] != Vector2.ZERO and current_state == State.IDLE:
				current_state = State.RUN
				update_animation()
			move(dir)
			return
	#Then if there are no buttons pressed we change our animation state to IDLE
	if current_state != State.IDLE:
		current_state = State.IDLE
	update_animation()

#Function to move in the environment
func move(dir: String) -> void:
	#Check if we can move to the direction
	_vector_position = inputs[dir]*tilesize
	ray.target_position = _vector_position
	ray.force_raycast_update()
	#If we can then change the direction we face
	if !ray.is_colliding():
		if inputs[dir] == Vector2.LEFT:
			sprite.flip_h = true
		elif inputs[dir] == Vector2.RIGHT:
			sprite.flip_h = false
		#And create a tween that moves the player from starting position to final position
		var tween = create_tween()
		tween.tween_property(self, "position", position + _vector_position, 1.0/animation_speed).set_trans(Tween.TRANS_SINE)
		moving = true
		await tween.finished
		moving = false

#Function to change our current animation to our state
func update_animation() -> void:
	match current_state:
		State.IDLE:
			an_player.play("idle")
		State.RUN:
			an_player.play("run")
