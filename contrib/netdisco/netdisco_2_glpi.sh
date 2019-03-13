#!/bin/bash

# netdisco_2_glpi.sh - make fusioninventory-compatible xml from netdisco data
# format is netdisco_2_glpi.sh target

# POC Netdisco-to-Fusioninventory XML generator

# This is ugly, slow and commits the Cardinal Sin of directly querying the database,
# ...but it works....


# our local internal domain is mars. Yours might be venus or internal or something else.

export TARGET=$1".mars"
export IP=`host $TARGET | rev | cut -f1 -d" " | rev`

# pickup switch details known to ND. Get counters from RRD (if you want them, else leave that section out)
# this keeps switch loading to minimum 

## NB: SNMP implementations on switches and other devices are increasingly broken in terms of "standards compliance"
##  and also in terms of cpu consumption. The less they're polled the better. 

##  "Too many" polls from different NMS programs can affect networking performance!
##  As such, it is frequently beneficial to "proxy" as much as possible.

## Postel's Principle says to be conservative in what you send and liberal in what you accept,
## But there's nothing wrong with cleaning up what you accept and sending it along better formatted,
## Especially when some badly broken stuff can break the Net.


# NB for bash use:
# Whatever you do, keep the echoed $STRING part inside the speechmarks or random badness 
# may happen (read the bash manual on string quoting and the differences between single, double 
# or no quotemarks.)

#"firmwares" and "infos"
echo -e  "<?xml version=\"1.0\" encoding=\"UTF-8\" ?>"
echo -e  "<REQUEST>"
echo -e  "  <CONTENT>"
echo -e  "    <DEVICE>"
echo -e  "      <FIRMWARES>"
echo -e  "        <DESCRIPTION>device firmware</DESCRIPTION>"
        export MANUFACTURER=`echo -e  "select vendor from device where ip = '$IP' " | psql -Aqt `
echo -e  "        <MANUFACTURER>$MANUFACTURER</MANUFACTURER>"
        export MODEL=`echo -e  "select model from device where ip = '$IP' " | psql -Aqt `
echo -e  "        <NAME>$MODEL</NAME>"
echo -e  "        <TYPE>device</TYPE>"
        export VERSION=`echo -e  "select os_ver from device where ip = '$IP' " | psql -Aqt `
echo -e  "        <VERSION>$VERSION</VERSION>"
echo -e  "      </FIRMWARES>"
echo -e  "      <INFO>"
        export COMMENTS=`echo -e  "select description from device where ip = '$IP' " | psql -Aqt `
echo -e  "        <COMMENTS>$COMMENTS</COMMENTS>"
        export CONTACT=`echo -e  "select contact from device where ip = '$IP' " | psql -Aqt `
echo -e  "        <CONTACT>$CONTACT</CONTACT>"
echo -e  "        <FIRMWARE>$VERSION</FIRMWARE>"
## this is the GLPI device ID - leave at zero and let GLPI find it.
echo -e  "        <ID>0</ID>"
echo -e  "        <IPS>"                                                                                                                                                                                                                     
  for DEVIP in `echo -e  "select alias from device_ip where ip = '$IP' order by alias asc " | psql -Aqt `                                                                                                                                    
  do                                                                                                                                                                                                                                         
echo -e  "          <IP>$DEVIP</IP>"                                                                                                                                                                                                         
  done                                                                                                                                                                                                                                       
echo -e  "        </IPS>"                                                                                                                                                                                                                    
        export LOCATION=`echo -e  "select location from device where ip = '$IP' " | psql -Aqt `                                                                                                                                              
echo -e  "        <LOCATION>${LOCATION//\&/_}</LOCATION>"                                                                                                                                                                                    
        export DEVMAC=`echo -e  "select mac from device where ip = '$IP' " | psql -Aqt `                                                                                                                                                     
        if [ -z $DEVMAC ]; then                                                                                                                                                                                                              
           export DEVMAC=`echo -e  "select mac from node_ip where ip = '$IP' " | psql -Aqt `                                                                                                                                                 
        fi                                                                                                                                                                                                                                   
echo -e  "        <MAC>$DEVMAC</MAC>"                                                                                                                                                                                                        
echo -e  "        <MANUFACTURER>$MANUFACTURER</MANUFACTURER>"                                                                                                                                                                                
echo -e  "        <MODEL>$MODEL</MODEL>"                                                                                                                                                                                                     
        export NAME=`echo -e  "select name from device where ip = '$IP' " | psql -Aqt `                                                                                                                                                      
