package Tcl::Tk;

use strict;
use Tcl;
use Exporter;
use DynaLoader;
use vars qw(@ISA @EXPORT_OK %EXPORT_TAGS);
@ISA = qw(Exporter DynaLoader);

$Tcl::Tk::VERSION = '0.7';

=head1 NAME

Tcl::Tk - Extension module for Perl giving access to Tk via the Tcl extension

=head1 SYNOPSIS

    use Tcl::Tk qw(:widgets :misc);
    $interp = new Tcl::Tk;
    label(".l", -text => "Hello world");
    tkpack ".l";
    MainLoop;

Or    

    use Tcl::Tk;
    $interp = new Tcl::Tk;
    $interp->label(".l", -text => "Hello world")->pack;
    $btn = $interp->button(".btn", -text => "test", -command => sub {
      $btn->configure(-text=>"[". $btn->cget('-text')."]");
    })->pack;
    $interp->MainLoop;

=head1 DESCRIPTION

The Tcl::Tk submodule of the Tcl module gives access to the Tk library.
It does this by creating a Tcl interpreter object (using the Tcl extension)
and binding in all of Tk into the interpreter (in the same way that
B<wish> or other Tcl/Tk applications do).

Unlike perl-tk extension (available on CPAN), where Tcl+Tk+Tix are embedded
into extension, this module connects to existing TCL installation. Such
approach allows to work with most up-to-date TCL, and this automatically gives
Unicode and pure TCL widgets available to application along with any widgets
existing in TCL installation. As an example, Windows user have possibility to
use ActiveX widgets provided by Tcl extension named "OpTcl", so to provide
native Windows widgets.

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

When creating a widget, you must specify its path as first argument.
Widget path is a string starting with a dot and consisting of several
names separated by dots. These names are widget names that comprise
widget's hierarchy. As an example, if there exists a frame with a path
".fram" and you want to create a button on it and name it "butt" then
you should specify name ".fram.butt". Widget paths are refered in
miscellaneous widget operations, and geometry management is one of them.
Once again, see Tcl/Tk documentation to get details.

Widget creation command returns a Perl object that could be used further
for operations with widget. Perl method calls on the object are translated
into commands for the Tcl/Tk interpreter in a very simplistic fashion.
For example, the Perl command

    $l->configure(-background => "green");

is translated into the command

    $i->call($$l, "configure", "-background", "green");

for execution in your Tcl/Tk interpreter. Notice that it simply dereferences
the object to find the widget name. There is no automagic conversion that
happens: if you use a Tcl command which wants a widget pathname and you
only have an object returned by C<label()> (or C<button()> or C<entry()>
or whatever) then you must dereference it yourself.

When widgets are created they are stored internally and could be retreiwed
by C<widget()> command:

    widget(".fram.butt")->configure(-text=>"new text");
   
Please note that this method will return to you a widget object even if it was
not created within this module, and check will not be performed whether a 
widget with given path exists, despite of fact that checking for existence of
a widget is an easy task (invoking $interp->Eval("info commands $path") will
do this). Instead, you will receive perl object that will try to operate with
widget that has given path even if such path do not exists. 

This approach allows to transparently access widgets created in Tcl way. So
variable $btn in following code will behave exactly as if it was created
with "button" method:

    $interp->Eval(<<'EOS');
    frame .f
    button .f.b
    pack .f
    pack .f.b
    EOS
    my $btn = widget(".f.b");

Note, that currently C<widget()> methods does not checks whether required 
widget actually exists in Tk, and, if widget was created from Tcl/Tk, it will
not be retrieved by this method.
NOTE! this could change in future versions, so please do not use this method
to check whether a widget with certain path exists.

C<awidget> method

If you know there exists a method that creates widget in Tcl/Tk but it
is not implemented as a part of this module, use C<awidget> method (mnemonic
- "a widget" or "any widget"). C<awidget>, as method of interpreter object,
creates a subroutine inside Tcl::Tk package and this subroutine could be
invoked as a method for creating desired widget. After such call any 
interpreter can create required widget.

If there are more than one arguments provided to C<awidget> method, then
newly created method will be invoked with remaining arguments:

  $interp->awidget('tixTList');
  $interp->tixTList('.f.tlist');

does same thing as

  $interp->awidget('tixTList', '.f.tlist');

