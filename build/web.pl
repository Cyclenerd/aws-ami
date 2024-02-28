#!/usr/bin/perl

# Copyright 2024 Nils Knieling. All Rights Reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

use strict;
use warnings;
use DBI;
use JSON::XS;
use Template;
use File::Copy;

# Operating Systems JSON
my $operatingSystemsJsonFile = './operating-systems.json';
open my $operatingSystemsJsonFh, "<", $operatingSystemsJsonFile or die "ERROR: Cannot open JSON file '$operatingSystemsJsonFile'!";
my $json = do { local $/; <$operatingSystemsJsonFh> };
my $operatingSystems = JSON::XS->new->utf8->decode($json);

# Open DB
my $dbFile  = './ami.db';
my $db = DBI->connect("dbi:SQLite:dbname=$dbFile","","") or die "ERROR: Cannot connect $DBI::errstr\n";

# Template
mkdir('../web/');
my $gmtime = gmtime();
my $timestamp = time();
my $template = Template->new(
	INCLUDE_PATH => './src',
	PRE_PROCESS  => 'config.tt2',
	VARIABLES => {
		'operatingSystems' => $operatingSystems,
		'gmtime'           => $gmtime,
		'timestamp'        => $timestamp,
		'gitHubServerUrl'  => $ENV{'GITHUB_SERVER_URL'} || '',
		'gitHubRepository' => $ENV{'GITHUB_REPOSITORY'} || '',
		'gitHubRunId'      => $ENV{'GITHUB_RUN_ID'}     || '',
	}
);

# JSON
my $imagesSql = qq ~
	SELECT
		name,
		creationDate,
		architecture,
		imageId,
		ownerId,
		description,
		platformDetails,
		usageOperation,
		deviceEbsVolumeSize,
		deviceEbsVolumeType
	FROM images
	WHERE "state" = "available"
	ORDER BY creationDate DESC;
~;
my $imagesSth = $db->prepare($imagesSql);
$imagesSth->execute();
my @images = ();
while (my $image = $imagesSth->fetchrow_hashref) { push(@images, $image) }
$imagesSth->finish;
my $imagesJson = encode_json \@images;
$template->process(
	'images.tt2',
	{ 'json' => $imagesJson },
	"../web/images.json"
) || die "Template process failed: ", $template->error(), "\n";	

# Pages
my @pages = (
	'404',
	'index',
	'robots',
);
foreach my $page (@pages) {
	print "$page\n";
	my $fileExtension = 'html';
	$fileExtension = 'txt' if ($page eq 'robots');
	$template->process(
		"$page.tt2",
		{},
		"../web/$page.$fileExtension"
	) || die "Template process failed: ", $template->error(), "\n";
}

# Favicon
my @favicons = (
	'favicon.ico',
	'favicon-16x16.png',
	'favicon-32x32.png',
	'apple-touch-icon.png',
	'android-chrome-192x192.png',
	'android-chrome-512x512.png',
	'site.webmanifest',
);
foreach my $favicon (@favicons) {
	copy("./src/img/favicon/$favicon", "../web/$favicon") || die "ERROR: Can not copy '$favicon'!\n";
}

print "DONE\n";