echo -e  "        <NAME>$NAME</NAME>"                                                                                                                                                                                                        
        export SERIAL=`echo -e  "select serial from device where ip = '$IP' " | psql -Aqt `

## Did Netdisco fail to pickup the serial number? (FIA would have too. ND looks in more places!)
## kludge in the MAC as the serial in this case (FI4G won't inmport without a serial)
        if [ -z "$SERIAL" ]; then
           export SERIAL=$MAC
        fi
## Huawei Cloudengines. 
### .1.3.6.1.2.1.47.1.1.1.1.11.
#Local kludge: This is a stack. If the Stack Master changes then so does the reported SN 
# (and the system MAC) which means that Fusion/GLPI treats it as a different (new) switch.
#
# There's a PR in train to handle this better
#
# Force the SN to remain constant.
        if [ $1 = "abcdaa" ]; then
           export SERIAL="210235924710EA00XXXX"
        fi
### .1.3.6.1.2.1.47.1.1.1.1.11.
        if [ $1 = "abcdab" ]; then
           export SERIAL="210235924710EA00XXXX"
        fi
### .1.3.6.1.2.1.47.1.1.1.1.11.
        if [ $1 = "abcdac" ]; then
           export SERIAL="210235924610EA00XXXX"
        fi
# this is a Huawei AC6605 access controller. Not a stack but the SN isn't detected)
### .1.3.6.1.2.1.47.1.1.1.1.11.9
        if [ $1 = "abcda4" ]; then
           export SERIAL="21023579169WH600XXXX"
        fi
### .1.3.6.1.2.1.47.1.1.1.1.11.9
        if [ $1 = "abcda9" ]; then
           export SERIAL="210235791610F200XXXX"
        fi
echo -e  "        <SERIAL>$SERIAL</SERIAL>"

### NB: if Serial and/or MAC are blank, things WILL break horribly and randomly.
###       It also means your switch is not supported - YET - and you need to generate a snmpwalk
###        then ask for assistance in the Netdisco groups.
###       Assistance is available on IRC freenode - #netdisco  or on http://netdisco.org/ 
###       (you need to register your handle thanks to spammer attacks)


echo -e  "        <TYPE>NETWORKING</TYPE>"

## this bit demonstrates the kind of thing I like about pgsql - it has a lot of builtin functions you can take ## for granted that require jumping through hoops in mysql. 
## Note that IP addresses, time, MACs and many other net-related things are stored internally as 
## numerics and converted to whatever you need when displayed. See postgres.org

        export UPTIME="("`echo -e  "select uptime from device where ip= '$IP' " | psql -Aqt `") "`echo -e  "select justify_hours ((select uptime from device where ip= '$IP') / 100 * interval '1s' ) " | psql -Aqt `
echo -e  "        <UPTIME>$UPTIME</UPTIME>"
echo -e  "      </INFO>"

# some fields returned from some switches have spaces in them. 
# which will mess up loops - so we need to stop that happening.
#  - first, save the interfield spacer
SAVEIFS=$IFS
# This changes the "interfield spacing" from whitespace to "newline"
IFS=$(echo -en "\n\b")
# We''ll change it back at the end of the script.

# and now, on with the show (oh glorious spaghetti code, how we love thee)
echo -e  "      <PORTS>"
for PORT in `echo -e  "select port from device_port where ip = '$IP' " | psql -Aqt `
 do
 echo -e  "        <PORT>"
        export IFDESCR=`echo -e  "select descr from device_port where ip = '$IP' and port = '$PORT' " | psql -Aqt `
 echo -e  "          <IFDESCR>$IFDESCR</IFDESCR>"
        export IFALIAS=`echo -e  "select name from device_port where ip = '$IP' and port = '$PORT' " | psql -Aqt `
 echo -e  "          <IFALIAS>$IFALIAS</IFALIAS>"
        export IFNAME=`echo -e  "select port from device_port where ip = '$IP' and port = '$PORT' " | psql -Aqt `
 echo -e  "          <IFNAME>$IFNAME</IFNAME>"

