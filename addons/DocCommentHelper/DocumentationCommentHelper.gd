@tool
extends EditorPlugin

const ContextFilepath : String = "res://addons/DocCommentHelper/context.gd"
const SettingsPath = "res://addons/DocCommentHelper/DocCommentSettings.json"
const DefaultSettings = {
	"show options" : true,
	"wrap mode" : 2,
	"guideline" : 100,
	"auto brace" : true,
	"brace highlighting" : true,
	"help text" : true,
	"verbose" : true,
	"content" : "",
	"window size x" : 640,
	"window size y" : 400
	}


var context := EditorContextMenuPlugin.new()
var settings
var verbose : bool = true



func _enter_tree() -> void:
	add_context_menu_plugin(EditorContextMenuPlugin.CONTEXT_SLOT_SCRIPT_EDITOR_CODE, context)

func _exit_tree() -> void:
	verbose = context.verbose # since these are the only times you need to know verbose, it's fine
	if verbose: print("Documentation Comments Helper  ||  Plugin unloaded.")
	remove_context_menu_plugin(context)

func _ready():
	load_settings()
	verbose = settings["verbose"]
	context.set_script(load(ContextFilepath))
	context.verbose = verbose # since these are the only times you need to know verbose, it's fine
	if verbose: print("Documentation Comments Helper  ||  Hello! Right-click in the script editor to find the features of this plugin under the \"## Documentation\" menu item.")



func load_settings():
	if !_check_for_settings_file():
		settings = DefaultSettings
		save_settings()
		load_settings()
	else:
		var source = FileAccess.open(SettingsPath, FileAccess.READ)
		settings = JSON.parse_string(source.get_as_text())
		source.close()
		_check_matching_settings()



func save_settings():
	var new_file = FileAccess.open(SettingsPath, FileAccess.WRITE)
	new_file.store_string(JSON.new().stringify(settings, "\t"))
	new_file.close()



func _check_for_settings_file() -> bool:
	var file_found = DirAccess.open("res://addons/DocCommentHelper").file_exists("DocCommentSettings.json")
	return file_found



func _check_matching_settings():
	var changes_made : bool = false
	var defkeys : Array = DefaultSettings.keys()
	var extras_in_current_settings : Array
	for i in settings.keys():
		if !i in defkeys:
			extras_in_current_settings.append(i)
	for i in extras_in_current_settings:
		settings.erase(i)
	if extras_in_current_settings.size() != 0: changes_made = true

	var missing_from_settings : Array
	for i in defkeys:
		if !i in settings.keys():
			missing_from_settings.append(i)
	if missing_from_settings.size() != 0: changes_made = true
	settings.merge(DefaultSettings, false) # merges defaults with current settings, but does not overwrite any current key/value pairs
	
	if changes_made: save_settings()