C<awidgets> method

C<awidgets> method takes a list consisting of widget names and calls
C<awidget> method for each of them.

Widget creation commands are methods of Tcl::Tk interpreter object. But if
you want to omit interpreter for brevity, then you could do it, and in this
case will be used interpreter that was created first. Following examples
demonstrate this:

    use Tcl::Tk qw(:widgets :misc);
    $interp = new Tcl::Tk;

    # at next line interpreter object omited, but $interp is implicitly used
    label ".l", -text => "Hello world"; 
    
    tkpack ".l"; # $interp will be called to pack ".l"
    
    # OO way, we explicitly use methods of $interp to create button
    $btn = $interp->button(".btn", -text => "test", -command => sub {
      $btn->configure(-text=>"[". $btn->cget('-text')."]");
    });
    $btn->pack; # another way to pack a widget

    $interp->MainLoop;


=head2 Non-widget Tk commands

For convenience, the non-widget Tk commands (such as C<destroy>,
C<focus>, C<wm>, C<winfo> and so on) are also available for export as
Perl commands and translate into into their Tcl equivalents for
execution in your Tk/Tcl interpreter. The names of the Perl commands
are the same as their Tcl equivalents except for two: Tcl's C<pack>
command becomes C<tkpack> in Perl and Tcl's C<bind> command becomes
C<tkbind> in Perl. But those two commands are C<pack> and C<bind> when
used as method of interpreter, because this way we avoid confusion with
Perl internal C<pack> and C<bind>. The arguments you pass to any of these
Perl commands are not touched by the Tcl parser: each Perl argument is
passed as a separate argument to the Tcl command.

=head2 BUGS

Currently work is in progress, and some features could change in future
versions.

=head2 AUTHORS

Malcolm Beattie, mbeattie@sable.ox.ac.uk
Vadim Konovalov, vkonovalov@peterstar.ru, 19 May 2003.

=head2 COPYRIGHT

This program is free software; you can redistribute it and/or modify it under the same terms as Perl itself.

See http://www.perl.com/perl/misc/Artistic.html

=cut

my @widgets = qw(frame toplevel label labelframe button checkbutton radiobutton scale
		 mainwindow message listbox scrollbar spinbox entry menu menubutton 
		 canvas text
		 widget awidget awidgets
		);
my @misc = qw(MainLoop after destroy focus grab lower option place raise
              image
	      selection tk tkbind tkpack grid tkwait update winfo wm);
@EXPORT_OK = (@widgets, @misc);
%EXPORT_TAGS = (widgets => \@widgets, misc => \@misc);

## TODO -- module's private $tkinterp should go away!
my $tkinterp = undef;		# this gets defined when "new" is done

my $mainwindow = ['.'];
my %w; # hash to keep track on all created widgets
my %wint; # hash to keep track on tk interpreters associated with widgets

sub new {
    my ($class, $name, $display, $sync) = @_;
    Carp::croak 'Usage: $interp = new Tcl::Tk([$name [, $display [, $sync]]])'
	if @_ > 4;
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
    unless (defined($tkinterp)) {
        $i->CreateMainWindow($display, $name, $sync);
        bless $mainwindow, 'Tcl::Tk::Widget::MainWindow';
	$wint{'.'} = $i;
    }
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
    #'###???'&&   bless $i, 'Tcl::Tk';
    $tkinterp = $i;
    return $i;
}

