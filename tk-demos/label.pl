# label.tcl --
#
# This demonstration script creates a toplevel window containing
# several label widgets.
#
# RCS: @(#) $Id: label.tcl,v 1.2 1998/09/14 18:23:29 stanton Exp $

our $widgetDemo;
unless ($widgetDemo) {
    die "This script should be run from the \"widget\" demo."
}

my $w = '.label';
$interp->call('destroy', $w);
toplevel $w;
wm('title', $w, "Label Demonstration");
wm('iconname', $w, "label");
positionWindow($w);

label "$w.msg", -font=>$::font, -wraplength=>'4i', -justify=>'left', -text=>"Five labels are displayed below: three textual ones on the left, and a bitmap label and a text label on the right.  Labels are pretty boring because you can't do anything with them.";
tkpack "$w.msg", -side=>'top';

frame "$w.buttons";
tkpack "$w.buttons", -side=>'bottom', -fill=>'x', -pady=>'2m';
button "$w.buttons.dismiss", -text=>'Dismiss', -command=>"destroy $w";
button "$w.buttons.code", -text=>"See Code", -command=>"showCode $w";
tkpack "$w.buttons.dismiss", "$w.buttons.code", -side=>'left', -expand=>1;

frame "$w.left";
frame "$w.right";
tkpack "$w.left", "$w.right", -side=>'left', -expand=>'yes', -padx=>10, -pady=>10, -fill=>'both';

label "$w.left.l1", -text=>"First label";
label "$w.left.l2", -text=>"Second label, raised", -relief=>'raised';
label "$w.left.l3", -text=>"Third label, sunken", -relief=>'sunken';
tkpack "$w.left.l1", "$w.left.l2", "$w.left.l3", -side=>'top', -expand=>'yes', -pady=>2, -anchor=>'w';

label "$w.right.bitmap", -borderwidth=>2, -relief=>'sunken',
	-bitmap=>"\@images/face.bmp";
label "$w.right.caption", -text=>"Tcl/Tk Proprietor";
tkpack "$w.right.bitmap", "$w.right.caption", -side=>'top';

