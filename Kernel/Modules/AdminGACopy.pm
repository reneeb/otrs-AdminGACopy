# --
# Copyright (C) 2017 Perl-Services.de, http://perl-services.de
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::Modules::AdminGACopy;

use strict;
use warnings;

use Kernel::Language qw(Translatable);

our $ObjectManagerDisabled = 1;

sub new {
    my ( $Type, %Param ) = @_;

    # allocate new hash for object
    my $Self = {%Param};
    bless( $Self, $Type );

    return $Self;
}

sub Run {
    my ( $Self, %Param ) = @_;

    my $ParamObject        = $Kernel::OM->Get('Kernel::System::Web::Request');
    my $LayoutObject       = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
    my $GenericAgentObject = $Kernel::OM->Get('Kernel::System::GenericAgent');

    # challenge token check for write action
    $LayoutObject->ChallengeTokenCheck();

    my ( %GetParam, %Errors );
    for my $Parameter (qw(ID)) {
        $GetParam{$Parameter} = $ParamObject->GetParam( Param => $Parameter ) || '';
    }

    my %List = $GenericAgentObject->JobList();
    my %Data = $GenericAgentObject->JobGet(
        Name => $GetParam{ID},
    );

    while( exists $List{ $Data{Name} } ) {
        $Data{Name} .= ' (Copy)';
    }

    my $TemplateID = $GenericAgentObject->JobAdd(
        Name   => $Data{Name},
        Data   => \%Data,
        UserID => $Self->{UserID},
    );

    return $LayoutObject->Redirect(
        OP => 'Action=AdminGenericAgent',
    );
}

1;
