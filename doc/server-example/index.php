<?php
if ($_GET['action']=='getConfig') {
    print json_encode(
            array(
                'configValidityPeriod' => 600,
                'schedule' => array (
                    array(
                        "periodicity" => 5600,
                        "task" => "Inventory",
                        "remote" => "http://".$_SERVER['SERVER_NAME'].":".$_SERVER['SERVER_PORT'].'/'.$_SERVER['REQUEST_URI'].'/inventory',
                        ),
                    array(
                        "periodicity" => 500,
                        "task" => "WakeOnLan",
                        "remote" => "http://".$_SERVER['SERVER_NAME'].":".$_SERVER['SERVER_PORT'].'/'.$_SERVER['REQUEST_URI'].'/wakeonlan',
                        "delayStartup" => 60
                        )
                    )
                )

        );
}
