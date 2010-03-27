package FusionInventory::Agent::Task::Inventory::OS::Win32::Ports;
# Had never been tested. There is no slot on my virtal machine.
use strict;
use Win32::OLE qw(in CP_UTF8);
use Win32::OLE::Const;

Win32::OLE-> Option(CP=>CP_UTF8);

use Win32::OLE::Enum;

use Encode qw(encode);

sub isInventoryEnabled {1}

sub doInventory {

    my $params = shift;
    my $logger = $params->{logger};
    my $inventory = $params->{inventory};

    my $WMIServices = Win32::OLE->GetObject(
            "winmgmts:{impersonationLevel=impersonate,(security)}!//./" );

    if (!$WMIServices) {
        print Win32::OLE->LastError();
    }

#        uIndex = 0;
#        if (m_dllWMI.BeginEnumClassObject( _T( "Win32_SerialPort")))
#        {
#            while (m_dllWMI.MoveNextEnumClassObject())
#            {
#                myObject.SetType( SYSTEM_PORT_SERIAL);
#                csBuffer = m_dllWMI.GetClassObjectStringValue( _T( "Name"));
#                myObject.SetName( csBuffer);
#                csBuffer = m_dllWMI.GetClassObjectStringValue( _T( "Caption"));
#                myObject.SetCaption( csBuffer);
#                csBuffer = m_dllWMI.GetClassObjectStringValue( _T( "Description"));
#                myObject.SetDescription( csBuffer);
#                pMyList->AddTail( myObject);
#                uIndex ++;
#            }
#            m_dllWMI.CloseEnumClassObject();
#        }
#        if (uIndex > 0)
#        {
#            uTotal += uIndex;
#            AddLog( _T( "OK (%u objects)\n"), uIndex);
#        }
#        else
#            AddLog( _T( "Failed because no Win32_SerialPort object !\n"));
#    }
#    catch (CException *pEx)
#    {
#        pEx->Delete();
#        AddLog( _T( "Failed because unknown exception !\n"));
#    }
#    // Get parallel ports
#    AddLog( _T( "WMI GetSystemPorts: Trying to find Win32_ParallelPort WMI objects..."));
#    try
#    {
#        uIndex = 0;
#        if (m_dllWMI.BeginEnumClassObject( _T( "Win32_ParallelPort")))
#        {
#            while (m_dllWMI.MoveNextEnumClassObject())
#            {
#                myObject.SetType( SYSTEM_PORT_PARALLEL);
#                csBuffer = m_dllWMI.GetClassObjectStringValue( _T( "Name"));
#                myObject.SetName( csBuffer);
#                csBuffer = m_dllWMI.GetClassObjectStringValue( _T( "Caption"));
#                myObject.SetCaption( csBuffer);
#                csBuffer = m_dllWMI.GetClassObjectStringValue( _T( "Description"));
#                myObject.SetDescription( csBuffer);
#                pMyList->AddTail( myObject);
#                uIndex ++;
#

    my @ports;
    foreach my $Properties ( Win32::OLE::in( $WMIServices->InstancesOf(
                    'Win32_SerialPort' ) ) )
    {


        push @ports, {

            NAME => $Properties->{Name},
            CAPTION => $Properties->{Caption},
            DESCRIPTION => $Properties->{Description},

        };

    }

    foreach my $Properties ( Win32::OLE::in( $WMIServices->InstancesOf(
                    'Win32_ParallelPort' ) ) )
    {


        push @ports, {

            NAME => $Properties->{Name},
            CAPTION => $Properties->{Caption},
            DESCRIPTION => $Properties->{Description},

        };

    }

    foreach (@ports) {
        $inventory->addPorts($_);
    }

}
1;
