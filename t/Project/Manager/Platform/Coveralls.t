use strict;
use warnings;
use Test::More;

use Project::Manager::Platform::Coveralls;
use Project::Manager::Platform::GitHub::User;
use Project::Manager::Config;
use Project::Manager::Platform::GitHub;

my $cv = Project::Manager::Platform::Coveralls->new;

my %cred = Project::Manager::Platform::GitHub->_get_github_user_pass;

#$cred{password} = ".";
$cv->auth_to_github( \%cred );

#use DDP; p $auth_github_redirect_to_coveralls;

use HTML::TreeBuilder::XPath;
my $coveralls_base = 'https://coveralls.io/';
my $coveralls_tree = HTML::TreeBuilder::XPath->new_from_content(
	$cv->ua->get($coveralls_base)->decoded_content
);

my @repos = $coveralls_tree->findnodes( q|//div[@class='repoOverview']| );
use DDP; p $repos[0]->as_HTML;
my @repos_text = map {
	my ($coverage_text_node) = $_->findnodes('.//div[contains(@class,"coverageText")]');
	my ($coveralls_org_node, $coveralls_repo_node) = $_->findnodes('.//h1/a');
	my $coverage_text =
	+{
		( $coverage_text_node ) ? (coverage =>  $coverage_text_node->as_trimmed_text) : (),
		coveralls_organisation => {
			name => $coveralls_org_node->as_trimmed_text,
			link => URI->new_abs($coveralls_org_node->attr('href'), $coveralls_base),
		},
		coveralls_repo => {
			name => $coveralls_repo_node->as_trimmed_text,
			link => URI->new_abs($coveralls_repo_node->attr('href'), $coveralls_base),
		},
		text => $_->as_trimmed_text,
	}
} @repos;
use DDP; p @repos_text;

$cv->repos;
