#include <M2/config.h>

void do_nothing_function (void) { }
 
#ifndef HAVE_SYNC
void sync(void) { }
#endif
