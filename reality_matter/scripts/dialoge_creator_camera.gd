extends Camera2D


var target_zoom: float = 1.0
const ZOOM_INCREMENT: float = 0.1
const ZOOM_RATE: float = 8.0
const MIN_ZOOM: float = 0.4
const MAX_ZOOM: float = 1.0
const MOVE_SPEED: float = 2.0

func _physics_process(delta: float):
	zoom = lerp(zoom,target_zoom * Vector2.ONE, ZOOM_RATE * delta)
	set_physics_process(not is_equal_approx(zoom.x, target_zoom))

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		
		#print_debug("DOING IT")
		if event.button_mask == MOUSE_BUTTON_MASK_LEFT:
			#print_debug("MOVING IT")
			position -= event.relative * zoom * MOVE_SPEED
	
	if event is InputEventMouseButton and event.is_pressed():
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			zoom_in()
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			zoom_out()

func zoom_in() -> void:
	target_zoom = max(target_zoom - ZOOM_INCREMENT, MIN_ZOOM)
	#print_debug(target_zoom)
	set_physics_process(true)
	
func zoom_out() -> void:
	target_zoom = min(target_zoom + ZOOM_INCREMENT, MAX_ZOOM)
	#print_debug(target_zoom)
	set_physics_process(true)
