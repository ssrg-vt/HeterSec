This is an instruction to build Redis on popcorn/HeterSec environment.
Redis is often referred as a *data structures* server. What this means is that Redis provides access to mutable data structures via a set of commands, which are sent using a *server-client* model with TCP sockets and a simple protocol.

Requirement
--------------

You need a popcorn-compiler installed. To randomly execute code between different nodes, you need to install the [secure-popcorn](https://github.com/ssrg-vt/popcorn-compiler/tree/secure-popcorn) branch.
Instructions to build the popcorn compiler can be found here.


Building Redis
--------------

Add the popcorn compiler location in the 2nd line of the Makefile, by default it is in `/usr/local/popcorn`:
```
% head Makefile
# Popcorn compiler location
POPCORN := /usr/local/popcorn
```

To build Redis, it is as simple as:
```
% make
```

Set up the configuration file of a list of places to trigger the migration. Also, set the probability to trigger the migration. Detailed instructions can be found here.

Running Redis
-------------

To run Redis with the default configuration just type:
```
% cd src
% ./redis-server
```

If you want to provide your redis.conf, you have to run it using an additional
parameter (the path of the configuration file):
```
% cd src
% ./redis-server /path/to/redis.conf
```

It is possible to alter the Redis configuration by passing parameters directly
as options using the command line. Examples:
```
% ./redis-server --port 9999 --replicaof 127.0.0.1 6379
% ./redis-server /etc/redis/6379.conf --loglevel debug
```

All the options in redis.conf are also supported as options using the command
line, with exactly the same name.

Playing with Redis
------------------

You can use redis-cli to play with Redis. Start a redis-server instance,
then in another terminal try the following:
```
% cd src
% ./redis-cli
redis> ping
PONG
redis> set foo bar
OK
redis> get foo
"bar"
redis> incr mycounter
(integer) 1
redis> incr mycounter
(integer) 2
redis>
```

Running the Redis benchmark:
```
% cd src
% ./redis-benchmark -h 127.0.0.1 -n 1000
```

You can find the list of all the available commands at http://redis.io/commands.