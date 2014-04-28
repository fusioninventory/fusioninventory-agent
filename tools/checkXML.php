#!/usr/bin/php
<?php

if (count($argv)<2) {
  print "Usage: $argv[0] filename.xml\n";
  exit(1);
}

$file = $argv[1];

if (!file_exists($file)) {
  print "Usage: can't read $file\n";
  exit(1);
}

$xmlstr = file_get_contents($file);
libxml_use_internal_errors(true);
$doc = @simplexml_load_string($xmlstr,'SimpleXMLElement', LIBXML_NOCDATA);
$xml = explode("\n", $xmlstr);

if (!$doc) {
    $errors = libxml_get_errors();

    foreach ($errors as $error) {
        echo display_xml_error($error, $xml);
    }

    libxml_clear_errors();
    exit(1);
} else {
    print "XML loaded successfully\n";
    exit(0);
}

function display_xml_error($error, $xml)
{
    $return  = $xml[$error->line - 1] . "\n";
    $return .= str_repeat('-', $error->column) . "^\n";

    switch ($error->level) {
        case LIBXML_ERR_WARNING:
            $return .= "Warning $error->code: ";
            break;
         case LIBXML_ERR_ERROR:
            $return .= "Error $error->code: ";
            break;
        case LIBXML_ERR_FATAL:
            $return .= "Fatal Error $error->code: ";
            break;
    }

    $return .= trim($error->message) .
               "\n  Line: $error->line" .
               "\n  Column: $error->column";

    if ($error->file) {
        $return .= "\n  File: $error->file";
    }

    return "$return\n\n--------------------------------------------\n\n";
}
