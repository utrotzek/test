package Net::UDAP::MessageOut;

# $Id$

use warnings;
use strict;
use Carp;

use version; our $VERSION = qv('0.1');

use Net::UDAP::Constant;
use Net::UDAP::Log;

use vars qw( $AUTOLOAD );    # Keep 'use strict' happy
use base qw(Class::Accessor);

my %field_default = (

    # define fields and default values here
    broadcast  => BROADCAST_OFF,
    dst_type   => DST_TYPE_ETH,
    dst_mac    => undef,
    src_type   => ADDR_TYPE_UDP,
    src_ip     => IP_ZERO,
    src_port   => PORT_ZERO,
    seq        => pack( 'n', 0x0001 ),    # unused
    udap_type  => UDAP_TYPE_UCP,
    ucp_flags  => pack( 'C', 0x01 ),      # unused?
    ucp_class  => UAP_CLASS_UCP,
    ucp_method => undef,
);

__PACKAGE__->follow_best_practice;
__PACKAGE__->mk_accessors( keys(%field_default) );

{

    sub new {
        my ( $caller, $arg_ref ) = @_;
        my $class = ref $caller || $caller;

        # make sure $arg_ref is a hash ref
        $arg_ref = {} unless defined $arg_ref;

        # values from $arg_ref over-write the defaults
        my %arg = ( %field_default, %{$arg_ref} );

        # A method must be specified, i.e. what type of packet is this?
        if ( !defined $arg{'ucp_method'} ) {
            croak(
                'Must specify ucp_method when create a new MessageOut object'
            );
        }

        # Set values and perform checks specific to each packet type
    SWITCH: {
            ( $arg{ucp_method} eq UCP_METHOD_DISCOVER ) && do {

                # Set values specific to discovery packets
                $arg{broadcast} = BROADCAST_ON;
                $arg{dst_mac}   = MAC_ZERO;
                last SWITCH;
            };

            # default action if ucp_method value recognised
            croak( 'Invalid ucp_method: '
                    . bytes_to_hex( $arg{ucp_method}, 4 ) );
        }

        my $self = bless {%arg}, $class;
        return $self;
    }

    sub packed {
        my $self = shift;

        # The first part of the msg is same for all msg types
        my $str .= $self->get_broadcast;
        $str    .= $self->get_dst_type;
        $str    .= $self->get_dst_mac;      # mac stored packed
        $str    .= $self->get_src_type;
        $str    .= $self->get_src_ip;
        $str    .= $self->get_src_port;
        $str    .= $self->get_seq;
        $str    .= $self->get_udap_type;
        $str    .= $self->get_ucp_flags;
        $str    .= $self->get_ucp_class;
        $str    .= $self->get_ucp_method;

        return $str;
    }
}

1;    # Magic true value required at end of module
__END__

=head1 NAME

