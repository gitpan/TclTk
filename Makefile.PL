# -- TODO -- call tclsh to discover it's parameters

use Tcl;

my %tclcfg;
my ($libpath, $incpath) = ('','');

my $interp = new Tcl;
$interp->Init();
my $tcl_library = $interp->GetVar('tcl_library');
my $tcl_version = $interp->GetVar('tcl_version');
$interp->Eval('package require Tk');
my $tk_version = $interp->GetVar('tk_version');
print STDERR "tcl_version=$tcl_version; tk_version=$tk_version\n";

s/\.// for $tcl_version, $tk_version;

if ($^O eq 'MSWin32') {
    $tcl_library =~ /^(.*)[\\\/]lib[\\\/]/;
    $libpath = "-L$1/lib";
    $incpath = "-I$1/include";
}

use ExtUtils::MakeMaker;
WriteMakefile(
	NAME => "Tcl::Tk",
	DISTNAME => "TclTk",
	VERSION_FROM => 'Tk.pm',
	PREREQ_PM => {
		Tcl => 0.4,
	},
	LIBS => ["$libpath -ltcl$tcl_version -ltk$tk_version"],
	INC => "$incpath",
      );
