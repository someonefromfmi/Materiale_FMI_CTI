#include "gpctrl.h"
// fisiere header necesare pt ODE in GSL
#include <gsl/gsl_errno.h>
#include <gsl/gsl_matrix.h>
#include <gsl/gsl_odeiv2.h>

// sistem ODE asociat problemei Vanderpol
int func(double t, const double y[], double f[], void* params) {
    double mu = *(double*) params;
    f[0] = y[1];
    f[1] = -y[0] + mu * y[1] * (1 - y[0] * y[0]);
    return GSL_SUCCESS; 
}

int jacobi(double t, const double y[], double *dfdy,
    double dfdt[], void *params) {
    (void)(t); /* avoid unused parameter warning */
    double mu = *(double*)params;
    gsl_matrix_view dfdy_mat
        = gsl_matrix_view_array (dfdy, 2, 2);
    gsl_matrix * mat = &dfdy_mat.matrix;
    // elem matricii Jacobiene
    gsl_matrix_set (mat, 0, 0, 0.0);
    gsl_matrix_set (mat, 0, 1, 1.0);
    gsl_matrix_set (mat, 1, 0, -2.0*mu*y[0]*y[1] - 1.0);
    gsl_matrix_set (mat, 1, 1, -mu*(y[0]*y[0] - 1.0));
    dfdt[0] = 0.0;
    dfdt[1] = 0.0;
    return GSL_SUCCESS;
}

int main(int argc, char** argv) {
    if(argc != 2) {
        fprintf(stdout, "Utilizare: \n %s nume_fisier \n", argv[0]);
        fprintf(stdout, "nume_fisier: numele fisierului de date \
                produs de program prin integrarea RK a ecuatiei Vanderpol. \
                \n\n");
    }

    FILE* fp;
    double mu = 15, t = 0, tf = 150.0;
    int i;
    gp_ctrl *h;
    char ch;
    double y[2] = {1.0, 0.0}; // cond init

    gsl_odeiv2_system sys = {func, jacobi, 2, &mu};

    //resurse RAM pt avansarea algoritmului RK8
    gsl_odeiv2_driver * drv =
        gsl_odeiv2_driver_alloc_y_new (&sys, gsl_odeiv2_step_rk8pd,
                                        1e-5, 1e-5, 0.0);

    fp = fopen(argv[1], "w");

    for (i = 1; i <= 150; i++){
        double ti = i * tf / 150;
        int status = gsl_odeiv2_driver_apply (drv, &t, ti, y); // avanseaza alg RK 8 pe un grid liniar
                                                               // din 1 in 1
        
        if (status != GSL_SUCCESS)
        {
            fprintf (stdout, "Eroare in avansarea alg ODE RK8 cod = %d\n", status);
            break;
        }
        fprintf (fp,"%.5lf\t%.5lf\t%.5lf\n", t, y[0], y[1]);
    }
    fclose(fp); fp = NULL;
    gsl_odeiv2_driver_free(drv);

    // sesiunea gnuplot
    h = gp_init();
    gp_set_xlabel(h, "t[div]");
    gp_set_ylabel(h, "y(t)");
    gp_set_gstyle(h, "lines");
    gp_send_cmd(h, "plot '%s' using 1:2", argv[1]);
    fprintf(stdout, "Apasa tasta q+ENTER pt a continua...\n");
    while(1) {
        if((ch=getchar()) == 'q') break;
    }
    gp_finalize(h);
    return GSL_SUCCESS;
}