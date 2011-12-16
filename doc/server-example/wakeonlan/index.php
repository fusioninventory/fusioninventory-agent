<?php

if ($_GET['action'] == 'getConfig') {
    print json_encode( array( 'macAddresses' => array ('00:23:18:a1:db:8d', '00:23:18:51:ab:7d', '00:23:18:91:dc:44') ) );
}
