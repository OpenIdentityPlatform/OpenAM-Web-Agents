#
# The contents of this file are subject to the terms of the Common Development and
# Distribution License (the License). You may not use this file except in compliance with the
# License.
#
# You can obtain a copy of the License at legal/CDDLv1.0.txt. See the License for the
# specific language governing permission and limitations under the License.
#
# When distributing Covered Software, include this CDDL Header Notice in each file and include
# the License file at legal/CDDLv1.0.txt. If applicable, add the following below the CDDL
# Header, with the fields enclosed by brackets [] replaced by your own identifying
# information: "Portions copyright [year] [name of copyright owner]".
#
# Copyright 2014 - 2016 ForgeRock AS.
#

ifndef	LINUX_MK_INCLUDED
LINUX_MK_INCLUDED := true
	
CC := gcc
SHARED := -shared

CFLAGS  += -fPIC -pthread -std=gnu99 -D_REENTRANT -DLINUX -D_GNU_SOURCE -D_FORTIFY_SOURCE=2 -fstack-protector-all \
	    -Wno-unused-value -Wno-deprecated-declarations

ifdef DEBUG
 CFLAGS += -g3 -fno-inline -O0 -DDEBUG -Wall
else
 CFLAGS += -g -O2 -DNDEBUG
endif

ifdef 64
 CFLAGS += -m64 -DLINUX_64
 LDFLAGS += -m64
else
 CFLAGS += -m32 -D_FILE_OFFSET_BITS=64 -D_LARGEFILE_SOURCE -D_LARGEFILE64_SOURCE
 LDFLAGS += -m32
endif

CFLAGS += $(COMPILEFLAG)Iextlib/$(OS_ARCH)_$(OS_MARCH)/apache24/os/unix $(COMPILEFLAG)Iextlib/$(OS_ARCH)_$(OS_MARCH)/apache22/os/unix

LDFLAGS += -Wl,-rpath,'$$ORIGIN/../lib' -Wl,-rpath,'$$ORIGIN' -Wl,--no-as-needed -Wl,-z,now -Wl,-z,relro  -lpthread -lresolv -lrt -ldl

libopenam: $(OUT_OBJS)
	@$(ECHO) "[*** Creating "$@" shared library ***]"
	${CC} $(SHARED) -fPIC -Wl,-soname,libopenam.so  $(LDFLAGS) $(OUT_OBJS) -o build/libopenam.so
	
apache: $(OUT_OBJS) $(APACHE_OUT_OBJS)
	@$(ECHO) "[*** Creating "$@" shared library ***]"
	${CC} $(SHARED) -fPIC -Wl,-soname,mod_openam.so $(LDFLAGS) \
	    $(OUT_OBJS) -Wl,--version-script=source/apache/agent.map $(APACHE_OUT_OBJS) -o build/mod_openam.so

apache22: apache22_pre $(OUT_OBJS) $(APACHE22_OUT_OBJS) apache22_post
	@$(ECHO) "[*** Creating "$@" shared library ***]"
	${CC} $(SHARED) -fPIC -Wl,-soname,mod_openam.so $(LDFLAGS) \
	    $(OUT_OBJS) -Wl,--version-script=source/apache/agent.map $(APACHE22_OUT_OBJS) -o build/mod_openam.so
	
iis: 
	$(error IIS target is not supported on this platform)

varnish: $(OUT_OBJS) $(VARNISH_OUT_OBJS) $(VARNISH_ASM_OBJS)
	@$(ECHO) "[*** Creating "$@" shared library ***]"
	${CC} $(SHARED) -fPIC -Wl,-soname,libvmod_am.so $(LDFLAGS) \
	    $(OUT_OBJS) -Wl,--version-script=source/varnish/agent.map $(VARNISH_OUT_OBJS) $(VARNISH_ASM_OBJS) -o build/libvmod_am.so

varnish3: $(OUT_OBJS) $(VARNISH3_OUT_OBJS) $(VARNISH3_ASM_OBJS)
	@$(ECHO) "[*** Creating "$@" shared library ***]"
	${CC} $(SHARED) -fPIC -Wl,-soname,libvmod_am.so $(LDFLAGS) \
	    $(OUT_OBJS) -Wl,--version-script=source/varnish3/agent.map $(VARNISH3_OUT_OBJS) $(VARNISH3_ASM_OBJS) -o build/libvmod_am.so
	
agentadmin: $(OUT_OBJS) $(ADMIN_OUT_OBJS)
	@$(ECHO) "[*** Creating "$@" binary ***]"
	${CC} $(CFLAGS) $(LDFLAGS) $(OUT_OBJS) $(ADMIN_OUT_OBJS) -o build/agentadmin

tests: CFLAGS += $(COMPILEFLAG)DUNIT_TEST
tests: clean build version test_includes $(OUT_OBJS) $(TEST_OBJECTS) 
	@$(ECHO) "[***** Building "$@" binary *****]"
	${CC} $(CFLAGS) $(LDFLAGS) $(OUT_OBJS) $(TEST_OBJECTS) -o build$(PS)test
	
endif
