### This file is part of virtual_mlv.
###
### virtual_mlv is free software: you can redistribute it and/or modify
### it under the terms of the GNU General Public License as published
### by the Free Software Foundation, either version 3 of the License,
### or (at your option) any later version.
###
### virtual_mlv is distributed in the hope that it will be useful, but
### WITHOUT ANY WARRANTY; without even the implied warranty of
### MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
### General Public License for more details.
###
### You should have received a copy of the GNU General Public License
### along with virtual_mlv.  If not, see
### <http://www.gnu.org/licenses/>.
###
###
### Authors: S. Lombardy, N. Bedon, C. Morvan, G. Fuhs, W. Hay
###

CC = gcc
LEXER = flex
PARSER = bison
CFLAGS =
EXEC = vm
LOAD = loadprog
DEBUG = yes

HAS_CLANG = $(shell which clang > /dev/null 2>&1; echo $$?)
DOXYCHECK = # Used to check doxygen comments consistency.

ifeq ($(HAS_CLANG), 0) # 0 is fine, it's the shell exit code upon success.
    DOXYCHECK = clang -Wdocumentation -fsyntax-only *.c *.h
else
    DOXYCHECK = @echo "It seems that you don't have `clang', doxycheck aborted."
endif

ifeq ($(DEBUG), yes)
    CFLAGS += -Wall -Wextra -std=c89 -pedantic
else
    CFLAGS += -O2 -DNDEBUG
endif

all: $(EXEC) clean

doxycheck:
	$(DOXYCHECK)

$(EXEC): main.o opcode.o vm.o $(LOAD).o array.o lex.yy.o mystack.o
	$(CC) $(CFLAGS) -o $@ $^

$(LOAD).c: $(LOAD).y
	$(PARSER) -d -o $(LOAD).c $(LOAD).y

$(LOAD).h: $(LOAD).c

lex.yy.c: $(LOAD).lex $(LOAD).h
	$(LEXER) $(LOAD).lex

%.o: %.c
	$(CC) $(CFLAGS) -o $@ -c $<

.PHONY: clean mrproper

clean:
	-rm -f *.o lex.yy.c $(LOAD).[ch]

mrproper: clean
	-rm -f $(EXEC)
