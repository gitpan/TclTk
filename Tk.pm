# $Id: Tk.pm,v 1.5 1995/06/06 11:58:26 mbeattie Exp $
#
# $Log: Tk.pm,v $
# Revision 1.5  1995/06/06  11:58:26  mbeattie
# Included and edited pod. Added Tk 4.0 commands/widgets.
#
# Revision 1.4  1994/12/06  17:32:32  mbeattie
# none
#
# Revision 1.3  1994/11/12  23:29:55  mbeattie
# *** empty log message ***
#
# Revision 1.1  1994/11/12  18:11:05  mbeattie
# Initial revision
#

package Tcl::Tk;

require Tcl;
use Exporter;
use DynaLoader;

=head1

Tcl::Tk - Extension module for Perl giving access to Tk via the Tcl extension

=head1 DESCRIPTION

The Tcl::Tk submodule of the Tcl module gives access to the Tk library.
It does this by creating a Tcl interpreter object (using the Tcl extension)
and binding in all of Tk into the interpreter (in the same way that
B<wish> or other Tcl/Tk applications do).

=head2 Access to the Tcl and Tcl::Tk extensions

To get access to the Tcl and Tcl::Tk extensions, put the commands
    require Tcl;
    use Tcl::Tk;

near the top of your program. The Tcl extension does not alter your
namespace at all (hence the "require"). The Tcl::Tk extension imports
the widget and other Tk commands into your namespace (hence the "use").

=head2 Creating a Tcl interpreter for Tk

To create a Tcl interpreter initialised for Tk, use
    $i = new Tcl::Tk (DISPLAY, NAME, SYNC);

All arguments are optional. This creates a Tcl interpreter object $i,
binds in all the additional Tk/Tcl commands and creates a main toplevel
window. The window is created on display DISPLAY (defaulting to the display
named in the DISPLAY environment variable) with name NAME (defaulting to
the name of the Perl program, i.e. the contents of Perl variable $0).
If the SYNC argument is present and true then an I<XSynchronize()> call is
done ensuring that X events are processed synchronously (and thus slowly).
This is there for completeness and is only very occasionally useful for
debugging errant X clients (usually at a much lower level than Tk users
will want).

=head2 Entering the main event loop

The Perl command
    MainLoop;

enters the Tk event loop. (Notice that the name differs from the equivalent
command in TkPerl5: names of commands in the Tcl and Tcl::Tk extensions
closely follow the C interface names with leading Tcl_ or Tk_ removed.)

=head2 Creating widgets

