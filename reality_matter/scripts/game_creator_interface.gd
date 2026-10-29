extends CanvasLayer

var csv_file_path: String = ""
var png_file_path: String = ""
var speadsheet_textbox
var tile_set_path_textbox

# Called when the node enters the scene tree for the first time.
func _ready():
	speadsheet_textbox = find_child("SpeadsheetTextbox")
	tile_set_path_textbox = find_child("TileSetPathTextbox")
	speadsheet_textbox.focus_entered.connect(on_spreadsheet_textbox_focus_entered)
	tile_set_path_textbox.focus_entered.connect(on_tilepath_textbox_focus_entered)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func on_player_selected_csv_file(_path: String) -> void:
	csv_file_path = _path
	print_debug(csv_file_path)
	if !csv_file_path.ends_with(".csv"):
		print_debug("FILE NOT CSV")
	speadsheet_textbox.text = csv_file_path
	speadsheet_textbox.release_focus()
	var _sprd_array : Array = []
	var file = FileAccess.open(csv_file_path, FileAccess.READ)
	while not file.eof_reached():
		var line = file.get_line()
		_sprd_array.append(line.split(","))
	file.close()
	print_debug(_sprd_array)

func on_player_selected_png_file(_path: String) -> void:
	png_file_path = _path
	print_debug(png_file_path)
	if !png_file_path.ends_with(".png"):
		print_debug("FILE NOT PNG")
	tile_set_path_textbox.release_focus()
	tile_set_path_textbox.text = png_file_path

func on_spreadsheet_textbox_focus_entered() -> void:
	var fil_Dil: FileDialog = FileDialog.new()
	fil_Dil.set_file_mode(FileDialog.FILE_MODE_OPEN_FILE)
	fil_Dil.set_access(FileDialog.ACCESS_FILESYSTEM)
	fil_Dil.file_selected.connect(on_player_selected_csv_file)
	fil_Dil.use_native_dialog = true
	fil_Dil.add_filter("*.csv")
	add_child(fil_Dil)
	fil_Dil.show()

func on_tilepath_textbox_focus_entered() -> void:
	var fil_Dil2: FileDialog = FileDialog.new()
	fil_Dil2.set_file_mode(FileDialog.FILE_MODE_OPEN_FILE)
	fil_Dil2.set_access(FileDialog.ACCESS_FILESYSTEM)
	fil_Dil2.file_selected.connect(on_player_selected_png_file)
	fil_Dil2.use_native_dialog = true
	fil_Dil2.add_filter("*.png")
	add_child(fil_Dil2)
	fil_Dil2.show()
