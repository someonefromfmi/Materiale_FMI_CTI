double mc(long Np, void* params) {
    double* prms = (double*) params;
    long i, N1 = 0l;
    double ret_val,  // val locala a integralei
            u,       // pt alg RNG
            x, y, z, // pct genrat aleat in dom de integrat
            w;       // val test generat aleat
    // tipl alg rng
    const gsl_rng_type *T = gsl_rng_default;
    // handle: poiter catre ram necesar dezvl alg rng
    gsl_rng* r = gsl_rng_alloc(T);
    gsl_rng_env_setup();
    for(i = 0; i < Np; i++) {
        u = gsl_rng_uniform(r); // u in [0,1]
        x = -(*prms)+u*(2*(*prms));
        u = gsl_rng_uniform(r);
        y = -(*(prms+1))+u*(2*(*(prms+1)));
        u = gsl_rng_uniform(r);
        z = -(*(prms+2))+u*(2*(*(prms+2)));
        u = gsl_rng_uniform(r);
        w = u*((*(prms+3)));
        if(w <= f(x, y, z)) N1++;
    } // end_for(Np)
    ret_val = ((double)N1)/((double)Np)*(2*(*prms))*(2*(*(prms+1)))*(2*(*(prms+2)));
    gsl_rng_free(r);
    return ret_val;
}// end_of_mc()
