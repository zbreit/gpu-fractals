shader_type canvas_item;

const int MAX_ITERS = 255;
const float ESCAPE_MAG_SQUARED = 1e6;

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

//void vertex() {
	//// Called for every vertex the material is visible on.
//}

void fragment() {
	// Called for every pixel the material is visible on.
	Complex c = Complex(2.0 * (UV[0] - 0.75), 2.0 * (UV[1] - 0.5));
		
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

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
