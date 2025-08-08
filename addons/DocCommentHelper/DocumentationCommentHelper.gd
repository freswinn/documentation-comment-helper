@tool
extends EditorPlugin

var context = EditorContextMenuPlugin.new()

func _enter_tree() -> void:
	print("Documentation Comments Helper  ||  Hello! Right-click in the script editor to find the features of this plugin under the \"## Documentation\" menu item.")
	add_context_menu_plugin(EditorContextMenuPlugin.CONTEXT_SLOT_SCRIPT_EDITOR_CODE, context)

func _exit_tree() -> void:
	print("Documentation Comments Helper  ||  Plugin unloaded.")
	remove_context_menu_plugin(context)

func _ready():
	context.set_script(load("res://addons/DocCommentHelper/context.gd"))
