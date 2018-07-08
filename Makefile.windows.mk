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

ifndef	WINDOWS_MK_INCLUDED
WINDOWS_MK_INCLUDED := true

CC32 := $(shell powershell 'Get-Command cl.exe | Where-Object {$$_.Definition -ne "" -and $$_.Definition -notlike "*amd64*"} | Select-Object -ExpandProperty Definition')
CC = cl
LINK32 := $(shell powershell 'Get-Command link.exe | Where-Object {$$_.Definition -ne "" -and $$_.Definition -notlike "*amd64*"} | Select-Object -ExpandProperty Definition')
LIB32_VC := $(shell powershell 'Get-Command link.exe | Where-Object {$$_.Definition -ne "" -and $$_.Definition -notlike "*amd64*"} | Select-Object -ExpandProperty Definition | split-path -parent | split-path -parent')
LIB32_SDK := $(shell powershell 'Get-ChildItem "$(WindowsSdkDir)" -recurse | Where-Object {$$_.PSIsContainer -eq $$true -and $$_.Name -eq "um"} | Select-Object -Index 1 | Select-Object -Expand FullName')
LINK = link
RC = rc
SHARED = /DLL

CFLAGS  += /O2 /Oi /GL /Gy /GT /D _CRT_SECURE_NO_WARNINGS /wd4996 /wd4101 /wd4244 /wd4995 /wd4275 \
	/EHa /nologo /Zi /errorReport:none /MP /Gm- /W3 /c /TC /D WIN32 /D _WIN32 /D ZLIB_WINAPI /D PCRE_STATIC

LDFLAGS += /SUBSYSTEM:CONSOLE /NOLOGO /INCREMENTAL:NO /errorReport:none /MANIFEST:NO \
	/OPT:REF /OPT:ICF /LTCG /DYNAMICBASE /NXCOMPAT /DEBUG
	
LIBS = kernel32.lib user32.lib ws2_32.lib crypt32.lib advapi32.lib shlwapi.lib shell32.lib secur32.lib

$(IIS_OUT_OBJS): COMPILEOPTS += /TP
$(TEST_OBJECTS): CFLAGS += /D HAVE_MSVC_THREAD_LOCAL_STORAGE /D HAVE__SNPRINTF_S /D HAVE__VSNPRINTF_S /D UNIT_TESTING_DEBUG=1

ifneq ($(findstring $(MAKECMDGOALS), iis32 iis64 iiszip),)
LIB64ENV := $(shell echo "$(LIBPATH)" | findstr amd64)

ifeq (,$(LIB64ENV))
$(error Missing support for 64 build environment)
endif

ifeq (,$(CC32))
CC32 := $(shell powershell 'Get-Command cl.exe | Where-Object {$$_.Definition -like "*amd64*"} | Select-Object -ExpandProperty Definition | split-path -parent | split-path -parent')\cl.exe
endif
ifeq (,$(LINK32))
LINK32 := $(shell powershell 'Get-Command cl.exe | Where-Object {$$_.Definition -like "*amd64*"} | Select-Object -ExpandProperty Definition | split-path -parent | split-path -parent')\link.exe
endif
ifeq (,$(LIB32_VC))
LIB32_VC := $(shell powershell 'Get-Command cl.exe | Where-Object {$$_.Definition -like "*amd64*"} | Select-Object -ExpandProperty Definition | split-path -parent | split-path -parent | split-path -parent')
endif

else
ifdef 64
 LDFLAGS += /MACHINE:X64
 OS_MARCH := _64
else
 LDFLAGS += /MACHINE:X86
 OS_MARCH :=
endif
endif

ifdef DEBUG
 CFLAGS += /MTd /D _DEBUG /D DEBUG
else
 CFLAGS += /MT
endif
	
libopenam: $(OUT_OBJS)
	@$(ECHO) "[*** Creating "$@" shared library ***]"
	-$(RMALL) $(OBJDIR)$(PS)version.*
	$(SED) -e "s$(SUB)_FILE_NAME_$(SUB)libopenam.dll$(SUB)g" \
	       -e "s$(SUB)_FILE_TYPE_$(SUB)VFT_DLL$(SUB)g" < source$(PS)version.rc.template > $(OBJDIR)$(PS)version.rc
	$(RC)  /l 0x0409 /nologo /fo $(OBJDIR)$(PS)version.res $(OBJDIR)$(PS)version.rc
	${LINK} $(SHARED) $(LDFLAGS) $(OUT_OBJS) $(OBJDIR)$(PS)version.res /OUT:build\$@.dll /PDB:build\$@.pdb \
	    $(LIBS)
	
