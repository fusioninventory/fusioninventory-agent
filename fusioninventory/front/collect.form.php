<?php
/*
 * @version $Id: computer.form.php 15453 2011-08-22 10:12:56Z yllen $
 -------------------------------------------------------------------------
 GLPI - Gestionnaire Libre de Parc Informatique
 Copyright (C) 2003-2011 by the INDEPNET Development Team.

 http://indepnet.net/   http://glpi-project.org
 -------------------------------------------------------------------------

 LICENSE

 This file is part of GLPI.

 GLPI is free software; you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation; either version 2 of the License, or
 (at your option) any later version.

 GLPI is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.

 You should have received a copy of the GNU General Public License
 along with GLPI; if not, write to the Free Software Foundation, Inc.,
 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
 --------------------------------------------------------------------------
 */

// ----------------------------------------------------------------------
// Original Author of file:
// Purpose of file:
// ----------------------------------------------------------------------

define('GLPI_ROOT', '../../../');
include (GLPI_ROOT . "/inc/includes.php");


if (!isset($_GET["id"])) {
   $_GET["id"] = 0;
}

$collect = new PluginFusioninventoryCollect();
$collectcontent = new PluginFusioninventoryCollectcontent();

//Add a new collect
if (isset($_POST["add"])) {
   
   $newID = $collect->add($_POST);
   glpi_header($_SERVER['HTTP_REFERER']."?id=$newID");

// delete a collect
} else if (isset($_REQUEST["purge"])) {
   $details       = $collectcontent->find("plugin_fusioninventory_collects_id = {$_POST['id']}");
   
   //delete the detail properties
   foreach($details as $detail){
      $collectcontent->delete($detail);
   }
   //delete the content
   $collect->delete($_POST,1);
   $collect->redirectToList();
//update a collect
} else if (isset($_POST["update"])) {

   $collect->getFromDB($_POST['id']);

   if($collect->fields['plugin_fusioninventory_collecttypes_id'] 
   != $_POST['plugin_fusioninventory_collecttypes_id']){
      $details       = $collectcontent->find("plugin_fusioninventory_collects_id = {$_POST['id']}");
      foreach($details as $detail){
         $collectcontent->delete($detail,1);
      }
   }

   $collect->update($_POST);
   glpi_header($_SERVER['HTTP_REFERER']);

}else{
   
   commonHeader($LANG['plugin_fusioninventory']['menu'][8], $_SERVER['PHP_SELF'], "plugins", 
   "fusioninventory","collect");

   $collect->showForm($_GET['id']);

   commonFooter();
}

?>
