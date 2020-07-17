#include <stdio.h>
#include <stdlib.h>	// system
#include <unistd.h>
#include <string.h>
#include <fcntl.h>	// O_RDONLY

int main()
{
	char buf[64];
	int nbytes = 0, fd;
	int total = 0;

	fd = open("open.c", O_RDONLY);
	while (nbytes = read(fd, buf, 63)) {
		printf("==> %d bytes read\n", nbytes);
		total += nbytes;
		if (nbytes == -1) break;
	}
	close(fd);

	printf("total %d bytes\n", total);

	return 0;
}
