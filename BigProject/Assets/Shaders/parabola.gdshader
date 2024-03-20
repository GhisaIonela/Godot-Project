shader_type canvas_item;

void fragment() {
	if (pow(UV.x - .5, 2) * 4. * 1. > UV.y) {
		COLOR.a = 0.;
	}
}