If desired, widgets can be created and handled entirely by Tcl/Tk code
evaluated in the Tcl interpreter object $i (created above). However,
there is an additional way of creating widgets in the interpreter
directly from Perl. The names of the widgets (frame, toplevel, label etc.)
are exported as Perl commands by the Tcl::Tk extension. The initial
"use Tcl::Tk;" command imports those commands into your namespace.
The command
    $l = label(".l", -text => "Hello world);

(for example), executes the command
    $i->call("label", ".l", "-text", "Hello world);

and hence gets Tcl to create a new label widget .l in your Tcl/Tk interpreter.
Since Tcl/Tk then creates a command ".l" in the interpreter and creating a
similarly named sub in Perl isn't a good idea, the Tcl::Tk extension uses a
kludge to give a slightly more convenient way of manipulating the widget.
Instead of returning the name of the new widget as a string, the above
label command returns a Perl reference to the widget's name, blessed into an
almost empty class. Perl method calls on the object are translated into
commands for the Tcl/Tk interpreter in a very simplistic fashion. For example,
the Perl command
    $l->configure(-background => "green");

is translated into the command
    $i->call($$l, "configure", "-background", "green");

for execution in your Tcl/Tk interpreter. Notice that it simply dereferences
the object to find the widget name. There is no automagic conversion that
happens: if you use a Tcl command which wants a widget pathname and you
only have an object returned by I<label()> (or I<button()> or I<entry()>
or whatever) then you must dereference it yourself.

=head2 Non-widget Tk commands

For convenience, the non-widget Tk commands (such as destroy, focus, wm,
winfo and so on) are also available as Perl commands and translate into
into their Tcl equivalents for execution in your Tk/Tcl interpreter. The
names of the Perl commands are the same as their Tcl equivalents except
for two: Tcl's pack command becomes tkpack in Perl and Tcl's bind command
becomes tkbind in Perl. The arguments you pass to any of these Perl
commands are not touched by the Tcl parser: each Perl argument is passed
as a separate argument to the Tcl command.

=head2 AUTHOR

Malcolm Beattie, mbeattie@sable.ox.ac.uk

=cut

@ISA = (Exporter, DynaLoader);

@EXPORT = qw(frame toplevel label button checkbutton radiobutton scale
	     message listbox scrollbar entry menu menubutton canvas text
	     MainLoop after destroy focus grab lower option place raise
	     selection tk tkbind tkpack tkwait update winfo wm);

$tkinterp = undef;		# this gets defined when "new" is done

sub new {
    my ($class, $name, $display, $sync) = @_;
    die 'Usage: $interp = new Tcl::Tk([$name [, $display [, $sync]]])'
	if @_ > 4;
    die "Tcl::Tk interpreter already created" if defined($tkinterp);
    my($i, $arg);

    $display = $ENV{DISPLAY} unless defined($display);
    ($name = $0) =~ s{.*/}{} unless defined($name);

    $i = new Tcl;
    $i->CreateMainWindow($display, $name, $sync);
    $i->SetVar2("env", "DISPLAY", $display, $Tcl::GLOBAL_ONLY);
    $i->SetVar("argv0", $0, $Tcl::GLOBAL_ONLY);
    $i->SetVar("argc", scalar(@main::ARGV), $Tcl::GLOBAL_ONLY);
    $i->ResetResult();
    foreach $arg (@main::ARGV) {
	$i->AppendElement($arg);
    }
    $i->SetVar("argv", $i->result(), $Tcl::GLOBAL_ONLY);
    $i->SetVar("tcl_interactive", "0", $Tcl::GLOBAL_ONLY);
    $i->Init();
    $i->Tk_Init();

    $tkinterp = $i;	# record the interp in package-scope var $tkinterp
    return $i;
}

sub frame {
    my $path = $tkinterp->call("frame", @_);
    bless \$path, Tcl::Tk::Widget;
}
sub toplevel {
    my $path = $tkinterp->call("toplevel", @_);
    bless \$path, Tcl::Tk::Widget;
}
sub label {
    my $path = $tkinterp->call("label", @_);
    bless \$path, Tcl::Tk::Widget;
}
sub button {
    my $path = $tkinterp->call("button", @_);
    bless \$path, Tcl::Tk::Widget;
}
sub checkbutton {
    my $path = $tkinterp->call("checkbutton", @_);
    bless \$path, Tcl::Tk::Widget;
}
sub radiobutton {
    my $path = $tkinterp->call("radiobutton", @_);
    bless \$path, Tcl::Tk::Widget;
}
sub scale {
    my $path = $tkinterp->call("scale", @_);
    bless \$path, Tcl::Tk::Widget;
}
sub message {
    my $path = $tkinterp->call("message", @_);
    bless \$path, Tcl::Tk::Widget;
}
sub listbox {
    my $path = $tkinterp->call("listbox", @_);
    bless \$path, Tcl::Tk::Widget;
}
sub scrollbar {
    my $path = $tkinterp->call("scrollbar", @_);
    bless \$path, Tcl::Tk::Widget;
}
sub entry {
    my $path = $tkinterp->call("entry", @_);
    bless \$path, Tcl::Tk::Widget;
}
sub menu {
    my $path = $tkinterp->call("menu", @_);
    bless \$path, Tcl::Tk::Widget;
}
sub menubutton {
    my $path = $tkinterp->call("menubutton", @_);
    bless \$path, Tcl::Tk::Widget;
}
sub canvas {
    my $path = $tkinterp->call("canvas", @_);
    bless \$path, Tcl::Tk::Widget;
}
sub text {
    my $path = $tkinterp->call("text", @_);
    bless \$path, Tcl::Tk::Widget;
}

sub after { $tkinterp->call("after", @_) }
sub bell { $tkinterp->call("bell", @_) }
sub bindtags { $tkinterp->call("bindtags", @_) }
sub clipboard { $tkinterp->call("clipboard", @_) }
sub destroy { $tkinterp->call("destroy", @_) }
sub exit { $tkinterp->call("exit", @_) }
sub fileevent { $tkinterp->call("fileevent", @_) }
sub focus { $tkinterp->call("focus", @_) }
sub grab { $tkinterp->call("grab", @_) }
sub image { $tkinterp->call("image", @_) }
sub lower { $tkinterp->call("lower", @_) }
sub option { $tkinterp->call("option", @_) }
sub place { $tkinterp->call("place", @_) }
sub raise { $tkinterp->call("raise", @_) }
sub selection { $tkinterp->call("selection", @_) }
sub tk { $tkinterp->call("tk", @_) }
sub tkwait { $tkinterp->call("tkwait", @_) }
sub update { $tkinterp->call("update", @_) }
sub winfo { $tkinterp->call("winfo", @_) }
sub wm { $tkinterp->call("wm", @_) }
sub property { $tkinterp->call("property", @_) }

sub tkbind { $tkinterp->call("bind", @_) }
sub tkpack { $tkinterp->call("pack", @_) }

package Tcl::Tk::Widget;

sub DESTROY {}			# do not let AUTOLOAD catch this method

sub AUTOLOAD {
    my $w = shift;
    my $method = $AUTOLOAD;
    $method =~ s/^Tcl::Tk::Widget::// or die "weird inheritance";
    $Tcl::Tk::tkinterp->call($$w, $method, @_);
}

bootstrap Tcl::Tk;

1;

__END__
