@tool
extends ConfirmationDialog

var edit : bool :
	set(value):
		edit = value
		title = "Edit Content Pack" if edit else "Create Content Pack"
		ok_button_text = "Save Pack" if edit else "Create Pack"
	get(): return edit

func _ready() -> void:
	pass # Replace with function body.
