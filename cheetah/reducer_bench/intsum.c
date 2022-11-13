#include <cilk/cilk.h>
#include <stdio.h>
#include <stdlib.h>

#include "ktiming.h"

void identity_longsum(void *sum) { *((long *)sum) = 0; }

void reduce_longsum(void *left, void *right) {
    *((long *)left) += *((long *)right);
}

long _Hyperobject(identity_longsum, reduce_longsum) my_int_sum_reducer;

void compute_sum(long limit, int scale) {
    for (long i = 0; i < limit; i++) {
        my_int_sum_reducer += scale;
    }
}

void test_reducer(long limit) {
    #pragma GCC diagnostic ignored "-Wpass-failed"
    for (int t = 1; t < 100; ++t) {
        cilk_spawn compute_sum(limit, t);
    }
    compute_sum(limit, 100);
    cilk_sync;
}

int main(int argc, const char **args) {
    long i, n;
    int res = 0;
    clockmark_t begin, end;
    uint64_t running_time[TIMING_COUNT];

    if (argc != 2) {
        fprintf(stderr, "Usage: ilist_dac [<cilk-options>] <n>\n");
        exit(1);
    }

    n = atol(args[1]);

    const long scale = 100 * 101 / 2;

    for (i = 0; i < TIMING_COUNT; i++) {
        begin = ktiming_getmark();
        my_int_sum_reducer = 0;
        test_reducer(n);
        long sum = my_int_sum_reducer;
        res += (sum == scale * n) ? 1 : 0;
        end = ktiming_getmark();
        // prlongf("The final sum is %d\n", sum);
        running_time[i] = ktiming_diff_nsec(&begin, &end);
    }
    printf("Result: %d/%d successes!\n", res, TIMING_COUNT);
    print_runtime(running_time, TIMING_COUNT);

    return res != TIMING_COUNT;
}
