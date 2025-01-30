@tool
extends ConfirmationDialog

#region Private Variables
var _update : bool = false

#region Properties
var cp_name : String :
	get(): return cp_name
	set(value):
		cp_name = value
		_set_text(%CPName, cp_name)

var folder_name : String :
	get(): return folder_name
	set(value):
		folder_name = value
		_set_text(%FolderName, folder_name)

var author_name : String :
	get(): return author_name
	set(value):
		author_name = value
		_set_text(%AuthorName, author_name)

var version_string : String :
	get(): return version_string
	set(value):
		version_string = value
		_set_text(%VersionString, version_string)

var url_string : String :
	get(): return url_string
	set(value):
		url_string = value
		_set_text(%UrlString, url_string)

var description : String :
	get(): return description
	set(value):
		description = value
		_set_text(%Description, description)

var icon_path : String :
	get(): return icon_path
	set(value):
		icon_path = value
		_set_text(%IconPath, icon_path)

var suggested_struct : bool :
	get(): return %SuggestedStruct.button_pressed
	set(value):
		suggested_struct = value
		if %SuggestedStruct != null:
			%SuggestedStruct.button_pressed = value

var edit : bool :
	set(value):
		edit = value
		title = "Edit Content Pack" if edit else "Create Content Pack"
		ok_button_text = "Save Pack" if edit else "Create Pack"
		%SStructLabel.visible = !edit
		%SuggestedStruct.visible = !edit
		%FolderLabel.visible = !edit
		%FolderName.visible = !edit
	get(): return edit

var pack_config : CPConfig
var pack_path : String
#endregion

#region Godot Overrides
func _ready() -> void:
	%SuggestedStruct.pressed.connect(func(): suggested_struct = %SuggestedStruct.button_pressed)
	self.cp_name = cp_name
	self.folder_name = folder_name
	self.author_name = author_name
	self.version_string = version_string
	self.url_string = url_string
	self.description = description
	self.icon_path = icon_path
	self.suggested_struct = suggested_struct
	
	%CPName.text_changed.connect(func(value : String): _update = true; cp_name = value; _update = false)
	%FolderName.text_changed.connect(func(value : String): _update = true; folder_name = value; _update = false)
	%AuthorName.text_changed.connect(func(value : String): _update = true; author_name = value; _update = false)
	%VersionString.text_changed.connect(func(value : String): _update = true; version_string = value; _update = false)
	%UrlString.text_changed.connect(func(value : String): _update = true; url_string = value; _update = false)
	%Description.text_changed.connect(func(): _update = true; description = %Description.text; _update = false)
	%IconPath.text_changed.connect(func(value : String): _update = true; icon_path = value; _update = false)
	%SuggestedStruct.toggled.connect(func(value : bool): _update = true; suggested_struct = value; _update = false)

#endregion

#region Private Functions
func _set_text(field : Control, value : String) -> void:
	if field == null: return
	if _update: return
	field.text = value
#endregion