# make sure you are using Netdisco 2.40.6 or later (release 2019/3/06) or this won't work!
# There are other ways of extracting IFNUMBER but they aren't as reliable because some switches 
# (EG: Cisco sg300) give the same name to vlan AND vlanif so simple pattern matching isn't the answer.
        export IFNUMBER=`echo -e  "select ifindex from device_port_properties where ip = '$IP' and port = '$PORT' " | psql -Aqt `
echo -e  "          <IFNUMBER>$IFNUMBER</IFNUMBER>"

        export IFMTU=`echo -e  "select mtu from device_port where ip = '$IP' and port = '$PORT' " | psql -Aqt `
 echo -e  "          <IFMTU>$IFMTU</IFMTU>"
        export IFMAC=`echo -e  "select mac from device_port where ip = '$IP' and port = '$PORT' " | psql -Aqt `
## Some switches are broken and report bogus MACs here (eg: Zyxel XGS- series)
        case "$IFMAC" in
            00:00:00:00:00*)
                  export IFMAC=$DEVMAC
              ;;
            *)
         ###      placeholder add else anything needed here
        esac
 echo -e  "          <MAC>$IFMAC</MAC>"
        export IFLASTCHANGE=`echo -e  "select justify_hours ((select lastchange from device_port where ip= '$IP' and port='$PORT') / 100 * interval '1s' ) " | psql -Aqt `
 echo -e  "          <IFLASTCHANGE>$IFLASTCHANGE</IFLASTCHANGE>"

# have we got any IP addresses?
 if [[ `echo -e  "select count(alias) from device_ip where ip = '$IP' and port= '$PORT' " | psql -Aqt ` -ge 1 ]] ; then
        export PORTIP=`echo -e  "select alias from device_ip where ip = '$IP' and port= '$PORT' limit 1 " | psql -Aqt `
  echo -e  "          <IP>$PORTIP</IP>"
  echo -e  "          <IPS>"
   for PORTIP in `echo -e  "select alias from device_ip where ip = '$IP' and port= '$PORT' " | psql -Aqt `
   do
    echo -e  "             <IP>$PORTIP</IP>"
   done 
   echo -e  "          </IPS>"
 fi

        export IFSPEED=`echo -e  "select raw_speed from device_port_properties where ip = '$IP' and port= '$PORT' " | psql -Aqt `
 echo -e  "          <IFSPEED>$IFSPEED</IFSPEED>"

### this seems to be ifadminstatus 1=up, 2=down, 3=testing ###
        export IFINTERNALSTATUS=`echo -e  "select up_admin from device_port where ip = '$IP' and port = '$PORT' " | psql -Aqt `
 case "$IFINTERNALSTATUS" in
  up)
   echo -e "          <IFINTERNALSTATUS>1</IFINTERNALSTATUS>"
   ;;
  down)
   echo -e "          <IFINTERNALSTATUS>2</IFINTERNALSTATUS>"
   ;;
  *)
 esac

### this seems to be ifstatus 1=up, 2=down, 3=testing ###
        export IFSTATUS=`echo -e  "select up from device_port where ip = '$IP' and port = '$PORT' " | psql -Aqt `
        case "$IFSTATUS" in
         up)
          echo -e "          <IFSTATUS>1</IFSTATUS>"
          ;;
         down)
          echo -e "          <IFSTATUS>2</IFSTATUS>"
          ;;
         *)
        esac
 
#### portduplex 1=unknown 2=half 3=full - only valid for ethernet ports ###
        export IFPORTDUPLEX=`echo -e  "select duplex from device_port where ip = '$IP' and port = '$PORT' " | psql -Aqt `
 case "$IFPORTDUPLEX" in
  half)
   echo -e "          <IFPORTDUPLEX>2</IFPORTDUPLEX>"
   ;;
  full)
   echo -e "          <IFPORTDUPLEX>3</IFPORTDUPLEX>"
   ;;
  *)
 esac

