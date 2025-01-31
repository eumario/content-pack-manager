extends Control

var _buttonPressedCount : int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	%MyButton.pressed.connect(func(): _buttonPressedCount += 1; %MyLabel.text = "Hello World! %d" % _buttonPressedCount)
