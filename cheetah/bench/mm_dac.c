#include <cilk/cilk.h>
#include <stdio.h>
#include <stdlib.h>

#include "getoptions.h"
#include "ktiming.h"

#ifndef TIMING_COUNT
#define TIMING_COUNT 1
#endif

#define CHECK_RESULT 1
#define THRESHOLD 16
#define TRUE 1
#define FALSE 0

unsigned int randomSeed = 1;

static void mm_dac_serial(int *C, const int *A, const int *B, int n,
                          int length) {

    if (length < THRESHOLD) {
        // Use a loop for small matrices
        for (int i = 0; i < length; i++)
            for (int j = 0; j < length; j++)
                for (int k = 0; k < length; k++)
                    C[i * n + j] += A[i * n + k] * B[k * n + j];
        return;
    }

    // Partition the matrices
    int mid = length >> 1;

    int *C00 = C;
    int *C01 = C + mid;
    int *C10 = C + n * mid;
    int *C11 = C + n * mid + mid;

    int const *A00 = A;
    int const *A01 = A + mid;
    int const *A10 = A + n * mid;
    int const *A11 = A + n * mid + mid;

    int const *B00 = B;
    int const *B01 = B + mid;
    int const *B10 = B + n * mid;
    int const *B11 = B + n * mid + mid;

    mm_dac_serial(C00, A00, B00, n, mid);
    mm_dac_serial(C01, A00, B01, n, mid);
    mm_dac_serial(C10, A10, B00, n, mid);
    mm_dac_serial(C11, A10, B01, n, mid);

    mm_dac_serial(C00, A01, B10, n, mid);
    mm_dac_serial(C01, A01, B11, n, mid);
    mm_dac_serial(C10, A11, B10, n, mid);
    mm_dac_serial(C11, A11, B11, n, mid);
}

/**
 * Recursive implementation of matrix multiply.
 * This code will not work on non-square matrices.
 * Effect: Compute C+=A*B,
 * where C, A, and B are the starting addresses of submatrices with dimension
 * length x length.  Argument n is the original input matrix length.
 **/
static void mm_dac(int *C, const int *A, const int *B, int n, int length) {

    if (length < THRESHOLD) {
        // Use a loop for small matrices
        for (int i = 0; i < length; i++)
            for (int j = 0; j < length; j++)
                for (int k = 0; k < length; k++)
                    C[i * n + j] += A[i * n + k] * B[k * n + j];
        return;
    }

    // Partition the matrices
    int mid = length >> 1;

    int *C00 = C;
    int *C01 = C + mid;
    int *C10 = C + n * mid;
    int *C11 = C + n * mid + mid;

    int const *A00 = A;
    int const *A01 = A + mid;
    int const *A10 = A + n * mid;
    int const *A11 = A + n * mid + mid;

    int const *B00 = B;
    int const *B01 = B + mid;
    int const *B10 = B + n * mid;
    int const *B11 = B + n * mid + mid;

    cilk_spawn mm_dac(C00, A00, B00, n, mid);
    cilk_spawn mm_dac(C01, A00, B01, n, mid);
    cilk_spawn mm_dac(C10, A10, B00, n, mid);
    mm_dac(C11, A10, B01, n, mid);
    cilk_sync;

    cilk_spawn mm_dac(C00, A01, B10, n, mid);
    cilk_spawn mm_dac(C01, A01, B11, n, mid);
    cilk_spawn mm_dac(C10, A11, B10, n, mid);
    mm_dac(C11, A11, B11, n, mid);
    cilk_sync;
}

static void rand_matrix(int *dest, int n) {
    for (int i = 0; i < n * n; ++i)
        dest[i] = rand_r(&randomSeed) & 0xff;
}

static void zero_matrix(int *dest, int n) {
    for (int i = 0; i < n * n; ++i)
        dest[i] = 0;
}

#if CHECK_RESULT
static int are_equal_matrices(const int *a, const int *b, int n) {
    for (int i = 0; i < n * n; ++i)
        if (a[i] != b[i])
            return FALSE;
    return TRUE;
}
#endif

static _Bool test_mm(int n, int check) {
    clockmark_t begin, end;
    uint64_t running_time[TIMING_COUNT];

    int *A = (int *)malloc(sizeof(int) * (n * n));
    int *B = (int *)malloc(sizeof(int) * (n * n));
    int *C = (int *)malloc(sizeof(int) * (n * n));

    rand_matrix(A, n);
    rand_matrix(B, n);

    for (int i = 0; i < TIMING_COUNT; i++) {
        zero_matrix(C, n);
        begin = ktiming_getmark();
        mm_dac(C, A, B, n, n);
        end = ktiming_getmark();
        running_time[i] = ktiming_diff_nsec(&begin, &end);
    }
    print_runtime(running_time, TIMING_COUNT);

    if (check) {
        fprintf(stderr, "Checking result.\n");
        int *Cs = (int *)malloc(sizeof(int) * (n * n));
        zero_matrix(Cs, n);
        mm_dac_serial(Cs, A, B, n, n);
        if (!are_equal_matrices(C, Cs, n)) {
            fprintf(stderr, ">>>> MM_dac FAILED.\n");
            return 0; /* fail */
        }
        fprintf(stderr, "MM_dac test passed.\n");
        free(Cs);
    }

    free(C);
    free(B);
    free(A);

    return 1; /* pass */
}

// return true iff n = 2^k (or 0).
static int is_power_of_2(int n) { return (n & (n - 1)) == 0; }

const char *specifiers[] = {"-n", "-c", "-h", 0};
int opt_types[] = {LONGARG, BOOLARG, BOOLARG, 0};

int main(int argc, char *argv[]) {

    long size;
    int help, check;

    /* standard benchmark options */
    size = 1024;
    check = 0;
    help = 0;

    get_options(argc, argv, specifiers, opt_types, &size, &check, &help);

    if (help) {
        fprintf(stderr, "Usage: mm_dac -n <size> [-c|-h]\n");
        fprintf(
            stderr,
            "   when -c is set, check result against sequential MM (slow).\n");
        fprintf(stderr, "   when -h is set, print this message and quit.\n");
        exit(0);
    }

    if (!is_power_of_2(size)) {
        fprintf(stderr, "Input size must be a power of 2 \n");
        exit(1);
    }

    if (!test_mm(size, check)) {
        exit(1);
    }

    return 0;
}
