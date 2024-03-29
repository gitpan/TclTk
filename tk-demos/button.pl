# button.tcl --
#
# This demonstration script creates a toplevel window containing
# several button widgets.
#
# RCS: @(#) $Id: button.tcl,v 1.2 1998/09/14 18:23:27 stanton Exp $

our $widgetDemo;
unless ($widgetDemo) {
    die "This script should be run from the \"widget\" demo."
}

my $w = '.button';
$interp->call('destroy', $w);
toplevel $w;
wm('title', $w, "Button Demonstration");
wm('iconname', $w, "button");
positionWindow($w);

label "$w.msg", -font=>$font, -wraplength=>'4i', -justify=>'left', -text=>"If you click on any of the four buttons below, the background of the button area will change to the color indicated in the button.  You can press Tab to move among the buttons, then press Space to invoke the current button.";
tkpack "$w.msg", -side=>'top';

frame "$w.buttons";
tkpack "$w.buttons", -side=>'bottom', -fill=>'x', -pady=>'2m';
button "$w.buttons.dismiss", -text=>'Dismiss', -command=>"destroy $w";
button "$w.buttons.code", -text=>"See Code", -command=>"showCode $w";
tkpack "$w.buttons.dismiss", "$w.buttons.code", -side=>'left', -expand=>1;

# below are four similar methods to call callback implemented by three
# different methods
button "$w.b1", -text=>"Peach Puff", -width=>10,
    -command=>sub {$interp->Eval("$w config -bg PeachPuff1; $w.buttons config -bg PeachPuff1")};
button "$w.b2", -text=>"Light Blue", -width=>10,
    -command=>sub {
         $interp->call("$w", 'config', -bg=>'LightBlue1'); 
         $interp->call("$w.buttons", 'config', -bg=>'LightBlue1');
       };
button "$w.b3", -text=>"Sea Green", -width=>10,
    -command=>"$w config -bg SeaGreen2;  $w.buttons config -bg SeaGreen2";
button "$w.b4", -text=>"Yellow", -width=>10,
    -command=>"$w config -bg Yellow1;    $w.buttons config -bg Yellow1";
tkpack "$w.b1", "$w.b2", "$w.b3", "$w.b4", qw/-side top -expand yes -pady 2/;

