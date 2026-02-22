#include "gpctrl.h"

/*******************************************************
 * Nume functie: check_X()
 * Rol:
 * Intrare: -
 * Iesire: 0 -> serverul x este activ, 1 altfel
 * Obs:
 ********************************************************/
int check_X() {
    char* display;
    if ((display = getenv("DISPLAY")) == NULL) {
        fprintf(stderr, "X-Windows inactiv. Iesire...\n");
        return 1;
    } else return 0;
} // end of check_X()

/*******************************************************
 * Nume functie: gp_init()
 * Rol: verifica starea xwindows prin intermediul variabilei de mediu DISPLAY
 * Intrare: -
 * Iesire: Un handle pt gestionarea comunicarii cu un subproces
 * Obs:
 ********************************************************/
gp_ctrl* gp_init() {
    gp_ctrl* handle;
    if ((handle = (gp_ctrl*)malloc(sizeof(gp_ctrl))) == NULL) {
        fprintf(stderr, "Alocare dinamica esuata pt structura de control gp_ctrl. Iesire...\n");
        return NULL;
    }
    strcpy(handle->style, "lines");
    handle->cmdstream = popen("gnuplot --persist", "w");
    if (handle->cmdstream == NULL) {
        fprintf(stderr, "Eroare la lansarea gnuplot. Verificati ca gnuplot este instalat. Iesire...\n");
        free(handle);
        return NULL;
    }
    return handle;
} // end of gp_init

/*******************************************************
 * Nume functie: gp_send_cmd()
 * Rol: Trimite o comandă formatata catre gnuplot
 * Intrare: handle - pointer catre structura gp_ctrl
 *          format - formatul stringului urmat de argumentele variabile
 * Iesire: -
 * Obs: Foloseste vfprintf pentru a permite formatarea flexibila
 *      Nu se verif sintaxa comenzii trnasmise de pe gnuplot, ramane in sarcina utilizatorului
 ********************************************************/
void gp_send_cmd(gp_ctrl* handle, const char* format, ...) {
    if (handle == NULL || handle->cmdstream == NULL) {
        fprintf(stderr, "Eroare: Handle invalid sau flux de comenzi inexistent. Iesire...\n");
        return;
    }

    va_list ap;
    char local_cmd[GP_CMD_SIZE];
    // initializez lista de argumente
    va_start(ap, format);
    vsprintf(local_cmd, format, ap);
    strcat(local_cmd, "\n");
    fputs(local_cmd, handle->cmdstream);
    fflush(handle->cmdstream); // goleste buffer ul, deoarece ramane acel \n
    va_end(ap);
    // termin stringul-comanda cu "\n" pt a semnala finalul unei comenzi gnuplot de executat
}

void gp_finalize(gp_ctrl* h) {
    if(check_X()) return; // am cv de inchis/eliberat RAM?
    // inchid subprocesul gnuplot, eleiberez RAM alocat
    if(pclose(h->cmdstream) == -1) {
        fprintf(stderr, "Comunicarea cu subprocesul gnuplot intrerupta!\n");
        // nmc de facut in plus
        return;
    }
    free(h);
    return;
}

/*******************************************************
 * Nume functie: gp_set_gstyle()
 * Rol: Trimite o comandă formatata catre gnuplot
 * Intrare: handle - pointer catre structura gp_ctrl
 *          format - formatul stringului urmat de argumentele variabile
 * Iesire: -
 * Obs: Foloseste vfprintf pentru a permite formatarea flexibila
 *      Nu se verif sintaxa comenzii trnasmise de pe gnuplot, ramane in sarcina utilizatorului
 ********************************************************/
void gp_set_gstyle(gp_ctrl* h, char* style) {
    if(strcmp(style, "lines") &&
    strcmp(style, "points") &&
    strcmp(style, "linespoints") &&
    strcmp(style, "impulses") &&
    strcmp(style, "dots") &&
    strcmp(style, "steps") &&
    strcmp(style, "errorbars") &&
    strcmp(style, "boxes") &&
    strcmp(style, "boxerrorbars")) {
        fprintf(stderr, "Stil grafic necunoscut de gnuplot. Fortez lines...\n");
        strcpy(h->style, "lines");
        return;
    }
    strcpy(h->style, style);
    return;
}

void gp_set_xlabel(gp_ctrl* h, char* label) {
    // defineste etichete axei x
    char local_cmd[GP_CMD_SIZE];
    sprintf(local_cmd, "set xlabel \"%s\"", label);
    gp_send_cmd(h, local_cmd);
    return;
}

void gp_set_ylabel(gp_ctrl* h, char* label) {
    // defineste etichete axei y
    char local_cmd[GP_CMD_SIZE];
    sprintf(local_cmd, "set ylabel \"%s\"", label);
    gp_send_cmd(h, local_cmd);
    return;
}

// putem face functii set_title, reprez graf folosind latex cu argumente 



