#ifndef REDUCER_DEFS_H_
#define REDUCER_DEFS_H_

#include <cilk/cilk.h>

#include "./line.h"
#include "./intersection_event_list.h"
#include "./intersection_detection.h"

//----- IntersectionEventList

// Evaluates *left = *left OPERATOR *right
void IEL_merge(IntersectionEventList * left, IntersectionEventList * right);

// Evaluates *left = *left OPERATOR *right
void IEL_list_reduce(void * left, void * right);

// Sets *value to the the identity value.
void IEL_list_identity(void* value);



typedef IntersectionEventList cilk_reducer(IEL_list_identity, IEL_list_reduce) IELReducer;

#define IEL_RED (IntersectionEventList) { .head = NULL, .tail = NULL }

//----- Misc.

#define REGRED(name)

#define REDVAL(name) name

#define KILLRED(name)

#endif
