@tool
extends Window

signal DocCommentHelper_Verbose

enum WrapMode { None, Arbitrary, Word, SmartWord }

const documentation_url = "https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_documentation_comments.html"
const SettingsPath = "user://DocCommentSettings.json"
const DefaultSettings = {
	"show options" : true,
	"wrap mode" : WrapMode.Word,
	"guideline" : 100,
	"auto brace" : true,
	"brace highlighting" : true,
	"help text" : true,
	"verbose" : true,
	"content" : ""
}
const HelpfulText = '''Documentation comments typed into this code region do not require any comment symbols (#). These will be added when you click either of the Convert buttons.

However, this will NOT add line breaks for you. Resize this window and use the Text Wrap Mode and Width Guide options to help you find a good place to break up your comment lines.

Enjoy! :)'''

var verbose : bool = true
var settings_file : FileAccess
var settings : Dictionary
var active : bool = false


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
	var file_found = DirAccess.open("user://").file_exists("DocCommentSettings.json")
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



func change_setting(key : String, value, save_after_change : bool = true):
	if !key in settings.keys(): return
	settings.set(key, value)
	if save_after_change: save_settings()




func _ready():
	if !Engine.is_editor_hint(): return
	load_settings()
	%ShowOptions.button_pressed = settings["show options"]
	%BraceCompletion.button_pressed = settings["auto brace"]
	%BraceHighlighting.button_pressed = settings["brace highlighting"]
	%WidthGuide.value = settings["guideline"]
	%Wrap.select(settings["wrap mode"])
	%HelpText.button_pressed = settings["help text"]
	%Verbose.button_pressed = settings["verbose"]
	%CodeEdit.text = settings["content"]
	active = true



func get_guideline():
	var editor_settings = EditorInterface.get_editor_settings()
	var guideline = editor_settings.get_setting("text_editor/appearance/guidelines/line_length_guideline_hard_column")
	change_setting("guideline", guideline)
	%WidthGuide.set_value_no_signal(settings["guideline"])
	_on_width_guide_value_changed(settings["guideline"])



func _on_show_options_toggled(toggled_on: bool) -> void:
	%Options.visible = toggled_on
	change_setting("show options", toggled_on)


func _on_website_pressed() -> void:
	OS.shell_open(documentation_url)


func _on_brace_completion_toggled(toggled_on: bool) -> void:
	%CodeEdit.auto_brace_completion_enabled = toggled_on
	change_setting("auto brace", toggled_on)


func _on_brace_highlighting_toggled(toggled_on: bool) -> void:
	%CodeEdit.auto_brace_completion_highlight_matching = toggled_on
	change_setting("brace highlighting", toggled_on)


func _on_width_guide_value_changed(value: float) -> void:
	%CodeEdit.set_line_length_guidelines([int(value)])
	change_setting("guideline", int(value))


func _on_wrap_item_selected(index: WrapMode) -> void:
	match index:
		WrapMode.None:
			%CodeEdit.wrap_mode = 0
		WrapMode.Arbitrary:
			%CodeEdit.wrap_mode = 1
			%CodeEdit.autowrap_mode = 1
		WrapMode.Word:
			%CodeEdit.wrap_mode = 1
			%CodeEdit.autowrap_mode = 2
		WrapMode.SmartWord:
			%CodeEdit.wrap_mode = 1
			%CodeEdit.autowrap_mode = 3
	change_setting("wrap mode", index)


func _on_convert_pressed() -> void:
	var work = %CodeEdit.text.split("\n")
	var out : String = ""
	for i in work:
		out += "## %s\n" % i
	%CodeEdit.text = out


func _on_copy_pressed() -> void:
	var work = %CodeEdit.text.split("\n")
	var out : String = ""
	for i in work:
		out += "## %s\n" % i
	%CodeEdit.text = out
	%CodeEdit.select_all()
	%CodeEdit.copy()


func _on_clear_pressed() -> void:
	%CodeEdit.text = ""


func _on_help_text_toggled(toggled_on: bool) -> void:
	match toggled_on:
		true: %CodeEdit.placeholder_text = HelpfulText
		false: %CodeEdit.placeholder_text = ""
	change_setting("help text", toggled_on)


func _on_verbose_toggled(toggled_on: bool) -> void:
	verbose = toggled_on
	change_setting("verbose", toggled_on)
	DocCommentHelper_Verbose.emit(verbose)


func _on_close_requested() -> void:
	change_setting("content", %CodeEdit.text)