sub declare_widget {
    my $int = shift;
    my $path = shift;
    $wint{$path} = $int;
    return $w{$path} = bless \$path, 'Tcl::Tk::Widget';
}
sub frame($@) {
    my $int = (ref $_[0]?shift:$tkinterp);
    my ($path) = $int->call("frame", @_);
    return $int->declare_widget($path);
}
sub toplevel {
    my $int = (ref $_[0]?shift:$tkinterp);
    my ($path) = $int->call("toplevel", @_);
    return $int->declare_widget($path);
}
sub mainwindow {
    # this is a window with path '.'
    $mainwindow;
}
sub label {
    my $int = (ref $_[0]?shift:$tkinterp);
    my ($path) = $int->call("label", @_);
    return $int->declare_widget($path);
}
sub labelframe {
    my $int = (ref $_[0]?shift:$tkinterp);
    my ($path) = $int->call("labelframe", @_);
    return $int->declare_widget($path);
}
sub button {
    my $int = (ref $_[0]?shift:$tkinterp);
    my ($path) = $int->call("button", @_);
    return $int->declare_widget($path);
}
sub checkbutton {
    my $int = (ref $_[0]?shift:$tkinterp);
    my ($path) = $int->call("checkbutton", @_);
    return $int->declare_widget($path);
}
sub radiobutton {
    my $int = (ref $_[0]?shift:$tkinterp);
    my ($path) = $int->call("radiobutton", @_);
    return $int->declare_widget($path);
}
sub scale {
    my $int = (ref $_[0]?shift:$tkinterp);
    my ($path) = $int->call("scale", @_);
    return $int->declare_widget($path);
}
sub spinbox {
    my $int = (ref $_[0]?shift:$tkinterp);
    my ($path) = $int->call("spinbox", @_);
    return $int->declare_widget($path);
}
sub message {
    my $int = (ref $_[0]?shift:$tkinterp);
    my ($path) = $int->call("message", @_);
    return $int->declare_widget($path);
}
sub listbox {
    my $int = (ref $_[0]?shift:$tkinterp);
    my ($path) = $int->call("listbox", @_);
    return $int->declare_widget($path);
}
sub image {
    my $int = (ref $_[0]?shift:$tkinterp);
    my ($path) = $int->call("image", @_);
    return $int->declare_widget($path);
}
sub scrollbar {
    my $int = (ref $_[0]?shift:$tkinterp);
    my ($path) = $int->call("scrollbar", @_);
    return $int->declare_widget($path);
}
sub entry {
    my $int = (ref $_[0]?shift:$tkinterp);
    my ($path) = $int->call("entry", @_);
    return $int->declare_widget($path);
}
sub menu {
    my $int = (ref $_[0]?shift:$tkinterp);
    my ($path) = $int->call("menu", @_);
    return $int->declare_widget($path);
}
sub menubutton {
    my $int = (ref $_[0]?shift:$tkinterp);
    my ($path) = $int->call("menubutton", @_);
    return $int->declare_widget($path);
}
sub canvas {
    my $int = (ref $_[0]?shift:$tkinterp);
    my ($path) = $int->call("canvas", @_);
    return $int->declare_widget($path);
}
sub text {
    my $int = (ref $_[0]?shift:$tkinterp);
    my ($path) = $int->call("text", @_);
    return $int->declare_widget($path);
}
# subroutine awidget used to create [a]ny [widget]. Nothing complicated here,
# mainly needed for keeping track of this new widget and blessing it to right
#package
sub awidget {
    my $int = (ref $_[0]?shift:$tkinterp);
    my $wclass = shift;
    # Following is a suboptimal way of autoloading, there should exist a way
    # to Improve it.
    my $subtext = <<"EOS";
package Tcl::Tk;
sub $wclass {
    my \$int = (ref \$_[0]?shift:\$tkinterp);
    my (\$path) = \$int->call("$wclass", \@_);
    return \$int->declare_widget(\$path);
}
EOS
    unless ($wclass=~/^\w+$/) {
      # to prevent bad hackery -- imagine someone names widget
      # as 'text {print "I am new text widget!";`rm files`} sub realone'
      die "widget name '$wclass' contains not allowed characters";
    }
    eval "$subtext"; #this will create appropriate method.
    if ($#_>-1) {
      return eval "\$int->$wclass(\@_)";
    }
}
sub awidgets {
    my $int = (ref $_[0]?shift:$tkinterp);
    $int->awidget($_) for @_;
}
sub widget($@) {
    my $int = (ref $_[0]?shift:$tkinterp);
    my $wpath = shift;
    if (exists $w{$wpath}) {
        return $w{$wpath};
    }
    if ($wpath=~/^\.[.\w]+$/) {
        # It looks like widget path
	# We could ask Tcl about it by invoking
	# my @res = $int->Eval("info commands $wpath");
	# but we don't do it, as long as we allow any widget paths to
	# be used by user.
        return $int->declare_widget($wpath);
    }
}
sub widgets {
    \%w;
}

