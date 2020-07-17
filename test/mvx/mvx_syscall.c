#include <unistd.h>
#include <stdio.h>

static void __attribute__((constructor)) init_syscall_loader(void)
{
	fprintf(stdout, "Issue an MVX init syscall.\n");
	syscall(335, 0x1);
}
