#!/usr/bin/perl

# This program requires
# a Google Drive access token in '~/.google-drive.yml',
# a folder 'Mirror/Test/Folder' in your Google Drive,
#   Mirror
#        `--Test
#              `--Folder
# and a local folder 'test_data_mirror'.
#
# Also put some files in your Google Drive test folder.

use Modern::Perl;

use lib '../lib';
use Net::Google::Drive::Simple::Mirror;

my $google_docs = Net::Google::Drive::Simple::Mirror->new(
    remote_root             => 'Mirror/Test/Folder',
    local_root              => 'test_data_mirror',
    preferred_export_format => 'opendocument',
);
