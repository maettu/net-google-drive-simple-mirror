use strict;
use warnings;
package Net::Google::Drive::Simple::Mirror;
use Net::Google::Drive::Simple;
use DateTime::Format::RFC3339;
use DateTime;
use Carp;

sub new{
    my ($class, %options) = @_;

    croak "Local folder '$options{local_root}' not found"
        unless -d $options{local_root};
    $options{local_root} .= '/'
        unless $options{local_root} =~ m{/$};

    my $gd = Net::Google::Drive::Simple->new();
    $options{remote_root} = '/'.$options{remote_root}
        unless $options{remote_root} =~ m{^/};
    # XXX To support slashes in folder names in remote_root, I would have
    # to implement a different remote_root lookup mechanism here:
    my (undef, $remote_root_ID) = $gd->children( $options{remote_root});

    my $self = {
        remote_root_ID          => $remote_root_ID,
        export_format           => ['opendocument', 'html'],
        download_condition      => \&_should_download,
        force                   => undef,
        net_google_drive_simple => $gd,

        %options
    };

    bless $self, $class;
}

sub mirror{

}


sub _should_download{
    my ($self, $remote_file, $local_file) = @_;

    return 1 if $self->{force};

    my $date_time_parser = DateTime::Format::RFC3339->new();

    my $local_epoch =  (stat($local_file))[9];
    my $remote_epoch = $date_time_parser
                            ->parse_datetime($remote_file->modifiedDate())
                            ->epoch();

    if (-f $local_file and $remote_epoch < $local_epoch ){
        return 0;
    }
    else {
        return 1;
    }

}
1;

=head1 NAME

Net::Google::Drive::Simple::Mirror - Locally mirror a Google Drive folder structure

=head1 SYNOPSIS

    use Net::Google::Drive::Simple::Mirror;

    # requires a ~/.google-drive.yml file containing an access token,
    # see documentation of Net::Google::Drive::Simple
    my $google_docs = Net::Google::Drive::Simple::Mirror->new(
        remote_root => '/folder/on/google/docs',
        local_root  => 'local/folder',
        export_format => ['opendocument', 'html'],
    );

    $google_docs->mirror();


=head1 DESCRIPTION

Net::Google::Drive::Simple::Mirror allows you to locally mirror a folder structure from Google Drive.

=head2 GETTING STARTED

For setting up your access token see the documentation of Net::Google::Drive::Simple.

=head1 METHODS

=over 4

=item C<new()>

Creates a helper object to mirror a remote folder to a local folder.

Parameters:

remote_root: folder on your Google Docs account. See "CAVEATS" below.

local_root: local folder to put the mirrored files in.

export_format: anonymous array containing your preferred export formats.
Google Doc files may be exported to several formats. To get an idea of available formats, check 'exportLinks()' on a Google Drive Document or Spreadsheet, e.g.

    my $gd = Net::Google::Drive::Simple->new(); # 'Simple' not 'Mirror'
    my $children = $gd->children( '/path/to/folder/on/google/drive' );
    for my $child ( @$children ) {
        if ($child->can( 'exportLinks' )){
            foreach my $type (keys %{$child->exportLinks()}){
                print "$type";
            }
        }
    }

Now, specify strings that your preferred types match against. The default is ['opendocument', 'html']

download_condition: reference to a sub that takes the remote file name and the local file name as parameters. Returns true or false. The standard implementation is:
    # XXX put _should_download() here.

force: download all files and replace local copies.

=back

=head1 CAVEATS

At the moment, remote_root must not contain slashes in the file names of its folders.

    'Folder/Containing/Letters A/B'

Because folder "Letters A/B" contains a slash:
    Folder
         `--Containing
                     `--Letters A/B

This will be resolved to:
    Folder
         `--Containing
                     `--Letters A
                                `--B

The remote_root 'Example/root' may contain folders and files with slashes. These get replaced with underscores in the local file system.

    remote_root = 'Example/root';

    Example
          `--root
                `--Letters A/B

(Net::Google::Drive::Simple::Mirror uses folder ID's as soon as it has found the remote_root and does not depend on folder file names.)