apache: $(OUT_OBJS) $(APACHE_OUT_OBJS)
	@$(ECHO) "[*** Creating "$@" shared library ***]"
	-$(RMALL) $(OBJDIR)$(PS)version.*
	$(SED) -e "s$(SUB)_FILE_NAME_$(SUB)mod_openam.dll$(SUB)g" \
	       -e "s$(SUB)_FILE_TYPE_$(SUB)VFT_DLL$(SUB)g" < source$(PS)version.rc.template > $(OBJDIR)$(PS)version.rc
	$(RC)  /l 0x0409 /nologo /fo $(OBJDIR)$(PS)version.res $(OBJDIR)$(PS)version.rc
	${LINK} $(SHARED) $(LDFLAGS) $(OUT_OBJS) $(APACHE_OUT_OBJS) $(OBJDIR)$(PS)version.res /OUT:build\mod_openam.dll \
	    /PDB:build\mod_openam.pdb $(LIBS) \
	    extlib/$(OS_ARCH)$(OS_MARCH)/apache24/lib/libapr-1.lib extlib/$(OS_ARCH)$(OS_MARCH)/apache24/lib/libaprutil-1.lib \
	    extlib/$(OS_ARCH)$(OS_MARCH)/apache24/lib/libhttpd.lib

apache22: apache22_pre $(OUT_OBJS) $(APACHE22_OUT_OBJS) apache22_post
	@$(ECHO) "[*** Creating "$@" shared library ***]"
	-$(RMALL) $(OBJDIR)$(PS)version.*
	$(SED) -e "s$(SUB)_FILE_NAME_$(SUB)mod_openam.dll$(SUB)g" \
	       -e "s$(SUB)_FILE_TYPE_$(SUB)VFT_DLL$(SUB)g" < source$(PS)version.rc.template > $(OBJDIR)$(PS)version.rc
	$(RC)  /l 0x0409 /nologo /fo $(OBJDIR)$(PS)version.res $(OBJDIR)$(PS)version.rc
	${LINK} $(SHARED) $(LDFLAGS) $(OUT_OBJS) $(APACHE22_OUT_OBJS) $(OBJDIR)$(PS)version.res /OUT:build\mod_openam.dll \
	    /PDB:build\mod_openam.pdb $(LIBS) \
	    extlib/$(OS_ARCH)$(OS_MARCH)/apache22/lib/libapr-1.lib extlib/$(OS_ARCH)$(OS_MARCH)/apache22/lib/libaprutil-1.lib \
	    extlib/$(OS_ARCH)$(OS_MARCH)/apache22/lib/libhttpd.lib
	
iis:	iis32 agentadmin_iis iisclean iis64   

iisclean:
	-$(RMALL) $(OBJDIR)$(PS)*
	-$(RMALL) $(OBJDIR)$(PS)expat$(PS)*
	-$(RMALL) $(OBJDIR)$(PS)pcre$(PS)*
	-$(RMALL) $(OBJDIR)$(PS)zlib$(PS)*
	-$(RMALL) $(OBJDIR)$(PS)source$(PS)*
	-$(RMALL) $(OBJDIR)$(PS)source$(PS)iis$(PS)*
	
iis32: CC = $(CC32)
iis32: LDFLAGS += /MACHINE:X86
iis32: $(OUT_OBJS) $(IIS_OUT_OBJS)
	@$(ECHO) "[*** Creating "$@" shared library ***]"
	-$(RMALL) $(OBJDIR)$(PS)version.*
	$(SED) -e "s$(SUB)_FILE_NAME_$(SUB)mod_iis_openam_32.dll$(SUB)g" \
	       -e "s$(SUB)_FILE_TYPE_$(SUB)VFT_DLL$(SUB)g" < source$(PS)version.rc.template > $(OBJDIR)$(PS)version.rc
	$(RC)  /l 0x0409 /nologo /fo $(OBJDIR)$(PS)version.res $(OBJDIR)$(PS)version.rc
	"${LINK32}" $(SHARED) /LIBPATH:"$(LIB32_SDK)\x86" /LIBPATH:"$(LIB32_VC)\LIB" $(LDFLAGS) $(OUT_OBJS) $(IIS_OUT_OBJS) \
	    $(OBJDIR)$(PS)version.res /OUT:build\mod_iis_openam_32.dll \
	    /PDB:build\mod_iis_openam_32.pdb $(LIBS) /EXPORT:RegisterModule oleaut32.lib
	$(CP) $(OBJDIR)$(PS)mod_iis_openam_32.dll $(OBJDIR)$(PS)dist
	$(CP) $(OBJDIR)$(PS)mod_iis_openam_32.pdb $(OBJDIR)$(PS)dist

$(OBJDIR)/64/%.$(OBJ): %.c
	@$(ECHO) "[*** Compiling "$<" ***]"
	"$(CC)" $(CFLAGS) $< $(COMPILEOPTS)

OUT_OBJS_64 := $(addprefix $(OBJDIR)/64/,$(SOURCES:.c=.$(OBJ)))
IIS_OUT_OBJS_64 := $(addprefix $(OBJDIR)/64/,$(IIS_SOURCES:.c=.$(OBJ)))
$(IIS_OUT_OBJS_64): COMPILEOPTS += /TP
	
