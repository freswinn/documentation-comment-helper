@tool
extends EditorContextMenuPlugin

enum ContextSelect { FormatSelection, OpenWindow }


var window_path = "res://addons/DocCommentHelper/window.tscn"
var window
var window_open : bool = false

func _popup_menu(paths: PackedStringArray) -> void:
	var things := PopupMenu.new()
	things.add_item("Format selection as documentation", ContextSelect.FormatSelection)
	things.add_item("Open window for writing documentation", ContextSelect.OpenWindow)
	things.id_pressed.connect(_on_submenu_option)
	add_context_submenu_item("## Documentation", things)

func _on_submenu_option(val : int):
	match val:
		ContextSelect.FormatSelection:
			format_selection()
		ContextSelect.OpenWindow:
			open_window()

func open_window():
	if window_open:
		print("Documentation Comments  ||  window already opened. If this is in error, you may need to reset the plugin or editor.")
		return
	window = load(window_path).instantiate()
	EditorInterface.get_base_control().add_child(window)
	print("Documentation Comments  ||  window opening")
	window_open = true
	window.popup_centered()
	window.close_requested.connect(close_window)

func close_window():
	window_open = false
	print("Documentation Comments  ||  window closing")
	window.queue_free()

func format_selection():
	var editor_plugin = EditorPlugin.new().get_editor_interface()
	var scr : CodeEdit = editor_plugin.get_script_editor().get_current_editor().get_base_editor()
	var lines = scr.get_line_ranges_from_carets()
	print(lines)
	for i in range(lines[0].x, lines[0].y+1):
		var text = scr.get_line(i)
		scr.set_line(i, "## %s" % text)
