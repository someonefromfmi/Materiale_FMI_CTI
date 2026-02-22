# mpirun -np 4 ./t1

CC = mpicc
CFLAGS = -Wall -O2

SRC = tema1.c filecom.c calc.c
OBJ = $(SRC:.c=.o)
DEPS = filecom.h calc.h

TARGET = t1

all: $(TARGET)

$(TARGET): $(OBJ)
	$(CC) $(CFLAGS) -o $@ $^ 

%.o: %.c $(DEPS)
	$(CC) $(CFLAGS) -c $<

clean:
	rm -f *.o $(TARGET) out.txt

