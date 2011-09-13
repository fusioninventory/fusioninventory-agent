<?xml version="1.0" ?>
<?xml-stylesheet href="/usr/share/nmap/nmap.xsl" type="text/xsl"?>
<!-- Nmap 4.62 scan initiated Sat Mar 26 19:06:30 2011 as: nmap -v -v -v -sP -PP -&#45;system-dns -&#45;max-retries 1 -&#45;max-rtt-timeout 1000ms -oX - google.com -->
<nmaprun scanner="nmap" args="nmap -v -v -v -sP -PP --system-dns --max-retries 1 --max-rtt-timeout 1000ms -oX - google.com" start="1301162790" startstr="Sat Mar 26 19:06:30 2011" version="4.62" xmloutputversion="1.02">
<verbose level="3" />
<debugging level="0" />
<taskbegin task="Ping Scan" time="1301162790" />
<taskend task="Ping Scan" time="1301162792" extrainfo="1 total hosts" />
<taskbegin task="System DNS resolution of 1 host." time="1301162792" />
<taskend task="System DNS resolution of 1 host." time="1301162792" />
<host><status state="down" reason="no-response"/>
<address addr="209.85.143.99" addrtype="ipv4" />
</host>
<runstats><finished time="1301162792" timestr="Sat Mar 26 19:06:32 2011"/><hosts up="0" down="1" total="1" />
<!-- Nmap done at Sat Mar 26 19:06:32 2011; 1 IP address (0 hosts up) scanned in 2.094 seconds -->
</runstats></nmaprun>
