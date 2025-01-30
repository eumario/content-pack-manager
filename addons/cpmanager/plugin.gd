@tool
extends EditorPlugin

const MANAGER_DLG = preload("res://addons/cpmanager/Dialogs/cp_manager.tscn")

func _enter_tree() -> void:
	add_tool_menu_item("Content Pack Manager", _handle_cp_manager)
	add_autoload_singleton("PackManager", "res://addons/cpmanager/pack_manager.gd")

func _exit_tree() -> void:
	remove_tool_menu_item("Content Pack Manager")
	remove_autoload_singleton("PackManager")

func _handle_cp_manager() -> void:
	var dlg := MANAGER_DLG.instantiate()
	dlg.close_requested.connect(func(): dlg.queue_free())
	EditorInterface.popup_dialog_centered(dlg)
