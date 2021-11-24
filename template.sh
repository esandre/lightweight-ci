#!/bin/bash

source lightweight-ci.sh
cd <git repo root>

#Configuration
git_branch="<git branch to pull>"
dotnet_config="<dotnet configuration (Release/Dev/...)>"
iis_site="<IIS Site to stop&start>"
ssh_key="<path to gis private ssh key>"

git_fetch
git_reset
dotnet_build
dotnet_test

yes_or_no "Tests passed. Ready to deploy. Proceed ?" && publish
