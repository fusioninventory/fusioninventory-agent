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
   @author    Anthony Hébert
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

class PluginFusioninventoryCollect extends CommonDBTM {

   // From CommonDBChild
   public $dohistory = true;



   /**
    * Display name of itemtype
    * 
    * @global array $LANG
    * 
    * @return value name of this itemtype
    */
   static function getTypeName() {
      global $LANG;

      return $LANG['plugin_fusioninventory']['agents'][46];
   }

   
   function canCreate() {
      return PluginFusioninventoryProfile::haveRight("fusioninventory", "collect", "w");
   }


   function canView() {
      return PluginFusioninventoryProfile::haveRight("fusioninventory", "collect", "r");
   }


   function getSearchOptions() {
      global $LANG;

      $tab = array();
    
      $tab['common'] = $LANG['plugin_fusioninventory']['agents'][28];

      $tab[1]['table']     = $this->getTable();
      $tab[1]['field']     = 'name';
      $tab[1]['linkfield'] = 'name';
      $tab[1]['name']      = $LANG['common'][16];
      $tab[1]['datatype']  = 'itemlink';

      $tab[2]['table']     = 'glpi_plugin_fusioninventory_collecttypes';
      $tab[2]['field']     = 'name';
      $tab[2]['name']      = $LANG['common'][17];

      $tab[3]['table']     = $this->getTable();
      $tab[3]['field']     = 'is_active';
      $tab[3]['linkfield'] = 'is_active';
      $tab[3]['name']      = $LANG['common'][60];
      $tab[3]['datatype']  = 'bool';
      
      return $tab;
   }

   function showForm($ID, $options=array()) {
      global $CFG_GLPI, $LANG;

      if ($ID > 0) {
         $this->check($ID,'r');
         $this->getFromDB($ID);
      } else {
         // Create item
         $this->check(-1,'w');
      }
      
      $this->showTabs($options);
      $this->showFormHeader($options);


      echo "<tr class='tab_bg_1'>";
      echo "<td>".$LANG['common'][16]."&nbsp;:</td>";
      echo "<td><input type='hidden' name='id' value='{$this->fields['id']}'/>";
      //Html::autocompletionTextField($this, "name");
      echo "<input type='text' name='name' value='".$this->fields["name"]."'/>";
      echo "</td>";
      echo "<td>";
      echo $LANG['plugin_fusioninventory']['collect'][0]."&nbsp;:";
      echo "</td>";
      echo "<td>";
      
      $hasEntries = false;
      if ($ID > 0) {
         $cContent = new PluginFusioninventoryCollectcontent();
         if(count($cContent->find("plugin_fusioninventory_collects_id = ".$ID)) > 0)
            $hasEntries = true;
      }

      if($hasEntries) {

         $options_tooltip = array('contentid' => "comment_".$ID);
         $options_tooltip['link']       = false;
         $options_tooltip['linktarget'] = false;

         $cContenttype = new PluginFusioninventoryCollecttype();
         $cContenttype->getFromDB($this->fields['plugin_fusioninventory_collecttypes_id']);

         echo "<input type='hidden' value='".$this->fields['plugin_fusioninventory_collecttypes_id'];
         echo "' name='";
         echo "plugin_fusioninventory_collecttypes_id' />";
         echo $cContenttype->fields['name']."&nbsp;";
         showToolTip($LANG['plugin_fusioninventory']['collect']['tooltip'][2],$options_tooltip);

      } else {
         Dropdown::show('PluginFusioninventoryCollecttype', array(
                  'value'     => $this->fields['plugin_fusioninventory_collecttypes_id'],
                  'name'      => "plugin_fusioninventory_collecttypes_id",
                  'display_emptychoice' => false
         ));
      }
      echo "</td>";
      echo "</tr>";
      echo "<tr class='tab_bg_1'>";
      echo "<td>";
      echo $LANG['common'][60]."&nbsp;:";
      echo "</td>";
      echo "<td>";
      Dropdown::showYesNo("is_active", 
                          $this->fields['is_active']);
      echo "</td>";
      echo "<td>".$LANG['common'][25]."&nbsp;:</td>";
      echo "<td class='middle'>";
      echo "<textarea cols='45' rows='3' name='comment' >".$this->fields["comment"]."</textarea>";
      echo "</td></tr>";

      $this->showFormButtons($options);
      if ($ID > 0)
        $this->addDivForTabs();

      return true;
   }
   
   function defineTabs($options=array()) {
      global $LANG, $CFG_GLPI;

      $ong = array();
      $ong[0] = $LANG['plugin_fusioninventory']['profile'][7];
      return $ong;
   }




