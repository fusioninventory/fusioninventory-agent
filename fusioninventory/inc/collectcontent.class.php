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

class PluginFusioninventoryCollectcontent extends CommonDBTM {

   // From CommonDBChild
   public $dohistory = true;



   
   static function getTypeName() {
      global $LANG;

      return $LANG['plugin_fusioninventory']['agents'][48];
   }

   
   function canCreate() {
      return PluginFusioninventoryProfile::haveRight("fusioninventory", "collect", "w");
   }


   function canView() {
      return PluginFusioninventoryProfile::haveRight("fusioninventory", "collect", "r");
   }

   
   function getTabNameForItem(CommonGLPI $item, $withtemplate=0) {
      global $LANG;
      
      if ($item->getType() == 'PluginFusioninventoryCollect') {
            return $LANG['plugin_fusioninventory']['collect'][1];
      }
      return '';
   }

   static function displayTabContentForItem(CommonGLPI $item, $tabnum=1, $withtemplate=0) {

      switch ($item->getType()) {
         case 'PluginFusioninventoryCollect' :
            self::showAssociated($item);
         break;
      }
      return true;
   }


   private function showAssociatedRegistryKeys($content){
      global $DB, $CFG_GLPI, $LANG;

      echo "<div class='spaced'><table class='tab_cadre_fixe'>";
      echo "<tr><th colspan=5>{$LANG['plugin_fusioninventory']['collect'][2]}</th></tr>";
      echo "<tr>
      <th>{$LANG['plugin_fusioninventory']['collect']['fields'][2]}</th>
      <th>{$LANG['plugin_fusioninventory']['collect']['fields'][1]}</th>
      <th>{$LANG['rulesengine'][30]}</th>
      </tr>";
      foreach($content as $data){

         //hack on unserialize bug
         $properties = json_decode($data['details']);
         
         echo "<td align='center'>{$data['name']}</td>";
         echo "<td align='center'>HKEY_LOCAL_MACHINE/{$properties->path}</td>";
         echo "<td align='center'>
         <form name='form_bundle_item' action='".getItemTypeFormURL(__CLASS__).
                "' method='post'>
         <input type='hidden' name='id' value='{$data['id']}'>
         <input type='image' name='delete' src='../pics/drop.png'>
         </form></td></tr>";
      }
      echo "</table></div>";

   }

   private function showAssociatedWmiProperties($content){
      global $DB, $CFG_GLPI, $LANG;

      echo "<div class='spaced'><table class='tab_cadre_fixe'>";
      echo "<tr><th colspan=4>{$LANG['plugin_fusioninventory']['collect'][2]}</th></tr>";
      echo "<tr>
      <th>{$LANG['plugin_fusioninventory']['collect']['fields'][2]}</th>
      <th>{$LANG['plugin_fusioninventory']['collect']['fields'][4]}</th>
      <th>{$LANG['plugin_fusioninventory']['collect']['fields'][5]}</th>
      <th>{$LANG['rulesengine'][30]}</th>
      </tr>";
      foreach($content as $data){
        
         $properties = json_decode($data['details']);
         
         echo "<td align='center'>{$data['name']}</td>";
         echo "<td align='center'>{$properties->class}</td>";
         echo "<td align='center'>".implode(',',$properties->properties)."</td>";
         echo "<td align='center'>
         <form name='form_bundle_item' action='".Toolbox::getItemTypeFormURL(__CLASS__).
                "' method='post'>
         <input type='hidden' name='id' value='{$data['id']}'>
         <input type='image' name='delete' src='../pics/drop.png'>";
         Html::closeForm(true);
         echo "</td></tr>";
      }
      echo "</table></div>";

   }

   private function showAssociatedFiles($content){
      global $DB, $CFG_GLPI, $LANG;

      echo "<div class='spaced'><table class='tab_cadre_fixe'>";
      echo "<tr><th colspan=5>{$LANG['plugin_fusioninventory']['collect'][2]}</th></tr>";
      echo "<tr>
      <th>{$LANG['plugin_fusioninventory']['collect']['fields'][2]}</th>
      <th>{$LANG['plugin_fusioninventory']['collect']['fields'][11]}</th>
      <th>{$LANG['plugin_fusioninventory']['collect']['fields'][6]}</th>
      <th>{$LANG['plugin_fusioninventory']['collect']['fields'][10]}</th>
      <th>{$LANG['rulesengine'][30]}</th>
      </tr>";
      foreach($content as $data){
        
         $properties = json_decode($data['details']);
         
         echo "<td align='center'>{$data['name']}</td>";
         echo "<td align='center'>{$properties->dir}</td>";
         echo "<td align='center'>{$properties->filter->name}</td>";
         echo "<td align='center'>";
         echo Dropdown::getYesNo($properties->recursive)."</td>";
         echo "<td align='center'>
         <form name='form_bundle_item' action='".Toolbox::getItemTypeFormURL(__CLASS__).
                "' method='post'>
         <input type='hidden' name='id' value='{$data['id']}'>
         <input type='image' name='delete' src='../pics/drop.png'>";
         Html::closeForm(true);
         echo "</td></tr>";
      }
      echo "</table></div>";

   }