iis64: LDFLAGS += /MACHINE:X64
iis64: $(OUT_OBJS_64) $(IIS_OUT_OBJS_64)
	@$(ECHO) "[*** Creating "$@" shared library ***]"
	-$(RMALL) $(OBJDIR)$(PS)version.*
	$(SED) -e "s$(SUB)_FILE_NAME_$(SUB)mod_iis_openam_64.dll$(SUB)g" \
	       -e "s$(SUB)_FILE_TYPE_$(SUB)VFT_DLL$(SUB)g" < source$(PS)version.rc.template > $(OBJDIR)$(PS)version.rc
	$(RC)  /l 0x0409 /nologo /fo $(OBJDIR)$(PS)version.res $(OBJDIR)$(PS)version.rc
	${LINK} $(SHARED) $(LDFLAGS) $(OUT_OBJS_64) $(IIS_OUT_OBJS_64) $(OBJDIR)$(PS)version.res /OUT:build\mod_iis_openam_64.dll \
	    /PDB:build\mod_iis_openam_64.pdb $(LIBS) /EXPORT:RegisterModule oleaut32.lib
	$(CP) $(OBJDIR)$(PS)mod_iis_openam_64.dll $(OBJDIR)$(PS)dist
	$(CP) $(OBJDIR)$(PS)mod_iis_openam_64.pdb $(OBJDIR)$(PS)dist
	$(CP) $(OBJDIR)$(PS)dist$(PS)agentadmin.exe $(OBJDIR)$(PS)
	
varnish: 
	$(error Varnish target is not supported on this platform)

varnish3: 
	$(error Varnish target is not supported on this platform)
	
agentadmin: $(OUT_OBJS) $(ADMIN_OUT_OBJS)
	@$(ECHO) "[*** Creating "$@" binary ***]"
	-$(RMALL) $(OBJDIR)$(PS)version.*
	$(SED) -e "s$(SUB)_FILE_NAME_$(SUB)agentadmin.exe$(SUB)g" \
	       -e "s$(SUB)DESCRIPTION$(SUB)\"OpenAM Web Agent Administration Utility\"$(SUB)g" \
	       -e "s$(SUB)_FILE_TYPE_$(SUB)VFT_APP$(SUB)g" < source$(PS)version.rc.template > $(OBJDIR)$(PS)version.rc
	$(RC)  /l 0x0409 /nologo /fo $(OBJDIR)$(PS)version.res $(OBJDIR)$(PS)version.rc
	${LINK} $(LDFLAGS) $(OUT_OBJS) $(ADMIN_OUT_OBJS) $(OBJDIR)$(PS)version.res /OUT:build\$@.exe /PDB:build\$@.pdb \
	    $(LIBS) ole32.lib oleaut32.lib ahadmin.lib

agentadmin_iis: CC = $(CC32)
agentadmin_iis: LDFLAGS += /MACHINE:X86
agentadmin_iis: $(OUT_OBJS) $(ADMIN_OUT_OBJS)
	@$(ECHO) "[*** Creating agentadmin binary ***]"
	-$(RMALL) $(OBJDIR)$(PS)version.*
	$(SED) -e "s$(SUB)_FILE_NAME_$(SUB)agentadmin.exe$(SUB)g" \
	       -e "s$(SUB)DESCRIPTION$(SUB)\"OpenAM Web Agent Administration Utility\"$(SUB)g" \
	       -e "s$(SUB)_FILE_TYPE_$(SUB)VFT_APP$(SUB)g" < source$(PS)version.rc.template > $(OBJDIR)$(PS)version.rc
	$(RC)  /l 0x0409 /nologo /fo $(OBJDIR)$(PS)version.res $(OBJDIR)$(PS)version.rc
	"${LINK32}" /LIBPATH:"$(LIB32_SDK)\x86" /LIBPATH:"$(LIB32_VC)\LIB" $(LDFLAGS) $(OUT_OBJS) \
	    $(ADMIN_OUT_OBJS) $(OBJDIR)$(PS)version.res /OUT:build\agentadmin.exe /PDB:build\agentadmin.pdb \
	    $(LIBS) ole32.lib oleaut32.lib ahadmin.lib
	$(CP) $(OBJDIR)$(PS)agentadmin.pdb $(OBJDIR)$(PS)dist
	$(CP) $(OBJDIR)$(PS)agentadmin.exe $(OBJDIR)$(PS)dist

tests: CFLAGS += $(COMPILEFLAG)DUNIT_TEST
tests: clean build version test_includes $(OUT_OBJS) $(TEST_OBJECTS) 
	@$(ECHO) "[***** Building "$@" binary *****]"
	-$(RMALL) $(OBJDIR)$(PS)version.*
	$(SED) -e "s$(SUB)_FILE_NAME_$(SUB)test.exe$(SUB)g" \
	       -e "s$(SUB)DESCRIPTION$(SUB)\"OpenAM Web Agent Test Utility\"$(SUB)g" \
	       -e "s$(SUB)_FILE_TYPE_$(SUB)VFT_APP$(SUB)g" < source$(PS)version.rc.template > $(OBJDIR)$(PS)version.rc
	$(RC)  /l 0x0409 /nologo /fo $(OBJDIR)$(PS)version.res $(OBJDIR)$(PS)version.rc
	${LINK} $(LDFLAGS) $(OUT_OBJS) $(TEST_OBJECTS) $(OBJDIR)$(PS)version.res /OUT:build$(PS)test.exe $(LIBS)
	
endif
