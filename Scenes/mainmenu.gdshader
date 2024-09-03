shader_type canvas_item;

uniform float height = 3.0;
uniform float frequency = 20.0;
uniform float speed = 3.0;

void vertex() {
	VERTEX.y += height * sin((frequency * UV.x) + (speed * TIME));
}

void fragment() {
	// Called for every pixel the material is visible on.
}

void light() {
	// Called for every pixel for every light affecting the CanvasItem.
}
