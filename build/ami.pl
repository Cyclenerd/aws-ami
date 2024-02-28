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

# Open DB
my $dbFile  = './ami.db';
my $db = DBI->connect("dbi:SQLite:dbname=$dbFile","","") or die "ERROR: Cannot connect $DBI::errstr\n";

# Parse JSON
my $json;
while(<>){ $json .= $_ }

my $images = JSON::XS->new->utf8->decode($json);

foreach my $image (@{$images->{'Images'}}) {
	my $imageId         = $image->{'ImageId'}         || ""; # AMI
	my $name            = $image->{'Name'}            || "";

	my $architecture    = $image->{'Architecture'}    || "";
	my $bootMode        = $image->{'BootMode'}        || ""; # https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ami-boot.html
	my $creationDate    = $image->{'CreationDate'}    || "";
	my $deprecationTime = $image->{'DeprecationTime'} || "";
	my $description     = $image->{'Description'}     || "";
	my $enaSupport      = $image->{'EnaSupport'}      ? "1" : "0";
	my $hypervisor      = $image->{'Hypervisor'}      || "";
	my $imageLocation   = $image->{'ImageLocation'}   || "";
	my $imageType       = $image->{'ImageType'}       || "";
	my $ownerId         = $image->{'OwnerId'}         || "";
	my $platform        = $image->{'Platform'}        || "";
	my $platformDetails = $image->{'PlatformDetails'} || "";
	my $rootDeviceName  = $image->{'RootDeviceName'}  || "";
	my $rootDeviceType  = $image->{'RootDeviceType'}  || "";
	my $sriovNetSupport = $image->{'SriovNetSupport'} || "";
	my $state           = $image->{'State'}           || "";
	my $usageOperation  = $image->{'UsageOperation'}  || ""; # https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/billing-info-fields.html

	my $deviceName                   = $image->{'BlockDeviceMappings'}[0]->{'DeviceName'} || "";
	my $deviceEbsDeleteOnTermination = $image->{'BlockDeviceMappings'}[0]->{'Ebs'}->{'DeleteOnTermination'} ? "1" : "0";
	my $deviceEbsEncrypted           = $image->{'BlockDeviceMappings'}[0]->{'Ebs'}->{'Encrypted'}           ? "1" : "0";
	my $deviceEbsSnapshotId          = $image->{'BlockDeviceMappings'}[0]->{'Ebs'}->{'SnapshotId'}          || "";
	my $deviceEbsVolumeSize          = $image->{'BlockDeviceMappings'}[0]->{'Ebs'}->{'VolumeSize'}          || "0";
	my $deviceEbsVolumeType          = $image->{'BlockDeviceMappings'}[0]->{'Ebs'}->{'VolumeType'}          || "";

	if ($name) {
		print "$name\n";
	} else {
		die "ERROR: Image name missing!\n";
	}
	my $insert = qq ~
	INSERT INTO 'images' (
		'imageId',
		'name',
		'architecture',
		'bootMode',
		'creationDate',
		'deprecationTime',
		'description',
		'enaSupport',
		'hypervisor',
		'imageLocation',
		'imageType',
		'ownerId',
		'platform',
		'platformDetails',
		'rootDeviceName',
		'rootDeviceType',
		'sriovNetSupport',
		'state',
		'usageOperation',
		'deviceName',
		'deviceEbsDeleteOnTermination',
		'deviceEbsEncrypted',
		'deviceEbsSnapshotId',
		'deviceEbsVolumeSize',
		'deviceEbsVolumeType'
	) VALUES (
		'$imageId',
		'$name',
		'$architecture',
		'$bootMode',
		'$creationDate',
		'$deprecationTime',
		'$description',
		'$enaSupport',
		'$hypervisor',
		'$imageLocation',
		'$imageType',
		'$ownerId',
		'$platform',
		'$platformDetails',
		'$rootDeviceName',
		'$rootDeviceType',
		'$sriovNetSupport',
		'$state',
		'$usageOperation',
		'$deviceName',
		'$deviceEbsDeleteOnTermination',
		'$deviceEbsEncrypted',
		'$deviceEbsSnapshotId',
		'$deviceEbsVolumeSize',
		'$deviceEbsVolumeType'
	);
	~;
	$db->do($insert) or die "ERROR: Cannot insert location '$DBI::errstr'\n";
}