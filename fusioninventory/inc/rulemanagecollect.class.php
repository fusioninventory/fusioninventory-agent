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

/// FusionInventory Rules class
class PluginFusioninventoryRuleManageCollect extends Rule {

   const PATTERN_IS_EMPTY              = 30;
   const RULE_ACTION_LINK_OR_CREATE    = 0;
   const RULE_ACTION_LINK_OR_NO_CREATE = 1;
   const RULE_ACTION_DENIED            = 2;

   const LINK_RESULT_DENIED            = 0;
   const LINK_RESULT_CREATE            = 1;
   const LINK_RESULT_LINK              = 2;

   // From Rule
   public $right    = 'manage_collect';
   public $can_sort = true;


   function canCreate() {
      return PluginFusioninventoryProfile::haveRight("fusioninventory", "collect", "w");
   }


   function canView() {
      return PluginFusioninventoryProfile::haveRight("fusioninventory", "collect", "r");
   }



   function getTitle() {
      global $LANG;

      return $LANG['entity'][14];
   }



   function getCriterias() {
      global $LANG, $DB;

      $criterias = array ();

      $sql = "SELECT cc.id, ct.name as typeName, cc.name
              FROM glpi_plugin_fusioninventory_collectcontents as cc
              LEFT JOIN glpi_plugin_fusioninventory_collecttypes as ct
              ON cc.plugin_fusioninventory_collecttypes_id = ct.id
              LEFT JOIN glpi_plugin_fusioninventory_collects as c
              ON cc.plugin_fusioninventory_collects_id = c.id
              WHERE c.is_active = 1";

      $result = $DB->query($sql);



      if(!$result
         || !$DB->numrows($result)) {

         return $criterias;
      }

      $ruleActions = array(Rule::PATTERN_IS,Rule::PATTERN_IS_NOT,Rule::PATTERN_CONTAIN,
                           Rule::PATTERN_NOT_CONTAIN,Rule::PATTERN_BEGIN,Rule::PATTERN_END,
                           Rule::REGEX_MATCH,Rule::REGEX_NOT_MATCH);

      while ($row = $DB->fetch_array($result)) {
         $criterias[$row['id']]['table'] = 'glpi_plugin_fusioninventory_collectcontents';
         $criterias[$row['id']]['name'] = $row['typeName'].'::'.$row['name'];
         $criterias[$row['id']]['field'] = 'id';
         $criterias[$row['id']]['allow_condition'] = $ruleActions;
         $criterias[$row['id']]['type'] = $row['typeName'];
      }

      return $criterias;
   }