   /**
    * Get the list of jobs from all active collections
    * 
    * @param machineId computer_id
    * 
    * @return an array of jobs, extracted from each collection
    */
   static function getAllCollects($machineId){
      global $DB,$LANG;

      $o_Agent = new PluginFusioninventoryAgent();
      $result = $o_Agent->find("name = '{$machineId}'");

      if(count($result)==0) return false;

      $agentInfo = reset($result);
      $computerId = $agentInfo['items_id'];

      $jobs    = array();
      $obj     = new self;
      $content = new PluginFusioninventoryCollectcontent;

      //get active collections
      $collects = $obj->find("is_active = 1");
      $i = 0;
      foreach($collects as $collect){

         $contents = $content->find("plugin_fusioninventory_collects_id = {$collect['id']}");
         foreach($contents as $cContent){

            $function = PluginFusioninventoryCollecttype::getCollectTypeName(
                        $collect['plugin_fusioninventory_collecttypes_id']);

            $jobs[$i] = array('name'      => $cContent['name'],
                              'function'  => $function);

            $detail = json_decode($cContent['details']);

            $collectJob = new PluginFusioninventoryCollectjob();
            $sql = 'computers_id = '.$computerId.
                   ' AND glpi_plugin_fusioninventory_collectcontents_id = '.$cContent['id'];

            $resultJob = $collectJob->find($sql);
            $jobValues = array('computers_id' => $computerId,
                               'glpi_plugin_fusioninventory_collectcontents_id' => $cContent['id']);

            if(count($resultJob) == 0) {
               $uuid = $collectJob->add($jobValues);
            } else {
               $a_temp = reset($resultJob);
               $uuid = $a_temp['id'];
               $jobValues['id'] = $uuid;
               $collectJob->update($jobValues);
            }

            switch($function){
              case 'getFromRegistry':
                //for the registry, some changes are needed regarding the registry key
                $jobs[$i]['recursive']  = $detail->recursive;
                $jobs[$i]['64bit']      = (int)$detail->sixtyfour;
                $jobs[$i]['path']       = "HKEY_LOCAL_MACHINE";
                $jobs[$i]['path']      .= (substr($detail->path, 0,1) == '/') 
                                          ? $detail->path : '/'.$detail->path;
                $jobs[$i]['uuid']       = $uuid;

              break;

              default:
                $jobs[$i]['uuid'] = $uuid;
                foreach($detail as $k => $v){
                  $jobs[$i][$k] = $v;
                }  
              break;
            }
            $i++;
         }
      }
      return $jobs;
   }



