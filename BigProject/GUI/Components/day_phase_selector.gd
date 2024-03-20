extends Control

signal phase_changed(sky_color : Color, light_energy : float)

@onready var gradientSample : TextureRect = $GradientSample
@onready var slider : HSlider = $GradientSample/Slider

func _on_slider_value_changed(value) -> void:
	phase_changed.emit(gradientSample.texture.gradient.sample(value), value)
	
func get_sky_color() -> Color:
	return gradientSample.texture.gradient.sample(slider.value)

func get_light_energy() -> float:
	return  - pow((slider.value - 0.5), 2) * 4 + 1