   function getActions() {
      global $PLUGIN_HOOKS, $LANG;

      if(!isset($PLUGIN_HOOKS['plugin_fusioninventory']['collect_get_actions']))
         $PLUGIN_HOOKS['plugin_fusioninventory']['collect_get_actions'] = array();

      $actions = $PLUGIN_HOOKS['plugin_fusioninventory']['collect_get_actions'];

      $actions['_change_state_id']['name']  = $LANG['plugin_fusioninventory']['rules'][33];
      $actions['_change_state_id']['type']  = 'dropdown';
      $actions['_change_state_id']['table'] = 'glpi_states';

      $actions['_assign_soft']['name']  = $LANG['plugin_fusioninventory']['rules'][34];
      $actions['_assign_soft']['type']  = "dropdown";
      $actions['_assign_soft']['table'] = "glpi_softwares";

      $actions['_assign_soft_version']['name']  = $LANG['plugin_fusioninventory']['rules'][35];
      $actions['_assign_soft_version']['force_actions'] =

      array('assign','regex_result');

      $actions['_assign_user']['name']  = $LANG['plugin_fusioninventory']['rules'][36];
      $actions['_assign_user']['type']  = "dropdown";
      $actions['_assign_user']['table'] = "glpi_users";

      $actions['_assign_location']['name']  = $LANG['plugin_fusioninventory']['rules'][37];
      $actions['_assign_location']['type']  = "dropdown";
      $actions['_assign_location']['table'] = "glpi_locations";

      $actions['_assign_operatingsystem']['name']  = $LANG['plugin_fusioninventory']['rules'][38];
      $actions['_assign_operatingsystem']['type']  = "dropdown";
      $actions['_assign_operatingsystem']['table'] = "glpi_operatingsystems";

      $actions['_assign_operatingsystemversion']['name']  = $LANG['plugin_fusioninventory']['rules'][39];
      $actions['_assign_operatingsystemversion']['type']  = "dropdown";
      $actions['_assign_operatingsystemversion']['table'] = "glpi_operatingsystemversions";

      $actions['_assign_computertype']['name']  = $LANG['plugin_fusioninventory']['rules'][40];
      $actions['_assign_computertype']['type']  = "dropdown";
      $actions['_assign_computertype']['table'] = "glpi_computertypes";

      $actions['_assign_computermodel']['name']  = $LANG['plugin_fusioninventory']['rules'][41];
      $actions['_assign_computermodel']['type']  = "dropdown";
      $actions['_assign_computermodel']['table'] = "glpi_computermodels";

      return $actions;
   }


   
   /**
    * Execute the actions as defined in the rule
    *
    * @param $output the fields to manipulate
    * @param $params parameters
    *
    * @return the $output array modified
   **/
   function executeActions($output, $params) {
      global $PLUGIN_HOOKS;

      if(!isset($PLUGIN_HOOKS['plugin_fusioninventory']['collect_execute_actions']))
         $PLUGIN_HOOKS['plugin_fusioninventory']['collect_execute_actions'] = array();

      if (isset($params['class'])) {
         $class = $params['class'];
      } else if (isset($_SESSION['plugin_fusioninventory_classrulepassed'])) {
         $classname = $_SESSION['plugin_fusioninventory_classrulepassed'];
         $class = new $classname();
      }

      if (count($this->actions)) {

         $duplicateActions = $this->actions;
         foreach ($this->actions as $action) {

            switch($action->fields["action_type"]) {

               case "regex_result":

                  switch($action->fields["field"]) {

                     case "_assign_soft_version":

                        $software = new Software();
                        foreach($duplicateActions as $tmpAction) {
                           if($tmpAction->fields["field"] == "_assign_soft") {
                              $software->getFromDB($tmpAction->fields['value']);
                           }
                        }

                        // If software doesn't exist, quit.
                        if(!isset($software->fields['id']))
                           break;

                        $softwareversionRegex
                           = RuleAction::getRegexResultById(
                              $action->fields["value"],
                              $this->regex_results[0]);

                        $softwareversion = new Softwareversion();
                        $sqlVersion  = "name = '{$softwareversionRegex}'";
                        $sqlVersion .= " AND softwares_id = {$software->fields['id']}";

                        $softversResult = $softwareversion->find($sqlVersion);

                        // If software version  doesn't exist, quit.
                        if(count($softversResult)===0)
                           break;

                        $softvers = reset($softversResult);
                        $softwareversion->getFromDB($softvers['id']);

                        $computerSoftwareVersion = new Computer_SoftwareVersion();

                        $sqlCsv  = "computers_id = {$params['computers_id']} ";
                        $sqlCsv .= "AND softwareversions_id = {$softwareversion->fields['id']}";

                        $resultCSV = $computerSoftwareVersion->find($sqlCsv);

                        $values = array();
                        $values['computers_id'] = $params['computers_id'];
                        $values['softwareversions_id'] = $softwareversion->getID();
                        $values['is_delete'] = 0;
                        $values['is_template'] = 0;

                        if(count($resultCSV) === 0) {
                           $computerSoftwareVersion->add($values);
                        } else {
                           $tmpArray = reset($resultCSV);
                           $values['id'] = $tmpArray['id'];
                           $computerSoftwareVersion->update($values);
                        }
                        break;
                  }

                  break;

               case "assign":

                  switch($action->fields["field"]) {

                     case "_assign_user":
                        if(isset($params['computers_id'])) {
                            $computerObject = new Computer();
                            $computerObject->update(
                                array('id' => $params['computers_id'],
                                    'users_id' => $action->fields["value"])
                            );
                        }
                        break;

                     case "_assign_location":
                        if(isset($params['computers_id'])) {
                           $computerObject = new Computer();
                           $computerObject->update(
                              array('id' => $params['computers_id'],
                                    'locations_id' => $action->fields["value"]));
                          }
                          break;

                     case "_assign_operatingsystem":
                        if(isset($params['computers_id'])) {
                            $computerObject = new Computer();
                            $computerObject->update(
                               array('id' => $params['computers_id'],
                                     'operatingsystems_id' => $action->fields["value"]));
                        }
                        break;

                     case "_assign_operatingsystemversion":
                        if(isset($params['computers_id'])) {
                            $computerObject = new Computer();
                            $computerObject->update(
                                array('id' => $params['computers_id'],
                                      'operatingsystemversions_id' => $action->fields["value"]));
                        }
                        break;

                     case "_assign_computertype":
                        if(isset($params['computers_id'])) {
                            $computerObject = new Computer();
                            $computerObject->update(
                                  array('id' => $params['computers_id'],
                                      'computertypes_id' => $action->fields["value"]));
                        }
                        break;

                     case "_assign_computermodel":
                        if(isset($params['computers_id'])) {
                            $computerObject = new Computer();
                            $computerObject->update(
                                array('id' => $params['computers_id'],
                                      'computermodels_id' => $action->fields["value"]));
                        }
                        break;

                      case "_change_state_id":

                       if(isset($params['computers_id'])) {
                          $computerObject = new Computer();
                          $computerObject->update(
                             array('id' => $params['computers_id'],
                                   'states_id' => $action->fields["value"])
                          );
                       }
                       break;

                    case '_assign_soft_version':

                       $software = new Software();
                       foreach($duplicateActions as $tmpAction) {
                          if($tmpAction->fields["field"] == "_assign_soft") {
                             $software->getFromDB($tmpAction->fields['value']);
                          }
                       }

                       // If software doesn't exist, quit.
                       if(!isset($software->fields['id']))
                          break;

                       $softwareversion = new Softwareversion();
                       $sqlVersion  = "name = '{$action->fields["value"]}'";
                       $sqlVersion .= " AND softwares_id = {$software->fields['id']}";

                       $softversResult = $softwareversion->find($sqlVersion);

                       // If software version  doesn't exist, quit.
                       if(count($softversResult)===0)
                          break;

                       $softvers = reset($softversResult);
                       $softwareversion->getFromDB($softvers['id']);

                       $computerSoftwareVersion = new Computer_SoftwareVersion();

                       $sqlCsv  = "computers_id = {$params['computers_id']} ";
                       $sqlCsv .= "AND softwareversions_id = {$softwareversion->fields['id']}";

                       $resultCSV = $computerSoftwareVersion->find($sqlCsv);

                       $values = array();
                       $values['computers_id'] = $params['computers_id'];
                       $values['softwareversions_id'] = $softwareversion->getID();
                       $values['is_delete'] = 0;
                       $values['is_template'] = 0;

                       if(count($resultCSV) === 0) {
                          $computerSoftwareVersion->add($values);
                       } else {
                          $tmpArray = reset($resultCSV);
                          $values['id'] = $tmpArray['id'];
                          $computerSoftwareVersion->update($values);
                       }

                       break;

                    default:

                       // If none of the predefined action is matched, we try the plugins one
                       $pluginHooksExAction
                          = $PLUGIN_HOOKS['plugin_fusioninventory']['collect_execute_actions'];

                       if(array_key_exists($action->fields["field"], $pluginHooksExAction)) {
                          if(method_exists($pluginHooksExAction[$action->fields["field"]][0],
                             $pluginHooksExAction[$action->fields["field"]][1]))

                          call_user_func($pluginHooksExAction[$action->fields["field"]], $params, $action);
                       }
                  }

               break;

            }

         }
      }
      return $output;
   }