Net::UDAP::MessageOut - [One line description of module's purpose here]


=head1 VERSION

This document describes Net::UDAP::MessageOut version 0.1


=head1 SYNOPSIS

    use Net::UDAP::MessageOut;

=for author to fill in:
    Brief code example(s) here showing commonest usage(s).
    This section will be as far as many users bother reading
    so make it as educational and exeplary as possible.
  
  
=head1 DESCRIPTION

=for author to fill in:
    Write a full description of the module and its features here.
    Use subsections (=head2, =head3) as appropriate.


=head1 INTERFACE 

=for author to fill in:
    Write a separate section listing the public components of the modules
    interface. These normally consist of either subroutines that may be
    exported, or methods that may be called on objects belonging to the
    classes provided by the module.


=head1 DIAGNOSTICS

=for author to fill in:
    List every single error and warning message that the module can
    generate (even the ones that will "never happen"), with a full
    explanation of each problem, one or more likely causes, and any
    suggested remedies.

=over

=item C<< Error message here, perhaps with %s placeholders >>

[Description of error here]

=item C<< Another error message here >>

[Description of error here]

[Et cetera, et cetera]

=back


=head1 CONFIGURATION AND ENVIRONMENT

=for author to fill in:
    A full explanation of any configuration system(s) used by the
    module, including the names and locations of any configuration
    files, and the meaning of any environment variables or properties
    that can be set. These descriptions must also include details of any
    configuration language used.
  
Net::UDAP::Message requires no configuration files or environment variables.


=head1 DEPENDENCIES

=for author to fill in:
    A list of all the other modules that this module relies upon,
    including any restrictions on versions, and an indication whether
    the module is part of the standard Perl distribution, part of the
    module's distribution, or must be installed separately. ]

None.


=head1 INCOMPATIBILITIES

=for author to fill in:
    A list of any modules that this module cannot be used in conjunction
    with. This may be due to name conflicts in the interface, or
    competition for system or program resources, or due to internal
    limitations of Perl (for example, many modules that use source code
    filters are mutually incompatible).

None reported.


=head1 BUGS AND LIMITATIONS

=for author to fill in:
    A list of known problems with the module, together with some
    indication Whether they are likely to be fixed in an upcoming
    release. Also a list of restrictions on the features the module
    does provide: data types that cannot be handled, performance issues
    and the circumstances in which they may arise, practical
    limitations on the size of data sets, special cases that are not
    (yet) handled, etc.

No bugs have been reported.

Please report any bugs or feature requests to
C<bug-net-udap-message@rt.cpan.org>, or through the web interface at
L<http://rt.cpan.org>.


=head1 AUTHOR

Robin Bowes  C<< <robin@robinbowes.com> >>


=head1 LICENCE AND COPYRIGHT

Copyright (c) 2008, Robin Bowes C<< <robin@robinbowes.com> >>. All rights reserved.

This module is free software; you can redistribute it and/or
modify it under the same terms as Perl itself. See L<perlartistic>.


=head1 DISCLAIMER OF WARRANTY

BECAUSE THIS SOFTWARE IS LICENSED FREE OF CHARGE, THERE IS NO WARRANTY
FOR THE SOFTWARE, TO THE EXTENT PERMITTED BY APPLICABLE LAW. EXCEPT WHEN
OTHERWISE STATED IN WRITING THE COPYRIGHT HOLDERS AND/OR OTHER PARTIES
PROVIDE THE SOFTWARE "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER
EXPRESSED OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE. THE
ENTIRE RISK AS TO THE QUALITY AND PERFORMANCE OF THE SOFTWARE IS WITH
YOU. SHOULD THE SOFTWARE PROVE DEFECTIVE, YOU ASSUME THE COST OF ALL
NECESSARY SERVICING, REPAIR, OR CORRECTION.

IN NO EVENT UNLESS REQUIRED BY APPLICABLE LAW OR AGREED TO IN WRITING
WILL ANY COPYRIGHT HOLDER, OR ANY OTHER PARTY WHO MAY MODIFY AND/OR
REDISTRIBUTE THE SOFTWARE AS PERMITTED BY THE ABOVE LICENCE, BE
LIABLE TO YOU FOR DAMAGES, INCLUDING ANY GENERAL, SPECIAL, INCIDENTAL,
OR CONSEQUENTIAL DAMAGES ARISING OUT OF THE USE OR INABILITY TO USE
THE SOFTWARE (INCLUDING BUT NOT LIMITED TO LOSS OF DATA OR DATA BEING
RENDERED INACCURATE OR LOSSES SUSTAINED BY YOU OR THIRD PARTIES OR A
FAILURE OF THE SOFTWARE TO OPERATE WITH ANY OTHER SOFTWARE), EVEN IF
SUCH HOLDER OR OTHER PARTY HAS BEEN ADVISED OF THE POSSIBILITY OF
SUCH DAMAGES.

=cut

# vim:set softtabstop=4:
# vim:set shiftwidth=4:
