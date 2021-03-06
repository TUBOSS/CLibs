#-------------------------------------------------------------------------------
# Copyright (c) 2010, Jean-David Gadina - www.xs-labs.com
# Distributed under the Boost Software License, Version 1.0.
# 
# Boost Software License - Version 1.0 - August 17th, 2003
# 
# Permission is hereby granted, free of charge, to any person or organization
# obtaining a copy of the software and accompanying documentation covered by
# this license (the "Software") to use, reproduce, display, distribute,
# execute, and transmit the Software, and to prepare derivative works of the
# Software, and to permit third-parties to whom the Software is furnished to
# do so, all subject to the following:
# 
# The copyright notices in the Software and this entire statement, including
# the above license grant, this restriction and the following disclaimer,
# must be included in all copies of the Software, in whole or in part, and
# all derivative works of the Software, unless such copies or derivative
# works are solely in the form of machine-executable object code generated by
# a source language processor.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE, TITLE AND NON-INFRINGEMENT. IN NO EVENT
# SHALL THE COPYRIGHT HOLDERS OR ANYONE DISTRIBUTING THE SOFTWARE BE LIABLE
# FOR ANY DAMAGES OR OTHER LIABILITY, WHETHER IN CONTRACT, TORT OR OTHERWISE,
# ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
# DEALINGS IN THE SOFTWARE.
#-------------------------------------------------------------------------------

# $Id$

CC                      = gcc
LIBTOOL_STATIC          = libtool
LIBTOOL_DYNAMIC         = libtool
ARGS_CC                 = -std=c99 -Os -pedantic -Werror -Wall -Wextra -Wbad-function-cast -Wdeclaration-after-statement -Werror-implicit-function-declaration -Wmissing-braces -Wmissing-declarations -Wmissing-field-initializers -Wmissing-prototypes -Wnested-externs -Wold-style-definition -Wparentheses -Wreturn-type -Wshadow -Wsign-compare -Wstrict-prototypes -Wswitch -Wuninitialized -Wunknown-pragmas -Wunused-function -Wunused-label -Wunused-parameter -Wunused-value -Wunused-variable
ARGS_LIBTOOL_STATIC     = -static
ARGS_LIBTOOL_DYLIB      = -dynamic -flat_namespace -lSystem -undefined suppress -macosx_version_min 10.6

EXT_CODE                = .c
EXT_HEADERS             = .h
EXT_OBJECT              = .o
EXT_LIB_STATIC          = .a
EXT_LIB_DYNAMIC         = .dylib

DIR_BUILD               = build/
DIR_SRC                 = source/
DIR_INC                 = $(DIR_SRC)include/
DIR_INSTALL             = /usr/local/xs-clibs/
DIR_INSTALL_LIB         = $(DIR_INSTALL)lib/
DIR_INSTALL_INC         = $(DIR_INSTALL)include/

.SUFFIXES:
.SUFFIXES: $(EXT_CODE) $(EXT_HEADERS) $(EXT_OBJECT) $(EXT_LIB_STATIC) $(EXT_LIB_DYNAMIC)

VPATH =
vpath
vpath %$(EXT_CODE) $(DIR_SRC)
vpath %$(EXT_HEADERS) $(DIR_INC)
vpath %$(EXT_OBJECT) $(DIR_BUILD)
vpath %$(EXT_LIB_STATIC) $(DIR_BUILD)
vpath %$(EXT_LIB_DYNAMIC) $(DIR_BUILD)

_FILES_SRC             = $(foreach dir,$(DIR_SRC),$(wildcard $(DIR_SRC)*$(EXT_CODE)))
_FILES_SRC_REL         = $(notdir $(_FILES_SRC))
_FILES_SRC_O           = $(subst $(EXT_CODE),$(EXT_OBJECT),$(_FILES_SRC_REL))
_FILES_SRC_O_BUILD     = $(addprefix $(DIR_BUILD),$(_FILES_SRC_O))
_FILES_SRC_A           = $(subst $(EXT_CODE),$(EXT_LIB_STATIC),$(_FILES_SRC_REL))
_FILES_SRC_A_BUILD     = $(addprefix $(DIR_BUILD),$(_FILES_SRC_A))
_FILES_SRC_DYLIB       = $(subst $(EXT_CODE),$(EXT_LIB_DYNAMIC),$(_FILES_SRC_REL))
_FILES_SRC_DYLIB_BUILD = $(addprefix $(DIR_BUILD),$(_FILES_SRC_DYLIB))
_STEM                  = %
_ARGS_CC               = -I $(DIR_INC) $(ARGS_CC)

.PHONY: all clean install uninstall __copyright

all: __copyright $(_FILES_SRC_O_BUILD) $(_FILES_SRC_A_BUILD) $(_FILES_SRC_DYLIB_BUILD)
	
clean:
	@echo "    - Removing all build files"
	@rm -rf $(DIR_BUILD)*
	@if [ -d "$(DIR_INSTALL).libs" ]; then rm -rf "$(DIR_INSTALL).libs"; fi
	
install: all
	@if [ ! -d "$(DIR_INSTALL)" ]; then sudo mkdir $(DIR_INSTALL); fi
	@if [ ! -d "$(DIR_INSTALL_LIB)" ]; then sudo mkdir $(DIR_INSTALL_LIB); fi
	@if [ ! -d "$(DIR_INSTALL_INC)" ]; then sudo mkdir $(DIR_INSTALL_INC); fi
	@echo "    - Installing header files to:      $(DIR_INSTALL_INC)"
	@sudo cp $(DIR_INC)* $(DIR_INSTALL_INC)
	@echo "    - Installing static libraries to:  $(DIR_INSTALL_LIB)"
	@sudo cp $(DIR_BUILD)*$(EXT_LIB_STATIC) $(DIR_INSTALL_LIB)
	@echo "    - Installing dynamic libraries to: $(DIR_INSTALL_LIB)"
	@sudo cp $(DIR_BUILD)*$(EXT_LIB_DYNAMIC) $(DIR_INSTALL_LIB)
	
uninstall:
	@if [ -d "$(DIR_INSTALL)" ]; then sudo rm -rf $(DIR_INSTALL); fi
	
$(DIR_BUILD)%$(EXT_OBJECT): %$(EXT_CODE) %$(EXT_HEADERS)
	@echo "    - Building object file:     "$(subst $(DIR_BUILD),"",$@)
	@$(CC) $(_ARGS_CC) -o $(DIR_BUILD)$(@F) -c $< $(CFLAGS)

$(DIR_BUILD)%$(EXT_LIB_STATIC): %$(EXT_OBJECT) %$(EXT_HEADERS)
	@echo "    - Building static library:  "$(subst $(DIR_BUILD),"",$(subst $(EXT_LIB_ARCHIVE),$(EXT_LIB_OBJECT),$@))
	@$(LIBTOOL_STATIC) $(ARGS_LIBTOOL_STATIC) -o $@ $<

$(DIR_BUILD)%$(EXT_LIB_DYNAMIC): %$(EXT_OBJECT) %$(EXT_HEADERS)
	@echo "    - Building dynamic library: "$(subst $(DIR_BUILD),"",$@)
	@$(LIBTOOL_DYNAMIC) $(ARGS_LIBTOOL_DYLIB) -install_name $(DIR_INSTALL_LIB)$(subst $(DIR_BUILD),"",$@) -o $@ $<
	
__copyright:
	@echo "----------------------------------------------------------------------"
	@echo "Copyright (c) 2011, Jean-David Gadina - www.xs-labs.com"
	@echo "Distributed under the Boost Software License, Version 1.0."
	@echo "----------------------------------------------------------------------"
