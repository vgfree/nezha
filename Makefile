# Makefile for Nezha project

TARGETS = testdbapi  testswserver testswclient testprotocol testlinktable \
          master libconfigdb.* 
OBJS    = event.o msgq.o engine.o nodes.o socketwrapper.o dbapi.o protocol.o \
        remotedbapi.o configdb.o 

all:	configdb master

# master:grid version	
master:	cmdline.o client.o
	gcc -o $@ $^ -L. -lconfigdb -ltokyocabinet
	@printf '#=====================================\n'
	@printf '# master:grid version\n'
	@printf '# execute ./master\n'
	@printf '#=====================================\n'

configdb: $(OBJS)
	ar -r libconfigdb.a $(OBJS)
	ar -s libconfigdb.a
	ranlib libconfigdb.a
	gcc -g -shared -W1 -o libconfigdb.so $^ -ltokyocabinet -lc

install:
	cp configdb.h /usr/include
	cp libconfigdb.* /usr/lib
	cp master /usr/bin/

uninstall:
	rm -rf  /usr/include/configdb.h
	rm -rf  /usr/lib/libconfigdb.*
	rm -rf  /usr/bin/master

test:   dbapi.o testdbapi.o \
		socketwrapper.o testsocketwrapperserver.o testsocketwrapperclient.o \
		protocol.o testprotocol.o \
		linktable.o testlinktable.o
	gcc -o testprotocol protocol.o testprotocol.o
	./testprotocol
	gcc -o testlinktable linktable.o testlinktable.o
	./testlinktable
	gcc -o testdbapi dbapi.o testdbapi.o -ltokyocabinet
	./testdbapi
	gcc -o testswserver socketwrapper.o testsocketwrapperserver.o
	gcc -o testswclient socketwrapper.o testsocketwrapperclient.o
	./testswserver &
	sleep 1
	./testswclient
	killall testswserver



.c.o:
	gcc -fPIC -g -c $<

clean:
	rm -rf *.o $(TARGETS) *.bak
