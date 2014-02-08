use strict;
use warnings;
package Net::Google::Drive::Simple::Mirror;
use Net::Google::Drive::Simple;
use DateTime::Format::RFC3339;
use DateTime;

sub new{
    my ($class, %options) = @_;

    my $self = {

        force => undef,

        %options
    }

}

=head1 NAME

Net::Google::Drive::Simple::Mirror - Locally mirror a Google Drive folder structure

=head1 SYNOPSIS

    use Net::Google::Drive::Simple::Mirror;

    # requires a ~/.google-drive.yml file containing an access token,
    # see documentation of Net::Google::Drive::Simple
    my $google_docs = Net::Google::Drive::Simple::Mirror->new(
        remote_root => '/folder/on/google/docs',
        local_root  => 'local/folder',
    );

    $google_docs->mirror();


=head1 DESCRIPTION

Net::Google::Drive::Simple::Mirror allows you to locally mirror a folder structure from Google Drive.

=head2 GETTING STARTED

For setting up your access token see the documentation of Net::Google::Drive::Simple.

=head1 METHODS




1;