sub after { 
    my $int = (ref $_[0]?shift:$tkinterp);
$int->call("after", @_) }
sub bell { 
    my $int = (ref $_[0]?shift:$tkinterp);
$int->call("bell", @_) }
sub bindtags {
    my $int = (ref $_[0]?shift:$tkinterp);
$int->call("bindtags", @_) }
sub clipboard { 
    my $int = (ref $_[0]?shift:$tkinterp);
$int->call("clipboard", @_) }
sub destroy { 
    my $int = (ref $_[0]?shift:$tkinterp);
$int->call("destroy", @_) }
sub exit { 
    my $int = (ref $_[0]?shift:$tkinterp);
$int->call("exit", @_) }
sub fileevent {
    my $int = (ref $_[0]?shift:$tkinterp);
$int->call("fileevent", @_) }
sub focus {
    my $int = (ref $_[0]?shift:$tkinterp);
$int->call("focus", @_) }
sub grab {
    my $int = (ref $_[0]?shift:$tkinterp);
$int->call("grab", @_) }
sub lower {
    my $int = (ref $_[0]?shift:$tkinterp);
$int->call("lower", @_) }
sub option {
    my $int = (ref $_[0]?shift:$tkinterp);
$int->call("option", @_) }
sub place {
    my $int = (ref $_[0]?shift:$tkinterp);
$int->call("place", @_) }
sub raise {
    my $int = (ref $_[0]?shift:$tkinterp);
$int->call("raise", @_) }
sub selection {
    my $int = (ref $_[0]?shift:$tkinterp);
$int->call("selection", @_) }
sub tk {
    my $int = (ref $_[0]?shift:$tkinterp);
$int->call("tk", @_) }
sub tkwait {
    my $int = (ref $_[0]?shift:$tkinterp);
$int->call("tkwait", @_) }
sub update {
    my $int = (ref $_[0]?shift:$tkinterp);
$int->call("update", @_) }
sub winfo {
    my $int = (ref $_[0]?shift:$tkinterp);
$int->call("winfo", @_) }
sub wm {
    my $int = (ref $_[0]?shift:$tkinterp);
$int->call("wm", @_) }
sub property {
    my $int = (ref $_[0]?shift:$tkinterp);
$int->call("property", @_) }

sub tkbind {
    my $int = (ref $_[0]?shift:$tkinterp);
    $int->call("bind", @_);
}
sub tkpack {
    my $int = (ref $_[0]?shift:$tkinterp);
    $int->call("pack", @_)
}
sub grid {
    my $int = (ref $_[0]?shift:$tkinterp);
    $int->call("grid", @_)
}
# bind and pack geometry methods
sub bind {
    my $int = shift;
    $int->call("bind", @_);
}
sub pack {
    my $int = shift;
    $int->call("pack", @_)
}

package Tcl::Tk::Widget;

# returns interpreter that is associated with widget
sub interp {
    my $self = shift;
    return $wint{$$self};
}

#
# few geometry methods here, as syntax sugar to do
#  button(...)->pack;
#assume here that OO is reference to widget's path
#
sub pack {
  my $self = shift;
  $wint{$$self}->call("pack",$$self,@_);
  $self;
}
sub grid {
  my $self = shift;
  $wint{$$self}->call("grid",$$self,@_);
  $self;
}
sub place {
  my $self = shift;
  $wint{$$self}->call("place",$$self,@_);
  $self;
}
sub form {
  my $self = shift;
  $wint{$$self}->call("tixForm",$$self,@_);
  $self;
}

sub DESTROY {}			# do not let AUTOLOAD catch this method

#
# Let Tcl/Tk/Tix process required method via AUTOLOAD mechanism
#

sub AUTOLOAD {
    my $w = shift;
    my $method = $::Tcl::Tk::Widget::AUTOLOAD;
    $method =~ s/^Tcl::Tk::Widget::// or die "weird inheritance ($method)";
    $wint{$$w}->call($$w, $method, @_);
}

package Tcl::Tk::Widget::MainWindow;


sub DESTROY {}			# do not let AUTOLOAD catch this method

sub AUTOLOAD {
    my $w = shift;
    my $method = $::Tcl::Tk::Widget::MainWindow::AUTOLOAD;
    $method =~ s/^Tcl::Tk::Widget::MainWindow::// or die "weird inheritance ($method)";
    $wint{'.'}->call('.', $method, @_);
}

bootstrap Tcl::Tk;

1;

