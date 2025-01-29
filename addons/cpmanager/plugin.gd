@tool
extends EditorPlugin

const MANAGER_DLG = preload("res://addons/cpmanager/Dialogs/cp_manager.tscn")

func _enter_tree() -> void:
	add_tool_menu_item("Content Pack Manager", _handle_cp_manager)

func _exit_tree() -> void:
	remove_tool_menu_item("Content Pack Manager")

func _handle_cp_manager() -> void:
	var dlg := MANAGER_DLG.instantiate()
	if FileAccess.file_exists("res://cp_settings.tres"):
		dlg.settings = load("res://cp_settings.tres")
	
	dlg.close_requested.connect(func(): dlg.queue_free())
	EditorInterface.popup_dialog_centered(dlg)
