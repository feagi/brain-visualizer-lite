extends TextureButton
class_name ToggleButton

const TEX_DISABLED_ON: Texture = preload("res://BrainVisualizer/UI/GenericResources/ButtonIcons/toggle_on_disabled.png")
const TEX_DISABLED_OFF: Texture = preload("res://BrainVisualizer/UI/GenericResources/ButtonIcons/toggle_disabled.png")
const TEX_ENABLED_ON: Texture = preload("res://BrainVisualizer/UI/GenericResources/ButtonIcons/toggle_on.png")
const TEX_ENABLED_OFF: Texture = preload("res://BrainVisualizer/UI/GenericResources/ButtonIcons/toggle_off.png")
const TEX_MIDDLE: Texture = preload("res://BrainVisualizer/UI/GenericResources/ButtonIcons/toggle_mult.png")

@export var enable_autoscaling_with_theme: bool = true

var is_inbetween: bool:
	get: return _is_inbetween
	set(v):
		_is_inbetween = v
		if v:
			texture_disabled = TEX_MIDDLE
			texture_hover = TEX_MIDDLE
			texture_normal = TEX_MIDDLE
			texture_pressed = TEX_MIDDLE
		else:
			_set_enable_toggle(button_pressed)

var _is_inbetween: bool
var _cached_size: Vector2i
# Called when the node enters the scene tree for the first time.
func _ready():
	toggle_mode = true
	toggled.connect(_set_enable_toggle)
	_set_enable_toggle(button_pressed)
	if enable_autoscaling_with_theme:
		_cached_size = custom_minimum_size
		_theme_changed()
		BV.UI.theme_changed.connect(_theme_changed)


## USE THIS INSTEAD OF SET_PRESSED_NO_SIGNAL! If only I could actually override this shit
func set_toggle_no_signal(val: bool) -> void:
	_set_enable_toggle(val)
	set_pressed_no_signal(val)

func _set_enable_toggle(is_press: bool) -> void:
	_is_inbetween = false
	if is_press:
		texture_disabled = TEX_DISABLED_ON
		texture_hover = TEX_ENABLED_ON
		texture_normal = TEX_ENABLED_ON
		texture_pressed = TEX_ENABLED_ON
	else:
		texture_disabled = TEX_DISABLED_OFF
		texture_hover = TEX_ENABLED_OFF
		texture_normal = TEX_ENABLED_OFF
		texture_pressed = TEX_ENABLED_OFF

func _theme_changed(_theme: Theme = null) -> void:
	custom_minimum_size = _cached_size * BV.UI.loaded_theme_scale.x
