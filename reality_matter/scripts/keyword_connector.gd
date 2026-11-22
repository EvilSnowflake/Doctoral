extends Line2D

@onready var wait_tim = $wait_tim

var start_point_node: Node
var end_point_node: Node

var _pnts: PackedVector2Array = []

func set_point_node(_start: Node, _end: Node) -> void:
	start_point_node = _start
	end_point_node = _end
	_pnts.append(Vector2.ZERO)
	_pnts.append(Vector2.ZERO)
	#_start.keyword_modified.connect(_follow_start_point_node)
	#_end.keyword_modified.connect(_follow_end_point_node)
	#_follow_start_point_node(0,0)
	#_follow_end_point_node(0,0)
	_start.tree_exited.connect(queue_free)
	_end.tree_exited.connect(queue_free)
	_end.opt_num_modified.connect(change_color)
	change_color(_end.col_number)

func fix_both_points() -> void:
	await get_tree().process_frame
	var start_pos: Vector2 = start_point_node.global_position
	start_pos.y = start_pos.y + start_point_node.size.y
	start_pos.x = start_pos.x + (start_point_node.size.x/2)
	if get_point_count() >= 1: set_point_position(0, start_pos)
	else: add_point(start_pos, 0)
	var end_pos: Vector2 = end_point_node.global_position
	end_pos.x = end_pos.x + (end_point_node.size.x / 2)
	if get_point_count() >= 2: set_point_position(1, end_pos)
	else: add_point(end_pos, 1)

func change_color(_col: Array) -> void:
	#print_debug([_col[0]/255.0,_col[1]/255.0,_col[2]/255.0])
	default_color = Color(_col[0]/255.0,_col[1]/255.0,_col[2]/255.0)
