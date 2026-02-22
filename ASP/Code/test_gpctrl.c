#include "gpctrl.h"
#include <stdio.h>

int main() {
    if (check_X() != 0) {
        return 1;
    }

    gp_ctrl* gnuplot = gp_init();
    if (!gnuplot) {
        return 1;
    }
    
    int line_width = 2;
    gp_send_cmd(gnuplot, "plot cos(x) with lines lw %d", line_width);

    pclose(gnuplot->cmdstream);
    free(gnuplot);

    return 0;
}
