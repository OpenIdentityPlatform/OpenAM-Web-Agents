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

# make options:
#  64=1 builds 64bit binary
#  DEBUG=1 builds debug binary version

HTTPD24_VERSION=2.4.33
HTTPD22_VERSION=2.2.34
APR_VERSION=1.6.3
APR_UTIL_VERSION=1.6.1

ifndef 32
 64 := 1
endif

# DEBUG=1

VERSION := 4.1.0

ifneq ("$(PROGRAMFILES)$(ProgramFiles)","")
 OS_ARCH := WINNT
 RMALL := cmd /c del /F /Q
 RMDIR := cmd /c rmdir /S /Q
 SED := sed
 ECHO := echo
 MKDIR := cmd /c mkdir
 CP := cmd /c copy /E /Y
 CD := cd
 CAT :=cat
 EXEC := 
 REVISION := Revision: $(shell git rev-parse --short HEAD)
 BUILD_MACHINE := $(shell hostname)
 IDENT_DATE := $(shell powershell get-date -format "{dd.MM.yyyy}")
 PATHSEP=\\
 SUB=/
 COMPILEFLAG=/
 COMPILEOPTS=/Fd$@.pdb /Fo$(dir $@)
 OBJ=obj
 UTAR=7z x
 UBZIP=7z x
 WGET=powershell /c Invoke-WebRequest
else
 OS_ARCH := $(shell uname -s)
 OS_MARCH := $(shell uname -m)
 RMALL := rm -fr
 RMDIR := $(RMALL)
 SED := sed
 ECHO := echo
 MKDIR := mkdir -p
 CP := cp -r
 CD := cd
 EXEC := ./
 REVISION := Revision: $(shell git rev-parse --short HEAD)
 BUILD_MACHINE := $(shell hostname)
 IDENT_DATE := $(shell date +'%d.%m.%y')
 PATHSEP=/
 SUB=%
 COMPILEFLAG=-
 COMPILEOPTS=-c -o $@
 OBJ=o
 UTAR=tar xf
 UBZIP=bunzip2
 WGET=wget
 CAT=cat
endif

SED_ROPT := r
OS_ARCH_EXT := 
	
ifdef 64
 OS_BITS := _64bit
else
 OS_BITS :=
endif

PS=$(strip $(PATHSEP))

CFLAGS := $(COMPILEFLAG)I.$(PS)source $(COMPILEFLAG)I.$(PS)zlib $(COMPILEFLAG)I.$(PS)expat $(COMPILEFLAG)I.$(PS)pcre \
	  $(COMPILEFLAG)DHAVE_EXPAT_CONFIG_H $(COMPILEFLAG)DHAVE_PCRE_CONFIG_H

DIR := ${CURDIR}
OBJDIR := build

