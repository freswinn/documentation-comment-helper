@tool
extends Window

enum WrapMode { None, Arbitrary, Word, SmartWord }

const documentation_url = "https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_documentation_comments.html"
var guideline : int = 80

func _ready():
	if Engine.is_editor_hint():
		var settings = EditorInterface.get_editor_settings()
		guideline = settings.get_setting("text_editor/appearance/guidelines/line_length_guideline_hard_column")
		%WidthGuide.set_value_no_signal(guideline)
		_on_width_guide_value_changed(guideline)

func _on_show_options_toggled(toggled_on: bool) -> void:
	%Options.visible = toggled_on


func _on_website_pressed() -> void:
	OS.shell_open(documentation_url)


func _on_brace_completion_toggled(toggled_on: bool) -> void:
	%CodeEdit.auto_brace_completion_enabled = toggled_on

func _on_brace_highlighting_toggled(toggled_on: bool) -> void:
	%CodeEdit.auto_brace_completion_highlight_matching = toggled_on


func _on_width_guide_value_changed(value: float) -> void:
	%CodeEdit.set_line_length_guidelines([int(value)])


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
