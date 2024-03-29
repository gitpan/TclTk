# entry2.tcl --
#
# This demonstration script is the same as the entry1.tcl script
# except that it creates scrollbars for the entries.
#
# RCS: @(#) $Id: entry2.tcl,v 1.2 1998/09/14 18:23:28 stanton Exp $

our $widgetDemo;
unless ($widgetDemo) {
    die "This script should be run from the \"widget\" demo."
}

my $w = '.entry2';
$interp->call('destroy', $w);
toplevel $w;
wm('title', $w, "Entry Demonstration (with scrollbars)");
wm('iconname', $w, "entry2");
positionWindow($w);


$interp->label("$w.msg", -font=>$font, -wraplength=>'5i', -justify=>'left', -text=>"Three different entries are displayed below, with a scrollbar for each entry.  You can add characters by pointing, clicking and typing.  The normal Motif editing characters are supported, along with many Emacs bindings.  For example, Backspace and Control-h delete the character to the left of the insertion cursor and Delete and Control-d delete the chararacter to the right of the insertion cursor.  For entries that are too large to fit in the window all at once, you can scan through the entries with the scrollbars, or by dragging with mouse button2 pressed.")
  ->pack(-side=>'top');

$interp->frame("$w.buttons")
  ->pack("$w.buttons", qw/-side bottom -fill x -pady 2m/);
$interp->button("$w.buttons.dismiss", -text=>"Dismiss", -command=>"destroy $w");
$interp->button("$w.buttons.code", -text=>"See Code", -command=>"showCode $w");
$interp->pack("$w.buttons.dismiss", "$w.buttons.code", -side=>"left", -expand=>1);

$interp->frame("$w.frame", -borderwidth=>10)
  ->pack(qw/-side top -fill x -expand 1/);

entry("$w.frame.e1", -xscrollcommand=>"$w.frame.s1 set");
scrollbar("$w.frame.s1", -relief=>'sunken', -orient=>"horiz", -command=>
	"$w.frame.e1 xview");
frame("$w.frame.spacer1", -width=>20, -height=>10);
entry("$w.frame.e2", -xscrollcommand=>"$w.frame.s2 set");
scrollbar("$w.frame.s2", qw/-relief sunken -orient horiz -command/,
	"$w.frame.e2 xview");
frame("$w.frame.spacer2", -width=>20, -height=>10);
entry("$w.frame.e3", -xscrollcommand=>"$w.frame.s3 set");
scrollbar("$w.frame.s3", qw/-relief sunken -orient horiz -command/,
	"$w.frame.e3 xview");
tkpack "$w.frame.e1", "$w.frame.s1", "$w.frame.spacer1", "$w.frame.e2",
       "$w.frame.s2", "$w.frame.spacer2", "$w.frame.e3", "$w.frame.s3",
       -side=>'top', -fill=>'x';

widget("$w.frame.e1")->insert("0", "Initial value");
widget("$w.frame.e2")->insert("end", "This entry contains a long value, much too long ");
widget("$w.frame.e2")->insert("end", "to fit in the window at one time, so long in fact ");
widget("$w.frame.e2")->insert("end", "that you'll have to scan or scroll to see the end.");

