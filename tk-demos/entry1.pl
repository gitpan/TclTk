# entry1.tcl --
#
# This demonstration script creates several entry widgets without
# scrollbars.
#
# RCS: @(#) $Id: entry1.tcl,v 1.2 1998/09/14 18:23:28 stanton Exp $

our $widgetDemo;
unless ($widgetDemo) {
    die "This script should be run from the \"widget\" demo."
}

my $w = '.entry1';
$interp->call('destroy', $w);
toplevel $w;
wm('title', $w, "Entry Demonstration (no scrollbars)");
wm('iconname', $w, "entry1");
positionWindow($w);
$interp->label("$w.msg", -font=>$font, -wraplength=>'5i', -justify=>'left', -text=>"Three different entries are displayed below.  You can add characters by pointing, clicking and typing.  The normal Motif editing characters are supported, along with many Emacs bindings.  For example, Backspace and Control-h delete the character to the left of the insertion cursor and Delete and Control-d delete the chararacter to the right of the insertion cursor.  For entries that are too large to fit in the window all at once, you can scan through the entries by dragging with mouse button2 pressed.")
  ->pack(-side=>'top');

$interp->frame("$w.buttons")
  ->pack(qw/-side bottom -fill x -pady 2m/);
$interp->button("$w.buttons.dismiss", -text=>"Dismiss", -command=>"destroy $w");
$interp->button("$w.buttons.code", -text=>"See Code", -command=>"showCode $w");
$interp->pack("$w.buttons.dismiss", "$w.buttons.code", -side=>"left", -expand=>1);

$interp->entry("$w.e1")->insert(0, "Initial value");
my $e2 = $interp->entry("$w.e2");
$interp->entry("$w.e3");
$interp->pack("$w.e1", "$w.e2", "$w.e3", -side=>"top", -pady=>5, -padx=>10, -fill=>"x");

$e2->insert("end", "This entry contains a long value, much too long ");
$e2->insert("end", "to fit in the window at one time, so long in fact ");
$e2->insert("end", "that you'll have to scan or scroll to see the end.");