   /**
    * process all collect answers
    * 
    * 
    * @return an array of jobs, extracted from each collection
    */
   static function setAnswer($params = array()){

      $uuid = $params['uuid'];
      $job = new PluginFusioninventoryCollectjob();
      $job->getFromDB($uuid);

      if(!isset($job->fields['glpi_plugin_fusioninventory_collectcontents_id'])) {
         return false;
      }

      $cContentId = $job->fields['glpi_plugin_fusioninventory_collectcontents_id'];

      $cContent = new PluginFusioninventoryCollectcontent();
      $cContent->getFromDB($cContentId);

      $jobValues = array('id' => $uuid);

      $machineId = $job->fields['computers_id'];

      $sql = 'computers_id = '.$machineId.' 
             AND glpi_plugin_fusioninventory_collectcontents_id = '.$cContentId;

      $cContentType = new PluginFusioninventoryCollecttype();
      $result = 
         $cContentType->find('id = '.$cContent->fields['plugin_fusioninventory_collecttypes_id']);
      $a_temp = reset($result);
      $cContentTypeName = $a_temp['name'];

      $rulecollection = new PluginFusioninventoryRuleManageCollectCollection();

      switch ($cContent->fields['plugin_fusioninventory_collecttypes_id']) {

         //getFromRegistry
         case '1':

            $keys = array();
            foreach ($params as $key => $value)
               if($key != "uuid" && $key != "action")
                  $keys[$key] = $value;

            $cKey = new PluginFusioninventoryCollectregistrykey();

            $result = $cKey->find('computers_id = '.$machineId.
                              ' AND glpi_plugin_fusioninventory_collectcontents_id = '.$cContentId);

            if(count($result) > 0)
               foreach ($result as $row) 
                  $cKey->delete(array('id' => $row['id']));

            if(count($keys)==0) return false;

            $cKeyValues = array('computers_id' => $machineId,
                                'glpi_plugin_fusioninventory_collectcontents_id  ' => $cContentId);

            foreach ($keys as $key => $value) {
               $cKeyValues['name'] = $key;
               $cKeyValues['value'] = $value;
               $cKeyValues['glpi_plugin_fusioninventory_collectcontents_id'] = $cContentId;
               $cKey->add($cKeyValues);

               $res_rule = $rulecollection->processAllRules(array('type' => 'getFromRegistry',
                                                                  'name' => $key,
                                                                  'value' => $value,
                                                                  'key_id' => $cContentId), null, 
                                                            array('computers_id'=>$machineId));
            }
            break;
         
         //getFromWMI
         case '2':

            $wmiProperties = array();
            foreach ($params as $key => $value)
               if($key != "uuid" && $key != "action")
                  $wmiProperties[$key] = $value;

            $cWMI = new PluginFusioninventoryCollectwmi();

            $result = $cWMI->find('computers_id = '.$machineId.
                              ' AND glpi_plugin_fusioninventory_collectcontents_id = '.$cContentId);

            if(count($result) > 0)
               foreach ($result as $row) 
                  $cWMI->delete(array('id' => $row['id']));

            if(count($wmiProperties)==0) return false;

            $cWMIValues = array('computers_id' => $machineId,
                                'glpi_plugin_fusioninventory_collectcontents_id' => $cContentId);

            foreach ($wmiProperties as $key => $value) {
               $cWMIValues['name'] = $key;
               $cWMIValues['value'] = htmlentities($value, ENT_QUOTES);
               $cWMI->add($cWMIValues);

               $res_rule = $rulecollection->processAllRules(array('type' => 'getFromWMI',
                                                                  'name' => $key,
                                                                  'value' => $value,
                                                                  'key_id' => $cContentId), null, 
                                                            array('computers_id'=>$machineId));
            }
            break;

         //findFile
         case '3':
            
            if(!isset($params['path']) 
               || !isset($params['size'])) {

               return false;
            }
            
            $path = $params['path'];
            $size = $params['size'];

            $cFile = new PluginFusioninventoryCollectfile();
            $cFileValues = array('path' => $path,
                                 'name' => $cContent->fields['name'],
                                 'size' => $size,
                                 'computers_id' => $machineId,
                                 'glpi_plugin_fusioninventory_collectcontents_id' => $cContentId);

            $result = $cFile->find($sql);
            if(count($result)>0) {
               $cFileOld = reset($result);
               $cFileValues['id'] = $cFileOld['id'];
               $cFile->update($cFileValues);
            } else {
               $cFile->add($cFileValues);
            }
            $res_rule = $rulecollection->processAllRules(array('type' => 'findFile',
                                                               'name' => $cContent->fields['name'],
                                                               'value' => $path,
                                                               'key_id' => $cContentId), null, 
                                                         array('computers_id'=>$machineId));
            break;

         //runCommand   
         case '4':
            
            if(!isset($params['output'])) return false;
            
            $output = $params['output'];

            $error = "";
            if(isset($params['error']))
               $error = $params['error'];

            $cCommand = new PluginFusioninventoryCollectcommandresult();

            $cCommandValues = array('name' => $cContent->fields['name'],
                                    'output' => $output,
                                    'error'  => $error,
                                    'computers_id' => $machineId,
                                 'glpi_plugin_fusioninventory_collectcontents_id' => $cContentId);

            $result = $cCommand->find($sql);
            if(count($result)>0) {
               $cCommandOld = reset($result);
               $cCommandValues['id'] = $cCommandOld['id'];
               $cCommand->update($cCommandValues);
            } else {
               $cCommand->add($cCommandValues);
            }
            $res_rule = $rulecollection->processAllRules(array('type' => 'runCommand',
                                                               'name' => $cContent->fields['name'],
                                                               'value' => $output,
                                                               'key_id' => $cContentId), null, 
                                                         array('computers_id'=>$machineId));
            break;
      }

      $jobValues['iteration'] = ++$job->fields['iteration'];
      $jobValues['log'] = serialize($params);
      $job->update($jobValues);

      return true;
   }
  


   /**
   * Delete collect information on computer
   *
   * @param $items_id integer id of the computer
   *
   * @return nothing
   *
   **/
   static function cleanComputer($items_id) {
      
      $pfCollectregistrykey = new PluginFusioninventoryCollectregistrykey();
      $pfCollectwmi         = new PluginFusioninventoryCollectwmi();
      $pfCollectrun         = new PluginFusioninventoryCollectcommandresult();
      $pfCollectfile        = new PluginFusioninventoryCollectfile();
      
      $pfCollectjob = new PluginFusioninventoryCollectjob();
            
      $a_collectregistrykey = $pfCollectregistrykey->find("`computers_id`='".$items_id."'");
      foreach ($a_collectregistrykey as $data) {
         $pfCollectregistrykey->delete($data);
      }

      $a_collectwmi = $pfCollectwmi->find("`computers_id`='".$items_id."'");
      foreach ($a_collectwmi as $data) {
         $pfCollectwmi->delete($data);
      }

      $a_collectrun = $pfCollectrun->find("`computers_id`='".$items_id."'");
      foreach ($a_collectrun as $data) {
         $pfCollectrun->delete($data);
      }

      $a_collectfile = $pfCollectfile->find("`computers_id`='".$items_id."'");
      foreach ($a_collectfile as $data) {
         $pfCollectfile->delete($data);
      }

      $a_collectjob = $pfCollectjob->find("`computers_id`='".$items_id."'");
      foreach ($a_collectjob as $data) {
         $pfCollectjob->delete($data);
      }

   }

}

?>