#include <cilk/cilk.h>
#include <stdio.h>
#include <stdlib.h>

#include "ktiming.h"

void identity_intsum(void *sum) { *((int *)sum) = 0; }

void reduce_intsum(void *left, void *right) {
    *((int *)left) += *((int *)right);
}

int _Hyperobject(identity_intsum, reduce_intsum) my_int_sum_reducer = 0;

void compute_sum(int limit) {
    for (int i = 0; i < limit; i++) {
        my_int_sum_reducer += 1;
    }
}

void test_reducer(int limit) {
    cilk_spawn compute_sum(limit);
    compute_sum(limit);
    cilk_sync;
}

int main(int argc, const char **args) {
    int i;
    int n, res = 0;
    clockmark_t begin, end;
    uint64_t running_time[TIMING_COUNT * 200];

    if (argc != 2) {
        fprintf(stderr, "Usage: ilist_dac [<cilk-options>] <n>\n");
        exit(1);
    }

    n = atoi(args[1]);

    for (i = 0; i < TIMING_COUNT * 200; i++) {
        begin = ktiming_getmark();
        my_int_sum_reducer = 0;
        test_reducer(n);
        int sum = my_int_sum_reducer;
        res += (sum == 2 * n) ? 1 : 0;
        end = ktiming_getmark();
        // printf("The final sum is %d\n", sum);
        running_time[i] = ktiming_diff_nsec(&begin, &end);
    }
    printf("Result: %d/%d successes!\n", res, TIMING_COUNT * 200);
    // print_runtime(running_time, TIMING_COUNT);

    return 0;
}
