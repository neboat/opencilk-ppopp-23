#include <cilk/cilk.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

#include "intlist.h"
#include "ktiming.h"

#ifndef TIMING_COUNT
#define TIMING_COUNT 1
#endif

IntList _Hyperobject(identity_IntList, reduce_IntList) my_int_list_reducer;
// Initial value omitted //

void ilist_dac(int lo, int hi, int base) {
    int mid, ctr;

    if (hi - lo < base) {
        for (ctr = lo; ctr < hi; ctr++)
            IntList_append(&my_int_list_reducer, ctr);
        return;
    }

    mid = (lo + hi) / 2;

    cilk_spawn ilist_dac(lo, mid, base);

    ilist_dac(mid, hi, base);

    cilk_sync;

    return;
}

int main(int argc, char *args[]) {
    int i;
    int n, res = 0, b = 4;
    clockmark_t begin, end;
    uint64_t running_time[TIMING_COUNT];

    if (argc != 2 && argc != 3) {
        fprintf(stderr, "Usage: ilist_dac [<cilk-options>] <n> [<b>]\n");
        exit(1);
    }

    n = atoi(args[1]);

    if (argc == 3) {
        b = atoi(args[2]);
    }

    for (i = 0; i < TIMING_COUNT; i++) {
        begin = ktiming_getmark();
        IntList_init(&my_int_list_reducer);
        ilist_dac(0, n, b);
        IntList result = my_int_list_reducer;
        res += IntList_check(&result, 0, n);
        end = ktiming_getmark();
        running_time[i] = ktiming_diff_nsec(&begin, &end);
    }
    printf("Result: %d/%d successes!\n", res, TIMING_COUNT);
    print_runtime(running_time, TIMING_COUNT);

    return 0;
}
