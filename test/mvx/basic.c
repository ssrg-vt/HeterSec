#include <stdio.h>
#include <stdlib.h>	// system
#include <unistd.h>
#include <string.h>

#include "info.h"
char* syscalls[] = {"writev", "read"};
#define SYSCALL_SIZE	(sizeof(syscalls)/sizeof(syscalls[0]))

int main()
{
	char name[30];
	int ret = 0;
	int loop = 1;

	info_syscalls(SYSCALL_SIZE);

	write(2, "Writting to stderr\n", sizeof("Writting to stderr\n"));

	while (loop) {
		printf("Input your name (type \"quit\" to exit): \n");
		fflush(stdout);
		ret = read(0, name, 100);
		name[ret] = 0;
		printf("%d char(s) read, buf: %s\n", ret, name);
		if (!strncmp(name, "quit", 4)) {
			loop = 0;
		}
	}
	return 0;
}