# Huawei ports aren't always picked up properly. Force the issue
# Not that it matters 
# - FI4G has decided that Type 53 is a physical, not aggregate port.
#  Because some makers return 53 for real ports. Edit your plugin to fix.
 case "$IFDESCR" in
  NULL*)
    echo -e "          <IFTYPE>1</IFTYPE>"
    ;;
  InLoopBack*)
    echo -e "          <IFTYPE>24</IFTYPE>"
    ;;
  Vlanif*)
    echo -e "          <IFTYPE>53</IFTYPE>"
    ;;
  Eth-Trunk*)
    echo -e "          <IFTYPE>161</IFTYPE>"
    ;;
  Stack-Port*)
    echo -e "          <IFTYPE>161</IFTYPE>"
    ;;
  *)
  # iftype other=1, ethernetCsmacd=6, propPointToPointSerial=22, softwareLoopback=24
  # propVirtual=53, tunnel=131, l2vlan=135, ieee8023adLag=161, ifPwType=246, 
         export IFTYPE=`echo -e  "select type from device_port where ip = '$IP' and port = '$PORT' " | psql -Aqt `
  case "$IFTYPE" in
   other)
    echo -e "          <IFTYPE>1</IFTYPE>"
    ;;
   ethernetCsmacd)
    echo -e "          <IFTYPE>6</IFTYPE>"
    ;;
   propPointToPointSerial)
    echo -e "          <IFTYPE>22</IFTYPE>"
    ;;
   softwareLoopback)
    echo -e "          <IFTYPE>24</IFTYPE>"
    ;;
   propVirtual)
    echo -e "          <IFTYPE>53</IFTYPE>"
    ;;
   tunnel)
    echo -e "          <IFTYPE>131</IFTYPE>"
    ;;
   l2vlan)
    echo -e "          <IFTYPE>135</IFTYPE>"
    ;;
   ieee8023adLag)
    echo -e "          <IFTYPE>161</IFTYPE>"
    ;;
   ifPwType)
    echo -e "          <IFTYPE>246</IFTYPE>"
    ;;
   *)
  esac
 esac

#### #############################################################
#### netdisco can't provide these, get them elsewhere #
#### in my case, that's my rrd files. Your milage (and paths) may vary ####
### this section may be entirely optional - g-bougard can advise
        export RRDPORT=${PORT,,}
        export RRDFILE=/var/lib/mrtg/"$1"/"$1"_"${RRDPORT//\//_}".rrd
 if [ -f "$RRDFILE" ]; then
        export RRDSTATS=`rrdtool lastupdate "$RRDFILE" | tail -n1`
  if [ -n "$RRDSTATS" ]; then
        export IFINOCTETS=`echo $RRDSTATS | rev | cut -f2 -d" " | rev`
   echo -e  "          <IFINOCTETS>$IFINOCTETS</IFINOCTETS>"
   echo -e  "          <IFINERRORS>0</IFINERRORS>"
        export IFOUTOCTETS=`echo $RRDSTATS | rev | cut -f1 -d" " | rev`
   echo -e  "          <IFOUTOCTETS>$IFOUTOCTETS</IFOUTOCTETS>"
   echo -e  "          <IFOUTERRORS>0</IFOUTERRORS>"
  fi
 fi
#### #############################################################


### ND can tell if the neighbour is a "upstream" (switch), but glpi doesn't know how to handle that

## TRUNK == "More than one VLAN"
        export TRUNK=`echo -e  "select count(vlan) from device_port_vlan where ip = '$IP' and port= '$PORT' " | psql -Aqt `
 if [[ $TRUNK -le 1 ]]; then 
  echo -e  "          <TRUNK>0</TRUNK>"
 elif [[ $TRUNK -ge 2 ]]; then 
  echo -e  "          <TRUNK>1</TRUNK>"
 fi
 if [[ $TRUNK -ge 1 ]]; then 
  echo -e  "         <VLANS>"
  for VLAN in `echo -e  "select vlan from device_port_vlan where ip = '$IP' and port= '$PORT' " | psql -Aqt `
  do
   echo -e  "            <VLAN>"
        export VLANNAME=`echo -e "select description from device_vlan where ip = '$IP' and vlan= '$VLAN' " | psql -Aqt `

