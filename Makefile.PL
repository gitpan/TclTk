use ExtUtils::MakeMaker;
WriteMakefile(NAME => "Tcl::Tk",
	      DISTNAME => "TclTk",
	      LIBS => ["-ltk -ltcl -L/usr/X11R6/lib -lX11 -lm"],
	      INC => "-I/usr/local/include -I/usr/include/tcl");
#sub MY::tool_autosplit { "AUTOSPLITFILE = :" }
