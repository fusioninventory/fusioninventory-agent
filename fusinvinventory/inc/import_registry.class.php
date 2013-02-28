<?php

/*
   ------------------------------------------------------------------------
   FusionInventory
   Copyright (C) 2010-2012 by the FusionInventory Development Team.

   http://www.fusioninventory.org/   http://forge.fusioninventory.org/
   ------------------------------------------------------------------------

   LICENSE

   This file is part of FusionInventory project.

   FusionInventory is free software: you can redistribute it and/or modify
   it under the terms of the GNU Affero General Public License as published by
   the Free Software Foundation, either version 3 of the License, or
   (at your option) any later version.

   FusionInventory is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
   GNU Affero General Public License for more details.

   You should have received a copy of the GNU Affero General Public License
   along with Behaviors. If not, see <http://www.gnu.org/licenses/>.

   ------------------------------------------------------------------------

   @package   FusionInventory
   @author    David Durieux
   @co-author 
   @copyright Copyright (c) 2010-2012 FusionInventory team
   @license   AGPL License 3.0 or (at your option) any later version
              http://www.gnu.org/licenses/agpl-3.0-standalone.html
   @link      http://www.fusioninventory.org/
   @link      http://forge.fusioninventory.org/projects/fusioninventory-for-glpi/
   @since     2010
 
   ------------------------------------------------------------------------
 */

if (!defined('GLPI_ROOT')) {
   die("Sorry. You can't access directly to this file");
}

class PluginFusinvinventoryImport_Registry extends CommonDBTM  {

   /**
   * Add registry key
   *
   * @param $idmachine integer id of the computer
   * @param $array array all values of the section
   *
   * @return id of the registry or false
   *
   **/
   function addRegistry($idmachine, $array) {
      global $LANG, $DB;

      //Get id from name
      $cco = new PluginFusioninventoryCollectcontent();
      $whereClause = "plugin_fusioninventory_collecttypes_id = 1 AND name = '{$array['NAME']}'";
      $result = $cco->find($whereClause);
      if(count($result) === 0) {
         return false;
      } else {
         $tmpArray = reset($result);
         $registryNameId = $tmpArray['id'];
      }

      if(!isset($array['REGVALUE'])) {
         return false;
      }

      // $rulecollection = new PluginFusioninventoryRuleManageCollectCollection();
      // $res_rule = $rulecollection->processAllRules(array('type' => 'getFromRegistry',
      //                                                    'name' => $array['NAME'],
      //                                                    'key_id' => $registryNameId,
      //                                                    'value' => $array['REGVALUE']), null, 
      //                                              array('computers_id'=>$idmachine));

      $registrykeyObject = new PluginFusioninventoryCollectregistrykey();

      $sqlAlreadyExist  = "computers_id = ".$idmachine." AND ";
      $sqlAlreadyExist .= 'name = "'.$array['NAME'].'"';

      $resultRegistrykeys = $registrykeyObject->find($sqlAlreadyExist);

      $registryValues = array(
         'name'         => $array['NAME'],
         'computers_id' => $idmachine,
         'plugin_fusioninventory_collectcontents_id' => $registryNameId,
         'value'        => $array['REGVALUE']
      );

      if(count($resultRegistrykeys) === 0) {
         return $registrykeyObject->add($registryValues);
      } else {
         $registryTmp = reset($resultRegistrykeys);
         $registryValues['id'] = $registryTmp['id'];
         $registrykeyObject->update($registryValues);
         return $registryValues['id'];
      }
   }

   function updateRegistry($idmachine, $array) {
      $this->addRegistry($idmachine, $array);
   }

   /**
   * Delete registry key
   *
   * @param $items_id integer id of the registry key
   * @param $idmachine integer id of the computer
   *
   * @return nothing
   *
   **/
   function deleteItem($items_id, $idmachine) {
      $registrykeyObject = new PluginFusioninventoryCollectregistrykey();
      $registrykeyObject->getFromDB($items_id);
      if ($registrykeyObject->fields['computers_id'] == $idmachine) {
         $input = array();
         $input['id'] = $items_id;
         $registrykeyObject->delete($input, 0);
      }
   }   
}

?>