## If you have gvrp, vlans keep appearing on various switches without descriptions 
## and this adds bogons to GLPI. This just forcibly cleans that up

   case "$VLANNAME" in
    default)
      export VLANNAME="0001-DEFAULT"
      ;;
    DEFAULT)
      export VLANNAME="0001-DEFAULT"
      ;;
    default)
      export VLANNAME="0001-DEFAULT"
      ;;
    VLAN\ 0001)
      export VLANNAME="0001-DEFAULT"
      ;;
    VLAN\ 0069)
      export VLANNAME="0069-userspace"
      ;;
    VLAN\ 0070)
      export VLANNAME="0070-userspace"
      ;;
    VLAN\ 0071)
      export VLANNAME="0071-userspace"
      ;;
    VLAN\ 0073)
      export VLANNAME="0073-userspace"
      ;;
    VLAN\ 0256)
      export VLANNAME="0256-CGROUP"
      ;;
    VLAN\ 0500)
      export VLANNAME="0500-MULTICAST"
      ;;
    VLAN\ 0511)
      export VLANNAME="0511-Mailservers"
      ;;
    VLAN\ 511)
      export VLANNAME="0511-Mailservers"
      ;;
    MAIL-Heartbeat)
      export VLANNAME="0511-Mailservers"
      ;;
    VLAN\ 0640)
      export VLANNAME="0640-PRINTERS"
      ;;
    VLAN\ 0641)
      export VLANNAME="0641-IPMIS"
      ;;
    SWITCHES)
      export VLANNAME="0642-SWITCHES"
      ;;
    SWITCHES_142)
      export VLANNAME="0642-SWITCHES"
      ;;
    VLAN\ 0642)
      export VLANNAME="0642-SWITCHES"
      ;;
    VLAN\ 0643)
      export VLANNAME="0643-user-IPMIS"
      ;;
    VLAN\ 0645)
      export VLANNAME="0645-user-misc"
      ;;
    VLAN\ 0646)
      export VLANNAME="0646-UPS"
      ;;
    VLAN\ 0670)
      export VLANNAME="0670-Frobuzz(isol)"
      ;;
    VLAN\ 0671)
      export VLANNAME="0671-Foobar(isolated)"
      ;;
    VLAN\ 0672)
      export VLANNAME="0672-IMAGING"
      ;;
    VLAN\ 0700)
      export VLANNAME="0700-EDUROAM-WANSIDE"
      ;;
    VLAN\ 2000)
      export VLANNAME="2000-FIREWALL-ZONE"
      ;;
    VLAN\ 2001)
      export VLANNAME="2001-MAILFIREWALL"
      ;;
    VLAN\ 3500)
      export VLANNAME="3500-WAPS"
      ;;
    VLAN\ 3550)
      export VLANNAME="3550-EDUROAM-WAPSIDE"
      ;;
    VLAN\ 4003)
      export VLANNAME="4003-Packetfence-quarantine"
      ;;
    VLAN\ 4004)
      export VLANNAME="4004-Packetfence-reg"
      ;;
    VLAN\ 4059)
      export VLANNAME="4059-trill"
      ;;
    VLAN\ 4094)
      export VLANNAME="4094-parking"
      ;;
     *)
   esac

### NB: ND has fields to mark if this is tagged, untagged and if it's PVID.
###        BUT, the XML spec for FI-Agent has no indication showing these
###        so all vlans end up being imported UNTAGGED!
   echo -e  "              <NAME>$VLANNAME</NAME>"
   echo -e  "              <NUMBER>$VLAN</NUMBER>"
   echo -e  "            </VLAN>"
  done
  echo -e  "           </VLANS>"
 fi

## Aggregate = LACP trunking, portchannel, ethernet bonding, various other names for combining ports for higher Bandwidth.
        export AGGREGATE=`echo -e  "select is_master from device_port where ip = '$IP' and port= '$PORT' " | psql -Aqt `
 if [ "$AGGREGATE" == "t" ]; then
  echo -e  "          <AGGREGATE>"
  for SLAVEPORT in `echo -e  "select port from device_port where ip = '$IP' and slave_of= '$PORT' " | psql -Aqt `
   do 
        export SLAVEIFNUMBER=`echo -e "select ifindex from device_port_properties where ip = '$IP' and port = '$SLAVEPORT' " | psql -Aqt `
   echo -e  "            <PORT>$SLAVEIFNUMBER</PORT>"
  done
  echo -e  "          </AGGREGATE>"
 fi
  echo -e  "        <CONNECTIONS>"

## What MACs are on the far side of the link?
        export CONNECTIONS=`echo -e  "select count(mac) from node where switch = '$IP' and port= '$PORT' and active= 't' " | psql -Aqt `
 if [[ $CONNECTIONS -ge 1 ]]; then
  echo -e  "           <CONNECTION>"
  for REMOTEMAC in `echo -e  "select mac from node where switch = '$IP' and port= '$PORT' and active= 't' " | psql -Aqt `
   do
   echo -e  "             <MAC>$REMOTEMAC</MAC>"
  done
  echo -e  "           </CONNECTION>"
 fi


