#include <stdio.h>
#include <stdlib.h>

int main() {
    FILE *input_file = fopen("input.dat", "r");
    if (!input_file) {
        fprintf(stderr, "Nu se poate deschide input.dat\n");
        return 1;
    }

    float *data = NULL;
    int total_values = 0;
    float temp;
    while (fscanf(input_file, "%f", &temp) == 1) {
        float *new_data = realloc(data, (total_values + 1) * sizeof(float));
        if (!new_data) {
            fprintf(stderr, "Eroare la alocarea memoriei\n");
            free(data);
            fclose(input_file);
            return 1;
        }
        data = new_data;
        data[total_values++] = temp;
    }
    fclose(input_file);

    int positive_count = 0;
    for (int i = 0; i < total_values; i++)
        if (data[i] >= 0)
            positive_count++;

    FILE *output_file = fopen("output_serial.dat", "w");
    if (!output_file) {
        fprintf(stderr, "Nu se poate deschide fisierul output_serial.dat\n");
        free(data);
        return 1;
    }
    fprintf(output_file, "Numar valori procesate:\t%d\n", total_values);
    fprintf(output_file, "Numar valori semipozitive procesate:\t%d\n", positive_count);
    fclose(output_file);

    free(data);
    printf("Procesare finalizata cu succes.\n");
    return 0;
}