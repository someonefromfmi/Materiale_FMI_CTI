#ifndef _GP_CTRL_H_
#define _GP_CTRL_H_

#include <string.h>
#include <stdarg.h> // declaratii pt fc cu lista variab de arg
#include <math.h>
#include <stdio.h>
#include <stdlib.h>

#define GP_CMD_SIZE 1024

typedef struct _GP_CTRL_H {
    FILE* cmdstream;
    char style[32];
    // FILE* logfile;
} gp_ctrl;

/*******************************************************
 * Nume functie: check_X()
 * Rol:
 * Intrare: -
 * Iesire: 0 -> serverul x este activ, 1 altfel
 * Obs:
 ********************************************************/
int check_X();

/*******************************************************
 * Nume functie: gp_init()
 * Rol: verifica starea xwindows prin intermediul variabilei de mediu DISPLAY
 * Intrare: -
 * Iesire: Un handle pt gestionarea comunicarii cu un subproces
 * Obs:
 ********************************************************/
gp_ctrl* gp_init();

// mai avem nevoie de o functie cu nr variab de argumente care sa transmita
// orice spre gnuplot

/*******************************************************
 * Nume functie: gp_send_cmd()
 * Rol: Trimite o comandă formatata catre gnuplot
 * Intrare: handle - pointer catre structura gp_ctrl
 *          format - formatul stringului urmat de argumentele variabile
 * Iesire: -
 * Obs: Foloseste vfprintf pentru a permite formatarea flexibila
 *      Nu se verif sintaxa comenzii trnasmise de pe gnuplot, ramane in sarcina utilizatorului
 ********************************************************/
void gp_send_cmd(gp_ctrl* handle, const char* format, ...);

void gp_finalize(gp_ctrl* h);

void gp_set_gstyle(gp_ctrl* h, char*style);

void gp_set_xlabel(gp_ctrl *h, char* xlabel);

void gp_set_ylabel(gp_ctrl *h, char* xlabel);


#endif

