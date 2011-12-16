<?php


file_put_contents("files/".$_GET['machineid'].".json", $HTTP_RAW_POST_DATA);
