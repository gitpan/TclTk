package Tcl::Tk;

use strict;
use Tcl;
use Exporter;
use DynaLoader;
our @ISA = qw(Exporter DynaLoader);

$Tcl::VERSION = '0.5';

=head1 NAME

Tcl::Tk - Extension module for Perl giving access to Tk via the Tcl extension

=head1 SYNOPSIS

    use Tcl;
    use Tcl::Tk qw(:widgets :misc);
    $interp = new Tcl::Tk;
    label(".l", -text => "Hello world");
    tkpack ".l";
    MainLoop;

=head1 DESCRIPTION

The Tcl::Tk submodule of the Tcl module gives access to the Tk library.
It does this by creating a Tcl interpreter object (using the Tcl extension)
and binding in all of Tk into the interpreter (in the same way that
B<wish> or other Tcl/Tk applications do).

Unlike perl-tk extension (available on CPAN), where Tcl+Tk+Tix is embedded
into extension, this module connects to existing TCL installation. Such
approach allows to work with most up-to-date TCL, and this automatically gives
Unicode and pure TCL widgets available to application.

Please see and try to run demo scripts 'demo.pl', 'demo-w-tix.pl' and
'widgets.pl' in tk-demo directory of source tarball.

=head2 Access to the Tcl and Tcl::Tk extensions

To get access to the Tcl and Tcl::Tk extensions, put the commands
    use Tcl;
    use Tcl::Tk;

near the top of your program. You can also import short-cut functions
into your namespace from Tcl::Tk if you want to avoid using method calls
for everything.

=head2 Creating a Tcl interpreter for Tk

To create a Tcl interpreter initialised for Tk, use

    $i = new Tcl::Tk (DISPLAY, NAME, SYNC);

All arguments are optional. This creates a Tcl interpreter object $i,
and creates a main toplevel window. The window is created on display
DISPLAY (defaulting to the display named in the DISPLAY environment
variable) with name NAME (defaulting to the name of the Perl program,
i.e. the contents of Perl variable $0). If the SYNC argument is present
and true then an I<XSynchronize()> call is done ensuring that X events
are processed synchronously (and thus slowly). This is there for
completeness and is only very occasionally useful for debugging errant
X clients (usually at a much lower level than Tk users will want).

=head2 Entering the main event loop

The Perl method call

    $i->MainLoop;

on the Tcl::Tk interpreter object enters the Tk event loop. You can
instead do C<Tcl::Tk::MainLoop> or C<Tcl::Tk-E<gt>MainLoop> if you prefer.
You can even do simply C<MainLoop> if you import it from Tcl::Tk in
the C<use> statement. Note that commands in the Tcl and Tcl::Tk
extensions closely follow the C interface names with leading Tcl_
or Tk_ removed.

=head2 Creating widgets

As a general rule, you need to consult TCL man pages to realize how to
use a widget, and after that invoke perl command that creates it preperly.

