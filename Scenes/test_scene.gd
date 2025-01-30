extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var packs = PackManager.get_pack_names()
	for pack in packs:
		%ContentPacks.add_item(pack)
	
	PackManager.configure_packs(%ContentWindow)
	PackManager.setup_packs()
	
	%EnableCP.pressed.connect(_handle_enable)
	%DisableCP.pressed.connect(_handle_disable)

func _handle_enable() -> void:
	var i : Array = %ContentPacks.get_selected_items()
	if i.size() == 0: return
	var pack : String = %ContentPacks.get_item_text(i)
	PackManager.enable_pack(pack)

func _handle_disable() -> void:
	var i : Array = %ContentPacks.get_selected_items()
	if i.size() == 0: return
	var pack : String = %ContentPacks.get_item_text(i)
	PackManager.disable_pack(pack)