  /**
    * Process a criteria of a rule
    *
    * @param $criteria criteria to check
    * @param $input the input data used to check criterias
   **/
   function checkCriteria(&$criteria, &$input) {

      $partial_regex_result = array();

      if(isset($input['key_id'])
         && $criteria->fields["criteria"] == $input['key_id']) {

         $input[$criteria->fields["criteria"]] = $input['value'];
      }

      // Undefine criteria field : set to blank
      if (!isset($input[$criteria->fields["criteria"]])) {
         $input[$criteria->fields["criteria"]] = '';
      }

      //If the value is not an array
      if (!is_array($input[$criteria->fields["criteria"]])) {
         $value = $this->getCriteriaValue($criteria->fields["criteria"],
                                          $criteria->fields["condition"],
                                          $input[$criteria->fields["criteria"]]);

         $res = RuleCriteria::match($criteria, $value, $this->criterias_results,
                                    $partial_regex_result);
      } else {
         //If the value is, in fact, an array of values
         // Negative condition : Need to match all condition (never be)
         if (in_array($criteria->fields["condition"], array(self::PATTERN_IS_NOT,
                                                            self::PATTERN_NOT_CONTAIN,
                                                            self::REGEX_NOT_MATCH,
                                                            self::PATTERN_DOES_NOT_EXISTS))) {
            $res = true;
            foreach ($input[$criteria->fields["criteria"]] as $tmp) {
               $value = $this->getCriteriaValue($criteria->fields["criteria"],
                                                $criteria->fields["condition"], $tmp);

               $res &= RuleCriteria::match($criteria, $value, $this->criterias_results,
                                           $partial_regex_result);
               if (!$res) {
                  break;
               }
            }

         // Positive condition : Need to match one
         } else {
            $res = false;
            foreach ($input[$criteria->fields["criteria"]] as $crit) {


               $value = $this->getCriteriaValue($criteria->fields["criteria"],
                                                $criteria->fields["condition"], $crit);

               $res |= RuleCriteria::match($criteria, $value, $this->criterias_results,
                                           $partial_regex_result);
            }
         }
      }

      // Found regex on this criteria
      if (count($partial_regex_result)) {
         // No regex existing : put found
         if (!count($this->regex_results)) {
            $this->regex_results = $partial_regex_result;

         } else { // Already existing regex : append found values
            $temp_result = array();
            foreach ($partial_regex_result as $new) {

               foreach ($this->regex_results as $old) {
                  $temp_result[] = array_merge($old,$new);
               }
            }
            $this->regex_results=$temp_result;
         }
      }

      return $res;
   }
}

?>
