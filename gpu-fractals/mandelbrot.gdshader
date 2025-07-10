shader_type canvas_item;

const int MAX_ITERS = 255;
const float ESCAPE_MAG_SQUARED = 4.0;

// Takes the form (x0, y0, x1, y1), where x0, y0 is the top left
// of the bounds and (x1, y1)
instance uniform vec4 mandelbrot_bounds = vec4(-2.0, -2.0, 2.0, 2.0);

struct Complex {
	float real;
	float imag;
};

Complex mul(Complex a, Complex b) {
	return Complex(
		a.real * b.real - a.imag * b.imag,
		a.real * b.imag + a.imag * b.real
	);
}

float square_mag(Complex z) {
	return z.real * z.real + z.imag * z.imag;
}

Complex plus(Complex a, Complex b) {
	return Complex(a.real + b.real, a.imag + b.imag);
}

// Computes whether the given complex point is bounded for the Mandelbrot set.
// A negative value indicates the value is bounded, otherwise the iteration
// index is returned
int mandelbrot(Complex c) {
	Complex z = Complex(0.0, 0.0);

	for(int i = 0; i < MAX_ITERS; ++i) {
		z = plus(mul(z, z), c);

		if(square_mag(z) > ESCAPE_MAG_SQUARED) {
			return i;
		}
	}

	return -1;
}

void fragment() {
	// Called for every pixel the material is visible on.
	float x0 = mandelbrot_bounds[0];
	float y0 = mandelbrot_bounds[1];
	float x1 = mandelbrot_bounds[2];
	float y1 = mandelbrot_bounds[3];

	// Note: UV goes from top left (0, 0) to bottom right (1, 1)
	// The input coordinate system go from top left (-1, 1) to bottom right (0, 0).
	// While the x-coordinate is increasing, the y -coordinate is decreasing, requiring
	// a sign flip.
	Complex c = Complex(x0 + (x1 - x0) * UV[0], y0 + (y1 - y0) * UV[1]);

	int i = mandelbrot(c);

	if (i < 0) {
		COLOR = vec4(0, 0, 0, 1);
	}
	else {
		float percent = float(i) / float(MAX_ITERS);
		//float percent = 1.0;
		COLOR = vec4(percent, percent / 2.0, percent / 4.0, 1);
	}
}