APACHE_SOURCES := source/apache/agent.c
APACHE22_SOURCES := source/apache/agent22.c
IIS_SOURCES := source/iis/agent.c
VARNISH_SOURCES := source/varnish/agent.c source/varnish/vcc_if.c
VARNISH_ASM_SOURCES := source/varnish/remap_64.s
VARNISH3_SOURCES := source/varnish3/agent.c source/varnish3/vcc_if.c
VARNISH3_ASM_SOURCES := source/varnish3/remap_64.s
ADMIN_SOURCES := source/admin.c source/admin_iis.c
SOURCES := $(filter-out $(ADMIN_SOURCES), $(wildcard source/*.c)) $(wildcard expat/*.c) $(wildcard pcre/*.c) $(wildcard zlib/*.c)
OBJECTS := $(SOURCES:.c=.$(OBJ))
OUT_OBJS := $(addprefix $(OBJDIR)/,$(OBJECTS))
ADMIN_OBJECTS := $(ADMIN_SOURCES:.c=.$(OBJ))
ADMIN_OUT_OBJS := $(addprefix $(OBJDIR)/,$(ADMIN_OBJECTS))
APACHE_OBJECTS := $(APACHE_SOURCES:.c=.$(OBJ))
APACHE22_OBJECTS := $(APACHE22_SOURCES:.c=.$(OBJ))
APACHE_OUT_OBJS := $(addprefix $(OBJDIR)/,$(APACHE_OBJECTS))
APACHE22_OUT_OBJS := $(addprefix $(OBJDIR)/,$(APACHE22_OBJECTS))
IIS_OBJECTS := $(IIS_SOURCES:.c=.$(OBJ))
IIS_OUT_OBJS := $(addprefix $(OBJDIR)/,$(IIS_OBJECTS))
VARNISH_OBJECTS := $(VARNISH_SOURCES:.c=.$(OBJ))
VARNISH_OUT_OBJS := $(addprefix $(OBJDIR)/,$(VARNISH_OBJECTS))
VARNISH_ASM_OBJS := $(addprefix $(OBJDIR)/,$(VARNISH_ASM_SOURCES:.s=.$(OBJ)))
VARNISH3_OBJECTS := $(VARNISH3_SOURCES:.c=.$(OBJ))
VARNISH3_ASM_OBJS := $(addprefix $(OBJDIR)/,$(VARNISH3_ASM_SOURCES:.s=.$(OBJ)))
VARNISH3_OUT_OBJS := $(addprefix $(OBJDIR)/,$(VARNISH3_OBJECTS))
ifdef TESTS
 TEST_FILES := $(addprefix tests/,$(addsuffix .c,$(TESTS)))
else
 TEST_FILES := $(filter-out test_MAIN.c, $(wildcard tests/*.c))
endif
TEST_SOURCES := $(wildcard cmocka/*.c) $(wildcard tests/*.c)
TEST_OBJECTS := $(addprefix $(OBJDIR)/,$(TEST_SOURCES:.c=.$(OBJ)))

$(APACHE_OUT_OBJS): CFLAGS += $(COMPILEFLAG)Iextlib/$(OS_ARCH)_$(OS_MARCH)/apache24/include \
	$(COMPILEFLAG)Iextlib/$(OS_ARCH)_$(OS_MARCH)/apache24/srclib/apr/include \
	$(COMPILEFLAG)Iextlib/$(OS_ARCH)_$(OS_MARCH)/apache24/srclib/apr-util/include \
        $(COMPILEFLAG)DAPACHE2 $(COMPILEFLAG)DAPACHE24
$(VARNISH_OUT_OBJS): CFLAGS += $(COMPILEFLAG)Iextlib/$(OS_ARCH)/varnish/include
$(VARNISH3_OUT_OBJS): CFLAGS += $(COMPILEFLAG)Iextlib/$(OS_ARCH)/varnish3/include
$(APACHE22_OUT_OBJS): CFLAGS += $(COMPILEFLAG)Iextlib/$(OS_ARCH)_$(OS_MARCH)/apache22/include \
	$(COMPILEFLAG)Iextlib/$(OS_ARCH)_$(OS_MARCH)/apache22/srclib/apr/include \
        $(COMPILEFLAG)Iextlib/$(OS_ARCH)_$(OS_MARCH)/apache22/srclib/apr-util/include \
	 $(COMPILEFLAG)DAPACHE2
$(TEST_OBJECTS): CFLAGS += $(COMPILEFLAG)I.$(PS)cmocka $(COMPILEFLAG)I.$(PS)tests $(COMPILEFLAG)I.$(PS)$(OBJDIR)$(PS)tests \
	$(COMPILEFLAG)DHAVE_SIGNAL_H $(COMPILEFLAG)DUNIT_TEST

ifeq ($(OS_ARCH), Linux)
 include Makefile.linux.mk
endif
ifeq ($(OS_ARCH), SunOS)
 include Makefile.solaris.mk
endif
ifeq ($(OS_ARCH), AIX)
 include Makefile.aix.mk
endif
ifeq ($(OS_ARCH), Darwin)
 include Makefile.macos.mk
 SED_ROPT := E
endif
ifeq ($(OS_ARCH), WINNT)
 include Makefile.windows.mk
endif

VERSION_NUM := $(shell $(ECHO) $(VERSION) | $(SED) "s/[^-\.0-9]*//g" | $(SED) "s/[\.-]/,/g" | $(SED) "/.*,$$/ s/$$/0/")

$(OBJDIR)/%.$(OBJ): %.c
	@$(ECHO) "[*** Compiling "$<" ***]"
	$(CC) $(CFLAGS) $< $(COMPILEOPTS)

$(OBJDIR)/%.$(OBJ): %.s
	@$(ECHO) "[*** Compiling "$<" ***]"
	$(CC) $(CFLAGS) $< $(COMPILEOPTS)
	
.DEFAULT_GOAL := all

all: apachezip

build:
	$(MKDIR) $(OBJDIR)$(PS)expat
	$(MKDIR) $(OBJDIR)$(PS)pcre
	$(MKDIR) $(OBJDIR)$(PS)zlib
	$(MKDIR) $(OBJDIR)$(PS)cmocka
	$(MKDIR) $(OBJDIR)$(PS)tests
	$(MKDIR) $(OBJDIR)$(PS)dist
	$(MKDIR) $(OBJDIR)$(PS)64
	$(MKDIR) $(OBJDIR)$(PS)64$(PS)expat
	$(MKDIR) $(OBJDIR)$(PS)64$(PS)pcre
	$(MKDIR) $(OBJDIR)$(PS)64$(PS)zlib
	$(MKDIR) $(OBJDIR)$(PS)64$(PS)source
	$(MKDIR) $(OBJDIR)$(PS)source$(PS)apache
	$(MKDIR) $(OBJDIR)$(PS)source$(PS)iis
	$(MKDIR) $(OBJDIR)$(PS)64$(PS)source$(PS)iis
	$(MKDIR) $(OBJDIR)$(PS)source$(PS)varnish
	$(MKDIR) $(OBJDIR)$(PS)source$(PS)varnish3

version:
	@$(ECHO) "[***** Updating version.h *****]"
	-$(RMALL) source$(PS)version.h
	pwd
	$(CAT) source$(PS)version.template 
	$(SED) -e "s$(SUB)_REVISION_$(SUB)$(REVISION)$(SUB)g" \
	    -e "s$(SUB)_IDENT_DATE_$(SUB)$(IDENT_DATE)$(SUB)g" \
	    -e "s$(SUB)_BUILD_MACHINE_$(SUB)$(BUILD_MACHINE)$(SUB)g" \
	    -e "s$(SUB)_VERSION_NUM_$(SUB)$(VERSION_NUM)$(SUB)g" \
	    -e "s$(SUB)_CONTAINER_$(SUB)$(CONTAINER)$(SUB)g" \
	    -e "s$(SUB)_VERSION_$(SUB)$(VERSION)$(SUB)g" source$(PS)version.template >> source$(PS)version.h
	$(CAT) source$(PS)version.h
clean:
	-$(RMDIR) $(OBJDIR)
	-$(RMALL) source$(PS)version.h

test_includes:
	@$(ECHO) "[***** Creating tests.h *****]"
	-$(MKDIR) $(OBJDIR)$(PS)tests
	-$(RMALL) $(OBJDIR)$(PS)tests$(PS)tests.h
	$(SED) -$(SED_ROPT) "/.*static.+/d" $(TEST_FILES) | $(SED) -$(SED_ROPT)n "/.*\(void[ \t]*\*\*[ \t]*state\)/p" | sed -$(SED_ROPT) "s/\{/\;/g" > $(OBJDIR)$(PS)tests$(PS)tests.h.template
	$(CP) $(OBJDIR)$(PS)tests$(PS)tests.h.template $(OBJDIR)$(PS)tests$(PS)tests.h
	$(ECHO) "const struct CMUnitTest tests[] = {" >> $(OBJDIR)$(PS)tests$(PS)tests.h
	$(SED) -$(SED_ROPT)n "s/void (test_.*[^\(])\(.*/cmocka_unit_test(\1),/p" $(OBJDIR)$(PS)tests$(PS)tests.h.template >> $(OBJDIR)$(PS)tests$(PS)tests.h
	$(ECHO) "};" >> $(OBJDIR)$(PS)tests$(PS)tests.h
	$(SED) -ie "s$(SUB)\"$(SUB) $(SUB)g" $(OBJDIR)$(PS)tests$(PS)tests.h

apr:
	-$(WGET) http://mirrors.ukfast.co.uk/sites/ftp.apache.org/apr/apr-${APR_VERSION}.tar.bz2
	-$(UBZIP) apr-${APR_VERSION}.tar.bz2; $(UTAR) apr-${APR_VERSION}.tar
	-$(WGET) http://mirrors.ukfast.co.uk/sites/ftp.apache.org/apr/apr-util-${APR_UTIL_VERSION}.tar.bz2
	-$(UBZIP) apr-util-${APR_UTIL_VERSION}.tar.bz2; $(UTAR) apr-util-${APR_UTIL_VERSION}.tar
apache-src: apr
	-$(WGET) http://mirrors.ukfast.co.uk/sites/ftp.apache.org/httpd/httpd-${HTTPD24_VERSION}.tar.bz2
	-$(UBZIP) httpd-${HTTPD24_VERSION}.tar.bz2; $(UTAR) httpd-${HTTPD24_VERSION}.tar
	-$(MKDIR) extlib/$(OS_ARCH)_$(OS_MARCH)
	-$(CP) httpd-${HTTPD24_VERSION} extlib/$(OS_ARCH)_$(OS_MARCH)/apache24
	-$(CP) apr-${APR_VERSION} extlib/$(OS_ARCH)_$(OS_MARCH)/apache24/srclib/apr
	-$(CP) apr-util-${APR_UTIL_VERSION} extlib/$(OS_ARCH)_$(OS_MARCH)/apache24/srclib/apr-util
	-$(RMALL) httpd-* apr-*
	-$(CD) extlib/$(OS_ARCH)_$(OS_MARCH)/apache24; ./configure --with-included-apr
apache22-src: apr
	-$(WGET) https://archive.apache.org/dist/httpd/httpd-${HTTPD22_VERSION}.tar.bz2
	-$(UBZIP) httpd-${HTTPD22_VERSION}.tar.bz2; $(UTAR) httpd-${HTTPD22_VERSION}.tar
	-$(MKDIR) extlib/$(OS_ARCH)_$(OS_MARCH)
	-$(CP) httpd-${HTTPD22_VERSION} extlib/$(OS_ARCH)_$(OS_MARCH)/apache22
	-$(CP) apr-${APR_VERSION} extlib/$(OS_ARCH)_$(OS_MARCH)/apache22/srclib/apr
	-$(CP) apr-util-${APR_UTIL_VERSION} extlib/$(OS_ARCH)_$(OS_MARCH)/apache22/srclib/apr-util
	-$(RMALL) httpd-* apr-*
	-$(CD) extlib/$(OS_ARCH)_$(OS_MARCH)/apache22; ./configure --with-included-apr
apachezip: CFLAGS += $(COMPILEFLAG)DSERVER_VERSION='"2.4.x"'
apachezip: CONTAINER = $(strip Apache 2.4 $(OS_ARCH)$(OS_ARCH_EXT) $(subst _,,$(OS_BITS)))
apachezip: clean build version apache-src apache agentadmin
	@$(ECHO) "[***** Building Apache 2.4 agent archive *****]"
	-$(MKDIR) $(OBJDIR)$(PS)web_agents
	-$(MKDIR) $(OBJDIR)$(PS)web_agents$(PS)apache24_agent
	-$(MKDIR) $(OBJDIR)$(PS)web_agents$(PS)apache24_agent$(PS)bin
	-$(MKDIR) $(OBJDIR)$(PS)web_agents$(PS)apache24_agent$(PS)lib
	-$(MKDIR) $(OBJDIR)$(PS)web_agents$(PS)apache24_agent$(PS)legal
	-$(MKDIR) $(OBJDIR)$(PS)web_agents$(PS)apache24_agent$(PS)instances
	-$(MKDIR) $(OBJDIR)$(PS)web_agents$(PS)apache24_agent$(PS)log
	-$(MKDIR) $(OBJDIR)$(PS)web_agents$(PS)apache24_agent$(PS)config
	-$(CP) $(OBJDIR)$(PS)agentadmin* $(OBJDIR)$(PS)web_agents$(PS)apache24_agent$(PS)bin$(PS)
	-$(CP) $(OBJDIR)$(PS)mod_openam.so $(OBJDIR)$(PS)web_agents$(PS)apache24_agent$(PS)lib$(PS)
	-$(CP) $(OBJDIR)$(PS)mod_openam.dll $(OBJDIR)$(PS)web_agents$(PS)apache24_agent$(PS)lib$(PS)
	-$(CP) $(OBJDIR)$(PS)mod_openam.pdb $(OBJDIR)$(PS)web_agents$(PS)apache24_agent$(PS)lib$(PS)
	-$(CP) config$(PS)* $(OBJDIR)$(PS)web_agents$(PS)apache24_agent$(PS)config$(PS)
	-$(CP) legal$(PS)* $(OBJDIR)$(PS)web_agents$(PS)apache24_agent$(PS)legal$(PS)
	$(CD) $(OBJDIR) && $(EXEC)agentadmin --a Apache_v24_$(OS_ARCH)$(OS_ARCH_EXT)$(OS_BITS)_$(VERSION).zip web_agents

apache22_pre:
	-$(CP) source$(PS)apache$(PS)agent.c source$(PS)apache$(PS)agent22.c

apache22_post:
	-$(RMALL) source$(PS)apache$(PS)agent22.c

apache22zip: CFLAGS += $(COMPILEFLAG)DSERVER_VERSION='"2.2.x"'
apache22zip: CONTAINER = $(strip Apache 2.2 $(OS_ARCH)$(OS_ARCH_EXT) $(subst _,,$(OS_BITS)))
apache22zip: clean build version apache22-src apache22 agentadmin
	@$(ECHO) "[***** Building Apache 2.2 agent archive *****]"
	-$(MKDIR) $(OBJDIR)$(PS)web_agents
	-$(MKDIR) $(OBJDIR)$(PS)web_agents$(PS)apache22_agent
	-$(MKDIR) $(OBJDIR)$(PS)web_agents$(PS)apache22_agent$(PS)bin
	-$(MKDIR) $(OBJDIR)$(PS)web_agents$(PS)apache22_agent$(PS)lib
	-$(MKDIR) $(OBJDIR)$(PS)web_agents$(PS)apache22_agent$(PS)legal
	-$(MKDIR) $(OBJDIR)$(PS)web_agents$(PS)apache22_agent$(PS)instances
	-$(MKDIR) $(OBJDIR)$(PS)web_agents$(PS)apache22_agent$(PS)log
	-$(MKDIR) $(OBJDIR)$(PS)web_agents$(PS)apache22_agent$(PS)config
	-$(CP) $(OBJDIR)$(PS)agentadmin* $(OBJDIR)$(PS)web_agents$(PS)apache22_agent$(PS)bin$(PS)
	-$(CP) $(OBJDIR)$(PS)mod_openam.so $(OBJDIR)$(PS)web_agents$(PS)apache22_agent$(PS)lib$(PS)
	-$(CP) $(OBJDIR)$(PS)mod_openam.dll $(OBJDIR)$(PS)web_agents$(PS)apache22_agent$(PS)lib$(PS)
	-$(CP) $(OBJDIR)$(PS)mod_openam.pdb $(OBJDIR)$(PS)web_agents$(PS)apache22_agent$(PS)lib$(PS)
	-$(CP) config$(PS)* $(OBJDIR)$(PS)web_agents$(PS)apache22_agent$(PS)config$(PS)
	-$(CP) legal$(PS)* $(OBJDIR)$(PS)web_agents$(PS)apache22_agent$(PS)legal$(PS)
	$(CD) $(OBJDIR) && $(EXEC)agentadmin --a Apache_v22_$(OS_ARCH)$(OS_ARCH_EXT)$(OS_BITS)_$(VERSION).zip web_agents

ibmhttp7zip: CFLAGS += $(COMPILEFLAG)DSERVER_VERSION='"2.2.x (IBM HTTP Server 7)"'
ibmhttp7zip: VENDOR_EXT = _ibmhttp
ibmhttp7zip: CONTAINER = $(strip IBM HTTP Server 7 $(OS_ARCH)$(OS_ARCH_EXT) $(subst _,,$(OS_BITS)))
ibmhttp7zip: clean build version apache22 agentadmin
	@$(ECHO) "[***** Building IBM HTTP Server 7 agent archive *****]"
	-$(MKDIR) $(OBJDIR)$(PS)web_agents
	-$(MKDIR) $(OBJDIR)$(PS)web_agents$(PS)httpserver7_agent
	-$(MKDIR) $(OBJDIR)$(PS)web_agents$(PS)httpserver7_agent$(PS)bin
	-$(MKDIR) $(OBJDIR)$(PS)web_agents$(PS)httpserver7_agent$(PS)lib
	-$(MKDIR) $(OBJDIR)$(PS)web_agents$(PS)httpserver7_agent$(PS)legal
	-$(MKDIR) $(OBJDIR)$(PS)web_agents$(PS)httpserver7_agent$(PS)instances
	-$(MKDIR) $(OBJDIR)$(PS)web_agents$(PS)httpserver7_agent$(PS)log
	-$(MKDIR) $(OBJDIR)$(PS)web_agents$(PS)httpserver7_agent$(PS)config
	-$(CP) $(OBJDIR)$(PS)agentadmin* $(OBJDIR)$(PS)web_agents$(PS)httpserver7_agent$(PS)bin$(PS)
	-$(CP) $(OBJDIR)$(PS)mod_openam.so $(OBJDIR)$(PS)web_agents$(PS)httpserver7_agent$(PS)lib$(PS)
	-$(CP) $(OBJDIR)$(PS)mod_openam.dll $(OBJDIR)$(PS)web_agents$(PS)httpserver7_agent$(PS)lib$(PS)
	-$(CP) $(OBJDIR)$(PS)mod_openam.pdb $(OBJDIR)$(PS)web_agents$(PS)httpserver7_agent$(PS)lib$(PS)
	-$(CP) config$(PS)* $(OBJDIR)$(PS)web_agents$(PS)httpserver7_agent$(PS)config$(PS)
	-$(CP) legal$(PS)* $(OBJDIR)$(PS)web_agents$(PS)httpserver7_agent$(PS)legal$(PS)
	$(CD) $(OBJDIR) && $(EXEC)agentadmin --a IBMHTTP_v7_$(OS_ARCH)$(OS_ARCH_EXT)$(OS_BITS)_$(VERSION).zip web_agents

iiszip: CFLAGS += $(COMPILEFLAG)DSERVER_VERSION='"7.5, 8.x"'
iiszip: CONTAINER = $(strip IIS 7.5, 8.x $(OS_ARCH)$(OS_ARCH_EXT) 32\/64bit)
iiszip: clean build version iis
	@$(ECHO) "[***** Building IIS agent archive *****]"
	-$(MKDIR) $(OBJDIR)$(PS)web_agents
	-$(MKDIR) $(OBJDIR)$(PS)web_agents$(PS)iis_agent
	-$(MKDIR) $(OBJDIR)$(PS)web_agents$(PS)iis_agent$(PS)bin
	-$(MKDIR) $(OBJDIR)$(PS)web_agents$(PS)iis_agent$(PS)lib
	-$(MKDIR) $(OBJDIR)$(PS)web_agents$(PS)iis_agent$(PS)legal
	-$(MKDIR) $(OBJDIR)$(PS)web_agents$(PS)iis_agent$(PS)instances
	-$(MKDIR) $(OBJDIR)$(PS)web_agents$(PS)iis_agent$(PS)log
	-$(MKDIR) $(OBJDIR)$(PS)web_agents$(PS)iis_agent$(PS)config
	-$(CP) $(OBJDIR)$(PS)dist$(PS)agentadmin* $(OBJDIR)$(PS)web_agents$(PS)iis_agent$(PS)bin$(PS)
	-$(CP) $(OBJDIR)$(PS)dist$(PS)mod_iis_openam* $(OBJDIR)$(PS)web_agents$(PS)iis_agent$(PS)lib$(PS)
	-$(CP) config$(PS)* $(OBJDIR)$(PS)web_agents$(PS)iis_agent$(PS)config$(PS)
	-$(CP) legal$(PS)* $(OBJDIR)$(PS)web_agents$(PS)iis_agent$(PS)legal$(PS)
	$(CD) $(OBJDIR) && $(EXEC)agentadmin --a IIS_$(OS_ARCH)_$(VERSION).zip web_agents

varnishzip: CFLAGS += $(COMPILEFLAG)DSERVER_VERSION='"4.1.x"'
varnishzip: CONTAINER = $(strip Varnish 4.1.x $(OS_ARCH)$(OS_ARCH_EXT) $(subst _,,$(OS_BITS)))
varnishzip: clean build version varnish agentadmin
	@$(ECHO) "[***** Building Varnish agent archive *****]"
	-$(MKDIR) $(OBJDIR)$(PS)web_agents
	-$(MKDIR) $(OBJDIR)$(PS)web_agents$(PS)varnish_agent
	-$(MKDIR) $(OBJDIR)$(PS)web_agents$(PS)varnish_agent$(PS)bin
	-$(MKDIR) $(OBJDIR)$(PS)web_agents$(PS)varnish_agent$(PS)lib
	-$(MKDIR) $(OBJDIR)$(PS)web_agents$(PS)varnish_agent$(PS)legal
	-$(MKDIR) $(OBJDIR)$(PS)web_agents$(PS)varnish_agent$(PS)instances
	-$(MKDIR) $(OBJDIR)$(PS)web_agents$(PS)varnish_agent$(PS)log
	-$(MKDIR) $(OBJDIR)$(PS)web_agents$(PS)varnish_agent$(PS)config
	-$(CP) $(OBJDIR)$(PS)agentadmin* $(OBJDIR)$(PS)web_agents$(PS)varnish_agent$(PS)bin$(PS)
	-$(CP) $(OBJDIR)$(PS)libvmod_am.so $(OBJDIR)$(PS)web_agents$(PS)varnish_agent$(PS)lib$(PS)
	-$(CP) config$(PS)* $(OBJDIR)$(PS)web_agents$(PS)varnish_agent$(PS)config$(PS)
	-$(CP) legal$(PS)* $(OBJDIR)$(PS)web_agents$(PS)varnish_agent$(PS)legal$(PS)
	$(CD) $(OBJDIR) && $(EXEC)agentadmin --a Varnish_v4_$(OS_ARCH)$(OS_ARCH_EXT)$(OS_BITS)_$(VERSION).zip web_agents

varnish3zip: CFLAGS += $(COMPILEFLAG)DSERVER_VERSION='"3.0.x"'
varnish3zip: CONTAINER = $(strip Varnish 3.0.x $(OS_ARCH)$(OS_ARCH_EXT) $(subst _,,$(OS_BITS)))
varnish3zip: clean build version varnish3 agentadmin
	@$(ECHO) "[***** Building Varnish agent archive *****]"
	-$(MKDIR) $(OBJDIR)$(PS)web_agents
	-$(MKDIR) $(OBJDIR)$(PS)web_agents$(PS)varnish3_agent
	-$(MKDIR) $(OBJDIR)$(PS)web_agents$(PS)varnish3_agent$(PS)bin
	-$(MKDIR) $(OBJDIR)$(PS)web_agents$(PS)varnish3_agent$(PS)lib
	-$(MKDIR) $(OBJDIR)$(PS)web_agents$(PS)varnish3_agent$(PS)legal
	-$(MKDIR) $(OBJDIR)$(PS)web_agents$(PS)varnish3_agent$(PS)instances
	-$(MKDIR) $(OBJDIR)$(PS)web_agents$(PS)varnish3_agent$(PS)log
	-$(MKDIR) $(OBJDIR)$(PS)web_agents$(PS)varnish3_agent$(PS)config
	-$(CP) $(OBJDIR)$(PS)agentadmin* $(OBJDIR)$(PS)web_agents$(PS)varnish3_agent$(PS)bin$(PS)
	-$(CP) $(OBJDIR)$(PS)libvmod_am.so $(OBJDIR)$(PS)web_agents$(PS)varnish3_agent$(PS)lib$(PS)
	-$(CP) config$(PS)* $(OBJDIR)$(PS)web_agents$(PS)varnish3_agent$(PS)config$(PS)
	-$(CP) $(OBJDIR)$(PS)web_agents$(PS)varnish3_agent$(PS)config$(PS)agent.vcl3.template $(OBJDIR)$(PS)web_agents$(PS)varnish3_agent$(PS)config$(PS)agent.vcl.template
	-$(RMALL) $(OBJDIR)$(PS)web_agents$(PS)varnish3_agent$(PS)config$(PS)agent.vcl3.template
	-$(CP) legal$(PS)* $(OBJDIR)$(PS)web_agents$(PS)varnish3_agent$(PS)legal$(PS)
	$(CD) $(OBJDIR) && $(EXEC)agentadmin --a Varnish_v3_$(OS_ARCH)$(OS_ARCH_EXT)$(OS_BITS)_$(VERSION).zip web_agents
	
