# Makefile.am for littler
#
# Copyright (C) 2006 - 2009  Jeffrey Horner and Dirk Eddelbuettel, GNU GPL'ed

# Installed program name
bin_PROGRAMS=r$(EXEEXT)

all-am: r$(EXEEXT) littler.h autoloads.h ldflags.txt

# List of files to include in distribution (e.g. make dist)
r_SOURCES=littler.c r.1 autoloads.R ldflags.R littler.R ANNOUNCEMENT \
			tests/* examples/* svnversion.h bootstrap

# These two together will tell make to create autoloads.h before any target.
nodist_r_SOURCES=autoloads.h ldflags.txt littler.h svnversion.h
BUILT_SOURCES=autoloads.h ldflags.txt littler.h svnversion.h

ROPTIONS=--silent --vanilla --slave

# The next three rules could be written more compactly as '... < $< > $@'
# using the GNU make 'extention variables' $< and $@, but as this may get
# executed under a non-GNU make on *BSD, we expand explicitly.
# The .PHONY settings that these targets are always freshly re-made.
.PHONY: littler.h
littler.h: littler.R
	R_HOME= ${RPROG} ${ROPTIONS} < littler.R > littler.h

.PHONY: autoloads.h 
autoloads.h: autoloads.R
	R_HOME= ${RPROG} ${ROPTIONS} < autoloads.R > autoloads.h

.PHONY: ldflags.txt
ldflags.txt: ldflags.R
	R_HOME= ${RPROG} ${ROPTIONS} < ldflags.R > ldflags.txt

# Always create a fresh svn version -- but .PHONY used here create a loop
.PHONY: svnversion.h
svnversion.h: 
	./bootstrap --svnversion

# Main r build rule, with suitable extension where needed (as eg on OS X)
r$(EXEEXT): $(r_OBJECTS) $(r_DEPENDENCIES) svnversion.h
	@rm -f r$(EXEEXT)
	$(CCLD) $(AM_CFLAGS) $(CFLAGS) $(AM_LDFLAGS) \
		`cat ldflags.txt` $(LDFLAGS) \
		-o $@ $(r_LDFLAGS) $(r_OBJECTS) $(r_LDADD) $(LIBS)
	$(RUN_NAMETOOL)

#  Clean target to delete stuff make generates
MOSTLYCLEANFILES=autoloads.h ldflags.txt littler.o littler.h 

# Ensure that svnversion.h is regenerated on 'make dist'
EXTRA_DIST=svnversion.h

#  install the man page
man_MANS=r.1