   private function showAssociatedCommands($content){
      global $DB, $CFG_GLPI, $LANG;

      echo "<div class='spaced'><table class='tab_cadre_fixe'>";
      echo "<tr><th colspan=4>{$LANG['plugin_fusioninventory']['collect'][2]}</th></tr>";
      echo "<tr>
      <th>{$LANG['plugin_fusioninventory']['collect']['fields'][2]}</th>
      <th>{$LANG['plugin_fusioninventory']['collect']['fields'][8]}</th>
      <th>{$LANG['rulesengine'][30]}</th>
      </tr>";
      foreach($content as $data){
        
         $properties = json_decode($data['details']);
         
         echo "<td align='center'>{$data['name']}</td>";
         echo "<td align='center'>{$properties->command}</td>";
         echo "<td align='center'>
         <form name='form_bundle_item' action='".Toolbox::getItemTypeFormURL(__CLASS__).
                "' method='post'>
         <input type='hidden' name='id' value='{$data['id']}'>
         <input type='image' name='delete' src='../pics/drop.png'>";
         Html::closeForm(true);
         echo "</td></tr>";
      }
      echo "</table></div>";

   }


   static function showAssociated(CommonDBTM $item, $withtemplate='') {
      global $DB, $CFG_GLPI, $LANG;

      $is_template   = 0;
      $obj           = new PluginFusioninventoryCollectcontent;
      $ID            = $item->fields['id'];

      $content = $obj->find("plugin_fusioninventory_collects_id = {$ID}");



      //List the content (switched per type)

      switch($item->fields['plugin_fusioninventory_collecttypes_id']){
         //getFromRegistry
         case 1:
            $obj->showAssociatedRegistryKeys($content);
         break;

         //getFromWMI
         case 2:
            $obj->showAssociatedWmiProperties($content);
         break;

         //findFile
         case 3:
            $obj->showAssociatedFiles($content);
         break;

         //runCommand
         case 4:
            $obj->showAssociatedCommands($content);
         break;
      }

      //Form

      echo "<form name='form_bundle_item' action='".getItemTypeFormURL(__CLASS__).
                "' method='post'>";
      echo "<input type='hidden' name='plugin_fusioninventory_collects_id' value='$ID'>";
      echo "<input type='hidden' name='plugin_fusioninventory_collecttypes_id' 
      value='{$item->fields['plugin_fusioninventory_collecttypes_id']}'>";

      echo "<div class='spaced'><table class='tab_cadre_fixe'>";
      echo "<tr><th colspan=6>{$LANG['plugin_fusioninventory']['collect'][1]}</th></tr>";

      //output the form depending on the type of collect
      //Note : No edition, we drop/add to edit
      $type = $item->fields['plugin_fusioninventory_collecttypes_id'];

      //always ask for a name
      echo "<tr class='tab_bg_1'>";
      echo "<td>{$LANG['plugin_fusioninventory']['collect']['fields'][2]}&nbsp;:</td>";
      echo "<td><input type='text' name='name' value=''/></td>";

      switch($type){

         //getFromRegistry
         case 1:
            echo "<td>{$LANG['plugin_fusioninventory']['collect']['fields'][1]}&nbsp;:</td>";
            echo "<td>HKEY_LOCAL_MACHINE/<input type='text' name='path' value=''/></td></tr>";
            echo "<tr class='tab_bg_1'><td colspan=6 class='center'>";
            echo "<input type='submit' name='add' value=\"".$LANG['buttons'][8]."\" 
            class='submit'/></td>"; 
            echo "</table>";
         break;

         //getFromWMI
         case 2:
            echo "<td>{$LANG['plugin_fusioninventory']['collect']['fields'][4]}&nbsp;:</td>";
            echo "<td><input type='text' name='class' value=''/></td>";
            echo "<td>{$LANG['plugin_fusioninventory']['collect']['fields'][5]}&nbsp;:</td>";
            echo "<td><input type='text' name='key' value=''/> ";
            
            $options_tooltip = array('contentid' => "comment_".$type);
            $options_tooltip['link']       = false;
            $options_tooltip['linktarget'] = false;

            Html::showToolTip($LANG['plugin_fusioninventory']['collect']['tooltip'][1],$options_tooltip);
            echo "</td>";
            echo "</tr>";
            echo "<tr class='tab_bg_1'><td colspan=6 class='center'>";
            echo "<input type='submit' name='add' value=\"".$LANG['buttons'][8]."\" 
            class='submit'/></td>"; 
            echo "</table>";
         break;

         //findFile
         case 3:
            echo "<td>{$LANG['plugin_fusioninventory']['collect']['fields'][11]}&nbsp;:</td>";
            echo "<td><input type='text' name='dir' value=''/></td>";
            echo "<tr class='tab_bg_1'>";
            echo "<td>{$LANG['plugin_fusioninventory']['collect']['fields'][10]}&nbsp;:</td>";
            echo "<td>";
            Dropdown::showYesNo("path_recursive");
            echo "</td>";
            echo "<td>{$LANG['plugin_fusioninventory']['collect']['fields'][6]}&nbsp;:</td>";
            echo "<td><input type='text' name='filename' value=''/></td></tr>";
            echo "</tr>";
            echo "<tr class='tab_bg_1'><td colspan=6 class='center'>";
            echo "<input type='submit' name='add' value=\"".$LANG['buttons'][8]."\" 
            class='submit'/></td>"; 
            echo "</table>";
         break;
         
         //runCommand
         case 4:
            echo "<td>{$LANG['plugin_fusioninventory']['collect']['fields'][8]}&nbsp;:</td>";
            echo "<td><input type='text' name='command' value=''/></td>";
            echo "</tr>";
            echo "<tr class='tab_bg_1'><td colspan=6 class='center'>";
            echo "<input type='submit' name='add' value=\"".$LANG['buttons'][8]."\" 
            class='submit'/></td>"; 
            echo "</table>";
         break;
      }

      echo "</div>";
      echo "</form>";

   }
   
}

?>
