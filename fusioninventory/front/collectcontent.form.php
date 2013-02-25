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

$collect = new PluginFusioninventoryCollectcontent();

//Add a new collectcontent
if (isset($_POST["add"])) {
//we need to rebuild the post.

   $data = array( 'plugin_fusioninventory_collects_id' => $_POST['plugin_fusioninventory_collects_id'],
               'plugin_fusioninventory_collecttypes_id' => 
               $_POST['plugin_fusioninventory_collecttypes_id'],
               'name' => $_POST['name']);

   switch($_POST['plugin_fusioninventory_collecttypes_id']){

      //getFromRegistry
      case 1:
         $data['details'] = json_encode(array('path'       => $_POST['path'],
                                              'sixtyfour'  => 0, // not implemented yet
                                              'recursive'  => 0));
         
      break;

      //getFromWMI
      case 2:
         $a_properties = explode(',', $_POST['key']);
         $a_sendProperties = array();
         foreach ($a_properties as $property)
            if(!empty($property))
               $a_sendProperties[] = $property;

         if(count($a_sendProperties) > 0) {
            $data['details'] = json_encode(array( 'class' => $_POST['class'],
                                                  'properties'  => $a_sendProperties));
         }
      break;

      //findFile
      case 3:
         $fName = trim($_POST['filename']);
         if(empty($fName)) {
            Session::addMessageAfterRedirect($LANG['plugin_fusioninventory']['collect'][5]);
            Html::back();
         }
         $data['details'] = json_encode(array(  'dir'          => $_POST['dir'],
                                                'recursive'    => $_POST['path_recursive'],
                                                'limit'        => 5,
                                                'filter'       => 
                                                array('name'      => $fName,
                                                      'is_file'   => 1,
                                                      'is_dir'    => 0)));        
      break;

      //runCommand
      case 4:
         $data['details'] = json_encode(array('command'     => $_POST['command']));        
      break;
   }

   $collect->add($data);
   glpi_header($_SERVER['HTTP_REFERER']);
   
} else if (isset($_POST["delete_x"])) {

   $collect->getFromDB($_POST['id']);
   switch($collect->fields['plugin_fusioninventory_collecttypes_id']) {
      
      //getFromRegistry
      case 1:
         $item = new PluginFusioninventoryCollectregistrykey();
         $result = $item->find('name = "'.$collect->fields['name'].'"');
         break;

      case 2:
         // $item = new PluginFusioninventoryCollectregistrykey();
         // $result = $item->find('name = "'.$collect->fields['name'].'"');
         break;

      //findFile
      case 3:
         $item = new PluginFusioninventoryCollectfile();
         $result = $item->find('glpi_plugin_fusioninventory_collectcontents_id = '.$_POST['id']);
         break;         

      //runCommand
      case 4:
         $item = new PluginFusioninventoryCollectcommandresult();
         $result = $item->find('glpi_plugin_fusioninventory_collectcontents_id = '.$_POST['id']);
         break;  

   }

   //delete associated contents
   foreach($result as $row) 
      $item->delete(array('id' => $row['id']));

   //delete associated jobs
   $collectjob = new PluginFusioninventoryCollectjob();
   $result = $collectjob->find('glpi_plugin_fusioninventory_collectcontents_id = '.$_POST['id']);
   foreach($result as $row) 
      $item->delete(array('id' => $row['id']));   

   //delete the collect campaign
   $collect->delete($_POST);
   
   glpi_header($_SERVER['HTTP_REFERER']);

}else{ //shoudn't happen
   glpi_header($_SERVER['HTTP_REFERER']);
}

?>
