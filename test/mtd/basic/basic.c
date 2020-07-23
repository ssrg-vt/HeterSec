#include <stdio.h>
#include <unistd.h>

#include "migrate.h"

void remote_func2(int i)
{
	printf("    In %s\n", __func__);
//	migrate(0, NULL, NULL);
}

void remote_func1(int i)
{
	printf("[%d] Exec remotely.. redirect print back\n", i);
	sleep(2);
	remote_func2(i);
	printf("    In %s.\n", __func__);
//	migrate(0, NULL, NULL);
}

int main(int argc, char *argv[])
{
	int i;

	printf("[%d] Before migration.\n", getpid());

	for (i = 0; i < 10; i++) {
		remote_func1(i);
	}
	return 0;
}
