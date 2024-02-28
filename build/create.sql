/*
 * Create SQLite3 database for Amazon AMI informations
 */

DROP TABLE IF EXISTS "images";
CREATE TABLE "images" (
	"imageId" TEXT NOT NULL DEFAULT "",
	"name" TEXT NOT NULL DEFAULT "",
	"architecture" TEXT NOT NULL DEFAULT "",
	"bootMode" TEXT NOT NULL DEFAULT "",
	"creationDate" TEXT NOT NULL DEFAULT "",
	"deprecationTime" TEXT NOT NULL DEFAULT "",
	"description" TEXT NOT NULL DEFAULT "",
	"enaSupport" INTEGER NOT NULL DEFAULT "0",
	"hypervisor" TEXT NOT NULL DEFAULT "",
	"imageLocation" TEXT NOT NULL DEFAULT "",
	"imageType" TEXT NOT NULL DEFAULT "",
	"ownerId" TEXT NOT NULL DEFAULT "",
	"platform" TEXT NOT NULL DEFAULT "",
	"platformDetails" TEXT NOT NULL DEFAULT "",
	"rootDeviceName" TEXT NOT NULL DEFAULT "",
	"rootDeviceType" TEXT NOT NULL DEFAULT "",
	"sriovNetSupport" TEXT NOT NULL DEFAULT "",
	"state" TEXT NOT NULL DEFAULT "",
	"usageOperation" TEXT NOT NULL DEFAULT "",
	"deviceName" TEXT NOT NULL DEFAULT "",
	"deviceEbsDeleteOnTermination" INTEGER NOT NULL DEFAULT "0",
	"deviceEbsEncrypted" INTEGER NOT NULL DEFAULT "0",
	"deviceEbsSnapshotId" TEXT NOT NULL DEFAULT "",
	"deviceEbsVolumeSize" INTEGER NOT NULL DEFAULT "0",
	"deviceEbsVolumeType" TEXT NOT NULL DEFAULT "",
	PRIMARY KEY("imageId")
);