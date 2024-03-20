extends Control

@export var options : Dictionary = {}
@onready var buttonContainer = $ButtonContainer

signal option_pressed(function_called : String)

func _ready():
	global_position = get_global_mouse_position()
	for option in options.keys():
		var button : Button = Button.new()
		button.text = option
		button.button_down.connect(emit_signal_for_button_pressed.bind(options[option]))
		button.mouse_filter = Control.MOUSE_FILTER_STOP
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		buttonContainer.add_child(button)

func _process(_delta):
	var rect = buttonContainer.get_global_rect()
	var mouse_position = get_global_mouse_position()
	if !rect.has_point(mouse_position) and mouse_position.distance_squared_to(get_global_transform().origin) > 2000:
		queue_free()
	
func emit_signal_for_button_pressed(function_called : String) -> void:
	option_pressed.emit(function_called)
	queue_free()
