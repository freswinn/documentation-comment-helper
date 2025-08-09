@tool
extends EditorPlugin

const ContextFilepath : String = "res://addons/DocCommentHelper/context.gd"

var context := EditorContextMenuPlugin.new()
var verbose : bool = true



func _enter_tree() -> void:
	add_context_menu_plugin(EditorContextMenuPlugin.CONTEXT_SLOT_SCRIPT_EDITOR_CODE, context)

func _exit_tree() -> void:
	verbose = context.verbose # since these are the only times you need to know verbose, it's fine
	if verbose: print("Documentation Comments Helper  ||  Plugin unloaded.")
	remove_context_menu_plugin(context)

func _ready():
	context.set_script(load(ContextFilepath))
	verbose = context.verbose # since these are the only times you need to know verbose, it's fine
	if verbose: print("Documentation Comments Helper  ||  Hello! Right-click in the script editor to find the features of this plugin under the \"## Documentation\" menu item.")
