#include <math.h>

float f(float x) {
    return exp(-pow(x-1, 2)/2.5) / sqrt(2*M_PI);
}