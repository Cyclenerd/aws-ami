#!/usr/bin/env bash

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

MY_DATABASE="ami.db"
MY_OPERATING_SYSTEMS_JSON="operating-systems.json"
MY_AWS_REGION="us-east-1"

echo "Create Database"
sqlite3 "$MY_DATABASE" < create.sql || exit 9

echo "Download Images"
mkdir -p "./import/"
jq -r '.[].owner' "$MY_OPERATING_SYSTEMS_JSON" | while read -r MY_OWNER_ID; do
	echo "$MY_OWNER_ID"
	aws ec2 describe-images --owner "$MY_OWNER_ID" --region "$MY_AWS_REGION" --output json > "./import/$MY_OWNER_ID.json" || exit 9
	perl ami.pl < "./import/$MY_OWNER_ID.json" || exit 9
done

echo "DONE"