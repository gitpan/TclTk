#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"
#include <tcl.h>
#include <tk.h>

#ifndef lint
static char vcid[] = "$Id: Tk.xs,v 1.3 1994/12/06 17:32:32 mbeattie Exp $";
#endif /* lint */

/* $Log: Tk.xs,v $
 * Revision 1.3  1994/12/06  17:32:32  mbeattie
 * none
 *
 * Revision 1.2  1994/11/12  23:29:55  mbeattie
 * *** empty log message ***
 *
 * Revision 1.1  1994/11/12  18:09:01  mbeattie
 * Initial revision
 *
 */

typedef Tcl_Interp *Tcl;

MODULE = Tcl::Tk		PACKAGE = Tcl::Tk	PREFIX = Tk_

void
Tk_MainLoop()

MODULE = Tcl::Tk		PACKAGE = Tcl

void
CreateMainWindow(interp, display, name, sync = 0)
	Tcl		interp
	char *		display
	char *		name
	int		sync
	Tk_Window	mainWindow = NO_INIT
    CODE:
	mainWindow = Tk_CreateMainWindow(interp, display, name, "Tk");
	if (!mainWindow)
	    croak(interp->result);
	Tk_GeometryRequest(mainWindow, 200, 200);
	if (sync)
	    XSynchronize(Tk_Display(mainWindow), True);

void
Tk_Init(interp)
	Tcl	interp
    CODE:
	if (Tk_Init(interp) != TCL_OK)
	    croak(interp->result);
