BEGIN {
	$| = 1;
}
use Test::More tests => 11;
use File::Spec::Functions qw(catdir catfile);
use Module::Build::JSAN::Installable;
use Cwd;
use Capture::Tiny qw(capture);
use Path::Class;
use JSON;


diag( "Using Module::Build::JSAN::Installable $Module::Build::JSAN::Installable::VERSION" );


my $original_dir = cwd();
my $blib_dir = catdir qw(.. .. blib lib);

chdir(catdir(qw(t MBJI-Test1)));


#================================================================================================================================================================================================================================================
diag( "Running ./Build on test distribution #1" );

(undef, undef) = capture { system($^X, "-I$blib_dir", 'Build.PL'); };

ok(-e '_build', 'Build.PL appeared to execute correctly');
ok(-e 'Build', 'Building script was created');
ok(-e 'META.json', 'META.json was created');

my $build = Module::Build::JSAN::Installable->current();


#================================================================================================================================================================================================================================================
diag( "Checking 'author'" );

my $test2 = [ 
    'SamuraiJack <root@symbie.org>'
];

is_deeply($build->dist_author(), $test2, 'dist_author is correct (single)');



#================================================================================================================================================================================================================================================
diag( "Checking build elements" );

my $test3 = $Module::Build::VERSION ge '0.35_01' ? [qw(PL support pm xs share_dir pod script js static)] : [qw(PL support pm xs pod script js static)];

is_deeply($build->build_elements(), $test3, 'build_elements list is correct');


#================================================================================================================================================================================================================================================
diag( "Checking 'requires'" );

my $test4 = {
    'Cool.JS.Lib' => '1.1',
    'Another.Cool.JS.Lib' => '1.2'
};

is_deeply($build->requires(), $test4, 'requires list is correct');


#================================================================================================================================================================================================================================================
diag( "Checking 'build_requires'" );

my $test5 = {
    'Building.JS.Lib' => '1.1',
    'Another.Building.JS.Lib' => '1.2'
};

is_deeply($build->build_requires(), $test5, 'build_requires list is correct');


#================================================================================================================================================================================================================================================
diag( "Checking 'configure_requires'" );

is_deeply($build->configure_requires(), {}, 'configure_requires list is correct');


#================================================================================================================================================================================================================================================
diag( "Various options" );

is($build->license(), 'perl', 'license is correct');

is($build->create_makefile_pl(), 'passthrough', 'create_makefile_pl is correct');


#================================================================================================================================================================================================================================================
# Static directory name should be saved into META.json

my $meta = decode_json(file('META.json')->slurp() . "");

ok($meta->{static_dir} eq 'assets', 'Non-standard name for static dir was saved in meta-file');


# Cleanup
(undef, undef) = capture { $build->dispatch('realclean'); };
unlink('META.json') if -e 'META.json';
unlink('Build.bat') if -e 'Build.bat';
unlink('Build.com') if -e 'Build.com';

chdir($original_dir);