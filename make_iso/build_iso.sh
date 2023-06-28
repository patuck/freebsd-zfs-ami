#!/bin/sh

set -x
set -u
set -e

iso_file="${1}"
label=`file "${iso_file}" | awk -F "'" '{print $2}'`

# Create a directory for the release and extract the existing ISO file
rm -rf release-media
mkdir -p release-media
tar -x -C release-media -f "${iso_file}"

# Untar source from extracted release media to /usr/src
tar -x -C / -f release-media/usr/freebsd-dist/src.txz

# Copy in the installerconfig file
cp installerconfig release-media/etc/installerconfig

# Create an iso file called freebsd.iso
sh /usr/src/release/amd64/mkisoimages.sh -b "${label}" freebsd.iso release-media

# Cleanup
rm -rf release-media
rm -rf /usr/src/