If desired, widgets can be created and handled entirely by Tcl/Tk code
evaluated in the Tcl interpreter object $i (created above). However,
there is an additional way of creating widgets in the interpreter
directly from Perl. The names of the widgets (frame, toplevel, label etc.)
can be imported as direct commands from the Tcl::Tk extension. For example,
if you have imported the C<label> command then

    $l = label(".l", -text => "Hello world);

executes the command

    $i->call("label", ".l", "-text", "Hello world);

and hence gets Tcl to create a new label widget .l in your Tcl/Tk
interpreter. You can either import such commands one by one with,
for example,

    use Tcl::Tk qw(label canvas MainLoop winfo);

or you can use the pre-defined Exporter tags B<:widgets> and B<:misc>.
The B<:widgets> tag imports all the widget commands and the B<:misc>
tag imports all non-widget commands (see the next section).

Let's return to the creation of the label widget above. Since Tcl/Tk
creates a command ".l" in the interpreter and creating a similarly
named sub in Perl isn't a good idea, the Tcl::Tk extension provides a
slightly more convenient way of manipulating the widget. Instead of
returning the name of the new widget as a string, the above label
command returns a Perl reference to the widget's name, blessed into an
almost empty class. Perl method calls on the object are translated
into commands for the Tcl/Tk interpreter in a very simplistic
fashion. For example, the Perl command

    $l->configure(-background => "green");

is translated into the command

    $i->call($$l, "configure", "-background", "green");

for execution in your Tcl/Tk interpreter. Notice that it simply dereferences
the object to find the widget name. There is no automagic conversion that
happens: if you use a Tcl command which wants a widget pathname and you
only have an object returned by C<label()> (or C<button()> or C<entry()>
or whatever) then you must dereference it yourself.

=head2 Non-widget Tk commands

For convenience, the non-widget Tk commands (such as C<destroy>,
C<focus>, C<wm>, C<winfo> and so on) are also available for export as
Perl commands and translate into into their Tcl equivalents for
execution in your Tk/Tcl interpreter. The names of the Perl commands
are the same as their Tcl equivalents except for two: Tcl's C<pack>
command becomes C<tkpack> in Perl and Tcl's C<bind> command becomes
C<tkbind> in Perl. The arguments you pass to any of these Perl
commands are not touched by the Tcl parser: each Perl argument is
passed as a separate argument to the Tcl command.

=head2 BUGS

Currently work is in progress, and some features could change in future
versions.

=head2 AUTHOR

Malcolm Beattie, mbeattie@sable.ox.ac.uk
Vadim Konovalov, vkonovalov@peterstar.ru, 19 May 2003.

=head2 COPYRIGHT

This program is free software; you can redistribute it and/or modify it under the same terms as Perl itself.

See http://www.perl.com/perl/misc/Artistic.html

=cut

my @widgets = qw(frame toplevel label labelframe button checkbutton radiobutton scale
		 mainwindow message listbox scrollbar entry menu menubutton canvas text
		 widget
		);
my @misc = qw(MainLoop after destroy focus grab lower option place raise
	      selection tk tkbind tkpack grid tkwait update winfo wm);
our @EXPORT_OK = (@widgets, @misc);
our %EXPORT_TAGS = (widgets => \@widgets, misc => \@misc);

my $tkinterp = undef;		# this gets defined when "new" is done
my $mainwindow = ['.'];
my %w; # hash to keep track on all widgets

sub new {
    my ($class, $name, $display, $sync) = @_;
    Carp::croak 'Usage: $interp = new Tcl::Tk([$name [, $display [, $sync]]])'
	if @_ > 4;
    Carp::croak "Tcl::Tk interpreter already created" if defined($tkinterp);
    my($i, $arg, @argv);

    if (defined($display)) {
	push(@argv, -display => $display);
    } else {
	$display = $ENV{DISPLAY} || '';
    }
    if (defined($name)) {
	push(@argv, -name => $name);
    } else {
	($name = $0) =~ s{.*/}{};
    }
    if (defined($sync)) {
	push(@argv, "-sync");
    } else {
	$sync = 0;
    }
    $i = new Tcl;
    $i->CreateMainWindow($display, $name, $sync);
    bless $mainwindow, 'Tcl::Tk::Widget::MainWindow';
    $i->SetVar2("env", "DISPLAY", $display, Tcl::GLOBAL_ONLY);
    $i->SetVar("argv0", $0, Tcl::GLOBAL_ONLY);
    $i->SetVar("argc", scalar(@main::ARGV), Tcl::GLOBAL_ONLY);
    $i->ResetResult();
    push(@argv, "--", @ARGV);
    $i->AppendElement($_) for @argv;
    $i->SetVar("argv", $i->result(), Tcl::GLOBAL_ONLY);
    $i->SetVar("tcl_interactive", "0", Tcl::GLOBAL_ONLY);
    $i->Init();
    $i->Tk_Init();

    $tkinterp = $i;
    return $i;
}

sub frame($@) {
    my $path = $tkinterp->call("frame", @_);
    $w{$path} = bless \$path, 'Tcl::Tk::Widget';
}
sub toplevel {
    my $path = $tkinterp->call("toplevel", @_);
    $w{$path} = bless \$path, 'Tcl::Tk::Widget';
}
sub mainwindow {
    # this is a window with path '.'
    $mainwindow;
}
sub label {
    my $path = $tkinterp->call("label", @_);
    $w{$path} = bless \$path, 'Tcl::Tk::Widget';
}
sub labelframe {
    my $path = $tkinterp->call("labelframe", @_);
    $w{$path} = bless \$path, 'Tcl::Tk::Widget';
}
sub button {
    my $path = $tkinterp->call("button", @_);
    $w{$path} = bless \$path, 'Tcl::Tk::Widget';
}
sub checkbutton {
    my $path = $tkinterp->call("checkbutton", @_);
    $w{$path} = bless \$path, 'Tcl::Tk::Widget';
}
sub radiobutton {
    my $path = $tkinterp->call("radiobutton", @_);
    $w{$path} = bless \$path, 'Tcl::Tk::Widget';
}
sub scale {
    my $path = $tkinterp->call("scale", @_);
    $w{$path} = bless \$path, 'Tcl::Tk::Widget';
}
sub message {
    my $path = $tkinterp->call("message", @_);
    $w{$path} = bless \$path, 'Tcl::Tk::Widget';
}
sub listbox {
    my $path = $tkinterp->call("listbox", @_);
    $w{$path} = bless \$path, 'Tcl::Tk::Widget';
}
sub scrollbar {
    my $path = $tkinterp->call("scrollbar", @_);
    $w{$path} = bless \$path, 'Tcl::Tk::Widget';
}
sub entry {
    my $path = $tkinterp->call("entry", @_);
    $w{$path} = bless \$path, 'Tcl::Tk::Widget';
}
sub menu {
    my $path = $tkinterp->call("menu", @_);
    $w{$path} = bless \$path, 'Tcl::Tk::Widget';
}
sub menubutton {
    my $path = $tkinterp->call("menubutton", @_);
    $w{$path} = bless \$path, 'Tcl::Tk::Widget';
}
sub canvas {
    my $path = $tkinterp->call("canvas", @_);
    $w{$path} = bless \$path, 'Tcl::Tk::Widget';
}
sub text {
    my $path = $tkinterp->call("text", @_);
    $w{$path} = bless \$path, 'Tcl::Tk::Widget';
}
sub widget($@) {
    my $wpath = shift;
    return $w{$wpath};
}
sub widget_do($@) {
    my $wpath = shift;
    return $w{$wpath};
}
sub widgets {
  \%w;
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
sub grid { $tkinterp->call("grid", @_) }

package Tcl::Tk::Widget;


sub DESTROY {}			# do not let AUTOLOAD catch this method

sub AUTOLOAD {
    my $w = shift;
    my $method = $::Tcl::Tk::Widget::AUTOLOAD;
    $method =~ s/^Tcl::Tk::Widget::// or die "weird inheritance ($method)";
    $tkinterp->call($$w, $method, @_);
}

package Tcl::Tk::Widget::MainWindow;


sub DESTROY {}			# do not let AUTOLOAD catch this method

sub AUTOLOAD {
    my $w = shift;
    my $method = $::Tcl::Tk::Widget::MainWindow::AUTOLOAD;
    $method =~ s/^Tcl::Tk::Widget::MainWindow::// or die "weird inheritance ($method)";
    $tkinterp->call('.', $method, @_);
}

bootstrap Tcl::Tk;

1;

