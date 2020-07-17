#ifndef _INFO_H_
#define _INFO_H_

extern char *syscalls[];

void info_syscalls(long size)
{
	int i;
	fprintf(stdout, "=== [MVX Unit Test] Testing %ld syscalls: ===\n", size);
	for (i = 0; i < size; i++) {
		fprintf(stdout, "%s", syscalls[i]);
		if (i != size-1) fprintf(stdout, ", ");
		if ((i+1)%10 == 0) fprintf(stdout, "\n");
	}
	fprintf(stdout, "\n\n");
}

#endif
