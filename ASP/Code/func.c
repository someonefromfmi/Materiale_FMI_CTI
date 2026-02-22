#define SQR(x) ((x)*(x))
double f(double x, double y, double z) {
    double eps = 1.e-20;
    if((SQR(x) + SQR(y)) < eps) {
        return exp(-SQR(x)-3*SQR(y)-SQR(z));
    } else 
        return exp(-SQR(x)-3*SQR(y)-SQR(z))*sin(SQR(x)+SQR(y))/(SQR(x)+SQR(y));
}
