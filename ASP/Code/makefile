# variabile de mediu pt compilare
# directorul de lucru
WDIR = $(shell pwd)

# compilatorul si instructiuni de compilare
CC = gcc
MPICC = mpicc
CFLAGS = -O2
INCDIR = -I.

# biblioteci externe de legat dinamic: basic linear algebra system pt gsl;
# gsl - GNU Scientific Library
LIBS = -lgslcblas -lgsl -lm

# curat rezultatul unei compilari anterioare
clean:
	rm -f *.o inel_mpi

# actiunea implicita
all: func2 mpi

# biblioteca dinamica | -c este flag-ul pt oprirea dupa compilare, dar inainte
# de legare | -fPIC 
func2: func2.c
	$(CC) -c -o func2.o $(CFLAGS) func2.c -lm


# bibilioteca statica - nevoie pt o masina in care nu este instalat nmc
# ar produce o biblioteca statica | rcs - replace create symbol

# Vanderpol - a lucart la Philips
# modul de device care sa simuleze un oscil electronic
# - oscilatorul Vanderpol
# u''(t) + miu * u'(t)(u^2(t)-1) + u(t)=0
# u(0)=1
# u'(0)=1
# ODE - Ordinary Differential Eqs.
# Runge-Kutta 8
# se rezolva prin notatia: u' = v
# v' = -u + miu * v(1-u^2)
# <=>
# y'[0] = y[1] = f1
# y'[1] =- y[0] + miu*y[1]*(1-y[0]*y[0]) = f2(t,y1,y2)
# ODE - Ordinary differential Equations

# compilarea codului Van der Pol
mpi: func2.o 
	env LD_LIBRARY_PATH=$(WDIR):$(LD_LIBRARY_PATH) $(MPICC) -o inel_mpi inel_mpi.c \
	func2.o -L$(WDIR) -lgplot -lm



# pt sysadmin: in /etc/ldconfig sau /etc/ld.conf pe fiecare este un dirname, dar
# este accesibil doar de sysadmin
# alternativ: rpath si env var LD_LIBRARY_PATH

# in terminal:
# export DL_LIBRARY_PATH=./:$LD_LIBRARY_PATH
#./vanderpol