## Is this a LLDP/CDP neighbour? (fold this down to CDP for either)
        export CDP=`echo -e  "select count(remote_port) from device_port where ip = '$IP' and port= '$PORT' " | psql -Aqt `
 if [[ $CDP -ge 1 ]]; then
  echo -e  "            <CDP>1</CDP>"
  echo -e  "            <CONNECTION>"
        export SYSNAME=`echo -e  "select device.name from device join device_port on device.ip=device_port.remote_ip where device_port.ip='$IP' and port ='$PORT' " | psql -Aqt `
  if [ -n "$SYSNAME" ]; then
   echo -e  "             <SYSNAME>$SYSNAME</SYSNAME>"
  fi
        export SYSMAC=`echo -e  "select remote_id from device_port where ip = '$IP' and port= '$PORT' " | psql -Aqt `
  echo -e  "              <SYSMAC>$SYSMAC</SYSMAC>"
        export SYSIP=`echo -e  "select remote_ip from device_port where ip = '$IP' and port= '$PORT' " | psql -Aqt `
  echo -e  "              <IP>$SYSIP</IP>"
        export SYSIFDESCR=`echo -e  "select remote_port from device_port where ip = '$IP' and port= '$PORT' " | psql -Aqt `
  if [ -n "$SYSIFDESCR" ]; then
     ## Take care of Zyxel borkage
     if [ "$SYSIFDESCR" == "Sid 1, Port 46" ]; then
       export SYSIFDESCR="Switch  1 - Port 46"
     fi
     if [ "$SYSIFDESCR" == "Sid 1, Port 48" ]; then
       export SYSIFDESCR="Switch  1 - Port 48"
     fi
   echo -e  "              <IFDESCR>$SYSIFDESCR</IFDESCR>"
  fi
  export SYSIFNUMBER=`echo -e  "select ifindex from device_port_properties where ip = '$SYSIP' and port = '$SYSIFDESCR' " | psql -Aqt `
#####################################################
#### PURE KLUDGE AND ONLY FOR WAP WORK AT MY SITE until I wirk out how to interrogate them!
        export WAPCHECK=`echo -e  "select remote_is_wap from device_port_properties where ip = '$IP' and port= '$PORT' " | psql -Aqt `
  if [ "$WAPCHECK" == "t" ]; then
   export SYSIFNUMBER="1"
  fi
## same for IPphones - most have a switch and slave ports in them. 
## This is important if you don't want either device showing up as an unmanaged hubs
## with a cloud of other devices hanging off them.
       export PHONECHECK=`echo -e  "select remote_is_phone from device_port_properties where ip = '$IP' and port= '$PORT' " | psql -Aqt `
  if [ "$PHONECHECK" == "t" ]; then
   export SYSIFNUMBER="1"
  fi
#####################################################
 # this just covers remaining bases (switches we don't handle)
  if [ -z $SYSIFNUMBER ]; then 
   export SYSIFNUMBER="1"
  fi
  echo -e  "               <IFNUMBER>$SYSIFNUMBER</IFNUMBER>"
  
        export SYSDESCR=`echo -e  "select remote_type from device_port where ip = '$IP' and port= '$PORT' " | psql -Aqt `
  if [ -n "$SYSDESCR" ]; then
  echo -e  "               <SYSDESCR>$SYSDESCR</SYSDESCR>"
  fi
        export NODEMAC=`echo -e  "select mac from node_ip where ip='$SYSIP' " | psql -Aqt `
  echo -e  "              <MAC>$NODEMAC</MAC>"
  echo -e  "            </CONNECTION>"
 fi
  echo -e  "        </CONNECTIONS>"
 echo -e  "        </PORT>"
done
IFS=$SAVEIFS
echo -e  "      </PORTS>"
echo -e  "    </DEVICE>"
echo -e  "    <MODULEVERSION>3.1</MODULEVERSION>"
echo -e  "    <PROCESSNUMBER>1</PROCESSNUMBER>"
echo -e  "  </CONTENT>"
echo -e  "  <DEVICEID>foo</DEVICEID>"
echo -e  "  <QUERY>SNMPQUERY</QUERY>"
echo -e  "</REQUEST>"

exit 0
