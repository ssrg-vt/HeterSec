export POPCORN="/usr/local/popcorn"

CC=$POPCORN/bin/clang ./configure --without-http_rewrite_module --without-pcre \
	--without-http_gzip_module
