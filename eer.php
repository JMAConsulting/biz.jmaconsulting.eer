<?php
/**
 * Enhanced Event Registration extension improves how parents register kids
 * in CiviEvent 
 * 
 * Copyright (C) 2012 JMA Consulting
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License as
 * published by the Free Software Foundation, either version 3 of the
 * License, or (at your option) any later version.
 * 
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Affero General Public License for more details.
 * 
 * You should have received a copy of the GNU Affero General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 * 
 * Support: https://github.com/JMAConsulting/biz.jmaconsulting.eer/issues
 * 
 * Contact: info@jmaconsulting.biz
 *          JMA Consulting
 *          215 Spadina Ave, Ste 400
 *          Toronto, ON  
 *          Canada   M5T 2C7
 */

require_once 'eer.civix.php';

/**
 * Implementation of hook_civicrm_config
 */
function eer_civicrm_config(&$config) {
  _eer_civix_civicrm_config($config);
}

/**
 * Implementation of hook_civicrm_xmlMenu
 *
 * @param $files array(string)
 */
function eer_civicrm_xmlMenu(&$files) {
  _eer_civix_civicrm_xmlMenu($files);
}

/**
 * Implementation of hook_civicrm_install
 */
function eer_civicrm_install() {
  return _eer_civix_civicrm_install();
}

/**
 * Implementation of hook_civicrm_uninstall
 */
function eer_civicrm_uninstall() {
  return _eer_civix_civicrm_uninstall();
}

/**
 * Implementation of hook_civicrm_enable
 */
function eer_civicrm_enable() {
  return _eer_civix_civicrm_enable();
}

/**
 * Implementation of hook_civicrm_disable
 */
function eer_civicrm_disable() {
  return _eer_civix_civicrm_disable();
}

/**
 * Implementation of hook_civicrm_upgrade
 *
 * @param $op string, the type of operation being performed; 'check' or 'enqueue'
 * @param $queue CRM_Queue_Queue, (for 'enqueue') the modifiable list of pending up upgrade tasks
 *
 * @return mixed  based on op. for 'check', returns array(boolean) (TRUE if upgrades are pending)
 *                for 'enqueue', returns void
 */
function eer_civicrm_upgrade($op, CRM_Queue_Queue $queue = NULL) {
  return _eer_civix_civicrm_upgrade($op, $queue);
}

/**
 * Implementation of hook_civicrm_managed
 *
 * Generate a list of entities to create/deactivate/delete when this module
 * is installed, disabled, uninstalled.
 */
function eer_civicrm_managed(&$entities) {
  return _eer_civix_civicrm_managed($entities);
}

function eer_civicrm_buildForm( $formName, &$form  )  {
  $childName  = array( 1 => 'Second', 2 => 'Third', 3 => 'Fourth', 4 => 'Fifth', 5 => 'Sixth', 6 => 'Seventh');
 
  if( $formName == 'CRM_Event_Form_Registration_AdditionalParticipant' ) {
    $is_enhanced = CRM_Core_DAO::singleValueQuery( "SELECT is_enhanced FROM civicrm_event_enhanced WHERE event_id = {$form->_eventId}" );
    if ( $is_enhanced ) {
      foreach( $form->_fields as $fieldKey => $fieldValues ) {
        $partcipantCount = $form->getVar('_name');
        $pCount = explode('_', $partcipantCount);
        $fieldValues['groupTitle'] = $childName[$pCount[1]].' Child';
        $firstChild[$fieldKey] = $fieldValues;
      }
      $form->assign( 'additionalCustomPre', $firstChild );
    }
  }


  if( $formName == 'CRM_Event_Form_Registration_Confirm' || $formName == 'CRM_Event_Form_Registration_ThankYou' ) { 
    
    $is_enhanced = CRM_Core_DAO::singleValueQuery( "SELECT is_enhanced FROM civicrm_event_enhanced WHERE event_id = {$form->_eventId}" );
    if ( $is_enhanced ) {
      $profArray = array( 'Current User Profile' => 1, 'Other Parent Or Guardian' => 2, 'First Emergency Contacts' => 3, 'Second Emergency Contacts' => 4, 'New Individual' => 6 );
      $profiles = CRM_Core_DAO::executeQuery(" SELECT uf_group_id, title, weight FROM civicrm_event_enhanced_profile LEFT JOIN civicrm_uf_group ON civicrm_event_enhanced_profile.uf_group_id = civicrm_uf_group.id WHERE civicrm_event_enhanced_profile.event_id = {$form->_eventId} AND civicrm_event_enhanced_profile.area = 2  AND civicrm_uf_group.is_active =1 ORDER BY civicrm_event_enhanced_profile.weight ");
      while( $profiles->fetch( ) ) {
        $ids[] = $profiles->uf_group_id;
        $addedProfiles[] = $profiles->title;
      }
      $form->_fields = array();
      $contacts = $form->getVar('_params');
      foreach ( $ids as $profileKey => $profileID ) {
        $id[$profileKey] = $profileID;
        $form->buildCustom( $id , 'customPost' );
        unset($id[$profileKey]);
        $fields = CRM_Core_BAO_UFGroup::getFields( $profileID, false, CRM_Core_Action::ADD,
                                                   null , null, false, null,
                                                   false, null, CRM_Core_Permission::CREATE,
                                                   'field_name', true );
        //$profileKey = null;
        foreach( $fields as $key => $value ) {
          $profileKey = $profArray[$value['groupTitle']];
          $newKey = $key;
          if( !empty($profileKey) ) {
            if ( strstr( $key , 'custom' ) ) { 
              $newKey = $key.'#'.$profileKey;
            } else {
              $newKey = $key.$profileKey;
            }
          }
          $form->_fields[$newKey] = $form->_fields[$key];
          $form->_elementIndex[$newKey] = $form->_elementIndex[$key];
          $form->_elements[$form->_elementIndex[$key]]->_attributes['name'] = $newKey;
          //$form->_elements[$form->_elementIndex[$key]]->_flagFrozen = null;
          
          if ( !empty( $form->_submitValues ) ) {
              if( strstr($newKey, (string)$profArray['New Individual'] ) ) {
                if( isset( $form->_submitValues[$key] ) ) {
                  $form->_elements[$form->_elementIndex[$key]]->_attributes['value'] = $form->_submitValues[$key];
                } else {
                  unset($form->_elements[$form->_elementIndex[$key]]->_attributes['value']);
                }
              } else {
                if( isset( $form->_submitValues[$newKey] ) ) {
                  $form->_elements[$form->_elementIndex[$key]]->_attributes['value'] = $form->_submitValues[$newKey];
                } else {
                  unset($form->_elements[$form->_elementIndex[$key]]->_attributes['value']);
                }
              }  
          }
          $form->_elements[$form->_elementIndex[$key]]->_name = $newKey;
          $fields[$key]['name'] = $newKey;
          $form->_fields[$newKey] = $fields[$key];
          unset( $form->_defaultValues[$key] );
          unset( $form->_defaults[$key] );
          unset( $form->_elementIndex[$key] );
          unset( $form->_fields[$key] );
          unset( $form->_rules[$key] );
        }
      }
      $allCount = $individualCount = 0; $head = null;
      foreach( $form->_fields as $fieldKey => $fieldValue ) {
        $allCount++;
        if( $form->_fields[$fieldKey]['groupTitle'] == 'New Individual' ) {
          if( !isset( $head ) ) {
            $head = $allCount - 1;
          }
          $individualCount++;
          if( strstr( $fieldKey , 'custom' ) ) {
            $newKey = rtrim( $fieldKey, '#'.$profArray['New Individual'] );
          } else {
            $newKey = rtrim( $fieldKey, $profArray['New Individual'] );
          }
          $form->_fields[$fieldKey]['groupTitle'] = 'First Child';
          $form->_fields[$fieldKey]['name'] = $newKey;
          $form->_elementIndex[$newKey] = $form->_elementIndex[$fieldKey];
          $individual[$newKey] = $form->_fields[$fieldKey];
          $form->_elements[$form->_elementIndex[$fieldKey]]->_attributes['name'] = $newKey;
          $form->_elements[$form->_elementIndex[$fieldKey]]->_name = $newKey;
          unset($form->_fields[$fieldKey]);
          unset($form->_elementIndex[$fieldKey]);
        } 
      }
      
      if($individual) {
        $pre = array_slice( $form->_fields, 0, $head);
        $tail = array_slice( $form->_fields, $head , $allCount - $individualCount  );
        $form->_fields = array_merge( $pre, $individual, $tail );
      }
      
      foreach( $form->_fields as $newKey => $feildValue ) {
        if ( !empty( $contacts[0][$newKey] ) ) {
          $form->_elements[$form->_elementIndex[$newKey]]->_attributes['value'] = $contacts[0][$newKey];
          $form->_elements[$form->_elementIndex[$newKey]]->_values = array( $contacts[0][$newKey] );
          if ( array_key_exists('multiple', $form->_elements[$form->_elementIndex[$newKey]]->_attributes) ) {
            $form->_elements[$form->_elementIndex[$newKey]]->_values = $contacts[0][$newKey];
          } else {
            $form->_elements[$form->_elementIndex[$newKey]]->_values = array( $contacts[0][$newKey] );
          }
          if ( array_key_exists('_elements', (array) $form->_elements[$form->_elementIndex[$newKey]]) ) {
            foreach ($form->_elements[$form->_elementIndex[$newKey]]->_elements as $readioKey => $radioVal ) {
              if ($radioVal->_type == 'radio' ) {
                if ( $contacts[0][$newKey] == $form->_elements[$form->_elementIndex[$newKey]]->_elements[$readioKey]->_attributes['value']  ) {
                  $form->_elements[$form->_elementIndex[$newKey]]->_elements[$readioKey]->_attributes['checked'] = 'checked';
                } else {
                  $form->_elements[$form->_elementIndex[$newKey]]->_elements[$readioKey]->_attributes['checked'] = '';
                }

              }
              if ($radioVal->_type == 'checkbox' ) { 
                if ( $contacts[0][$newKey][$form->_elements[$form->_elementIndex[$newKey]]->_elements[$readioKey]->_attributes['id']]  == 1 ) {
                  $form->_elements[$form->_elementIndex[$newKey]]->_elements[$readioKey]->_attributes['checked'] = 'checked';
                } else {
                  $form->_elements[$form->_elementIndex[$newKey]]->_elements[$readioKey]->_attributes['checked'] = '';
                }
              } 
            }
          }
        }
      }
      // foreach($myFields as $myKey => $myVal ) {
      //   if( strstr( $myKey, 'billing') || strstr( $myKey, 'credit') || strstr( $myKey, 'cvv') ) {
      //     unset($myFields[$myKey]);
      //   }
      // }
      
      
      $form->assign( 'customPost', $form->_fields );
      $profilesPre = CRM_Core_DAO::executeQuery(" SELECT uf_group_id, title, weight FROM civicrm_event_enhanced_profile LEFT JOIN civicrm_uf_group ON civicrm_event_enhanced_profile.uf_group_id = civicrm_uf_group.id WHERE civicrm_event_enhanced_profile.event_id = {$form->_eventId} AND civicrm_event_enhanced_profile.area = 1  AND civicrm_uf_group.is_active = 1 ");

      
       while( $profilesPre->fetch( ) ) {
         $profilePre = $profilesPre->uf_group_id;
         $addedProfiles[] = $profilesPre->title;
       }
       
      $form->buildCustom( $profilePre , 'customPre' ); 
      $fields = CRM_Core_BAO_UFGroup::getFields( $profilePre, false, CRM_Core_Action::ADD,
                                                 null , null, false, null,
                                                 false, null, CRM_Core_Permission::CREATE,
                                                 'field_name', true );
      foreach( $fields as $fieldKey => $fieldValues ) {
        $newKey = $fieldKey;
        if( $fields[$fieldKey]['groupTitle'] == 'New Individual' ) {
          $fields[$fieldKey]['groupTitle'] = 'First Child';
        } else {
          if ( strstr( $fieldKey , 'custom' ) ) { 
            $newKey = $fieldKey.'#'.$profArray[$fieldValues['groupTitle']];
          } else {
            $newKey = $fieldKey.$profArray[$fieldValues['groupTitle']];
          }
        }

        $form->_fields[$newKey] = $form->_fields[$fieldKey];
        $form->_elementIndex[$newKey] = $form->_elementIndex[$fieldKey];
        $form->_elements[$form->_elementIndex[$fieldKey]]->_attributes['name'] = $newKey;
        if ( !empty( $form->_submitValues ) ) { 
          if( $formName == 'CRM_Event_Form_Registration_Confirm') {
            //if( isset( $form->_submitValues[$newKey] ) ) {
              $form->_elements[$form->_elementIndex[$fieldKey]]->_attributes['value'] = $form->_submitValues[$newKey];
            } else {
              unset($form->_elements[$form->_elementIndex[$fieldKey]]->_attributes['value']);
            }
            //}
        }
        $form->_elements[$form->_elementIndex[$fieldKey]]->_name = $newKey;
        $fields[$fieldKey]['name'] = $newKey;
        $form->_elements[$form->_elementIndex[$newKey]]->_attributes['value'] = $contacts[0][$newKey];
        if ( array_key_exists('multiple', $form->_elements[$form->_elementIndex[$newKey]]->_attributes) ) {
          $form->_elements[$form->_elementIndex[$newKey]]->_values = $contacts[0][$newKey];
        } else {
          $form->_elements[$form->_elementIndex[$newKey]]->_values = array( $contacts[0][$newKey] );
        }
        if ( array_key_exists('_elements', (array) $form->_elements[$form->_elementIndex[$newKey]]) ) {
          foreach ($form->_elements[$form->_elementIndex[$newKey]]->_elements as $readioKey => $radioVal ) {
            if ($radioVal->_type == 'radio' ) {
              if ( $contacts[0][$newKey] == $form->_elements[$form->_elementIndex[$newKey]]->_elements[$readioKey]->_attributes['value']  ) {
                $form->_elements[$form->_elementIndex[$newKey]]->_elements[$readioKey]->_attributes['checked'] = 'checked';
              } else {
                $form->_elements[$form->_elementIndex[$newKey]]->_elements[$readioKey]->_attributes['checked'] = '';
              }
            }
            
            if ($radioVal->_type == 'checkbox' ) {  
              if ( $contacts[0][$newKey][$form->_elements[$form->_elementIndex[$newKey]]->_elements[$readioKey]->_attributes['id']]  == 1 ) {
                $form->_elements[$form->_elementIndex[$newKey]]->_elements[$readioKey]->_attributes['checked'] = 'checked';
              } else {
                $form->_elements[$form->_elementIndex[$newKey]]->_elements[$readioKey]->_attributes['checked'] = '';
              }
            } 
          }
          if ( $form->_elements[$form->_elementIndex[$newKey]]->_type == 'file' ) {
            unset($form->_elements[$form->_elementIndex[$newKey]]);
            unset($firstChild[$newKey]);
          }
        }
        $firstChild[$newKey] = $fields[$fieldKey];
      } 
     
      $form->assign( 'customPre', $firstChild );
      
      foreach ( $contacts as $contactKey => $contactValue ) {
        if ( $contactKey != 0 ) {
          foreach( $contactValue as $contKey => $contVal ) {
            if( array_key_exists( $contKey, $form->_elementIndex ) ) {
              if ( array_key_exists('_elements', (array) $form->_elements[$form->_elementIndex[$contKey]]) ) {
                foreach ( $form->_elements[$form->_elementIndex[$contKey]]->_elements as $addKey  => $addVal ) {
                  if ($addVal->_type == 'radio' ) {
                    if ( $addVal->_attributes['value'] == $contVal ) {
                      $additionalParticipants[$contactKey]['additionalCustomPre'][$form->_elements[$form->_elementIndex[$contKey]]->_label] = $addVal->_text;
                    }
                  }
                  if ( $addVal->_type == 'checkbox' ) {
                    $checkBoxFields[$addVal->_attributes['id']] = $addVal->_text;
                  }
                }
                $check =  null;
                if ( !empty ( $checkBoxFields ) ) {
                  foreach ( $contVal as $checkKey => $checkVal ) {
                    if (!empty($checkVal))  {
                      $check = $check.', '.$checkBoxFields[$checkKey];
                    }
                  }
                  $check = ltrim($check, ', ');
                  $additionalParticipants[$contactKey]['additionalCustomPre'][$form->_elements[$form->_elementIndex[$contKey]]->_label] = $check;
                  $checkBoxFields =  Array( );
                }
              } else {
                foreach ( $form->_elements[$form->_elementIndex[$contKey]] as $addKey  => $addVal ) {
                  if ( $form->_elements[$form->_elementIndex[$contKey]]->_type == 'select' ) {
                    if ( array_key_exists('multiple', $form->_elements[$form->_elementIndex[$contKey]]->_attributes) ) { 
                      foreach( $form->_elements[$form->_elementIndex[$contKey]]->_options as $optionVal ) {
                        $multipleFields[$optionVal['attr']['value']] = $optionVal['text'];
                      }
                    } else {
                      // if(is_array($contVal)) {
                      //   $additionalParticipants[$contactKey]['additionalCustomPre'][$form->_elements[$form->_elementIndex[$contKey]]->_label] = $form->_elements[$form->_elementIndex[$contKey]]->_options[$contVal]['text'];
                      // } else {
                      foreach( $form->_elements[$form->_elementIndex[$contKey]]->_options as $optionVal ) {
                        $selectFields[$optionVal['attr']['value']] = $optionVal['text'];
                      }
                      $additionalParticipants[$contactKey]['additionalCustomPre'][$form->_elements[$form->_elementIndex[$contKey]]->_label] = $selectFields[$contVal];
                    }
                  } elseif( $form->_elements[$form->_elementIndex[$contKey]]->_type != 'hidden' ) {
                    if ( !empty($contVal) && !empty( $form->_elements[$form->_elementIndex[$contKey]]->_label ) ) {
                      $additionalParticipants[$contactKey]['additionalCustomPre'][$form->_elements[$form->_elementIndex[$contKey]]->_label] = $contVal;
                    }
                  } 
                  $check = null;
                  if ( !empty ( $multipleFields ) ) {
                    foreach ( $contVal as $checkKey => $checkVal ) {
                      $check = $check.', '.$multipleFields[$checkVal];
                    } 
                    $check = ltrim($check, ', ');
                    $additionalParticipants[$contactKey]['additionalCustomPre'][$form->_elements[$form->_elementIndex[$contKey]]->_label]= $check;
                    $multipleFields = Array();
                  }
                }
              }
            }
            $additionalParticipants[$contactKey]['additionalCustomPreGroupTitle'] = $childName[$contactKey].' Child';
          } 
        }
      }
      if ( !empty($additionalParticipants) ) {
        $form->assign( 'addParticipantProfile', $additionalParticipants );
      }
      $config =& CRM_Core_Config::singleton( );
      $config->_form = $form;
      $config->_addedProfiles = $addedProfiles;
      $config->_is_shareAdd = $contacts[0]['is_shareAdd'];
      $config->_is_spouse   = $contacts[0]['is_spouse'];
      
    } 
    // if( $formName == 'CRM_Event_Form_Registration_Confirm' || $formName == 'CRM_Event_Form_Registration_ThankYou' ) {
  }

  
  if( $formName == 'CRM_Event_Form_Registration_Register' ) {
    $is_enhanced = CRM_Core_DAO::singleValueQuery( "SELECT is_enhanced FROM civicrm_event_enhanced WHERE event_id = {$form->_eventId}" );
    
    if ( $is_enhanced ) {
      $profileCount = CRM_Core_DAO::singleValueQuery( " SELECT count(id) FROM  civicrm_uf_group WHERE name IN ('biz_jmaconsulting_eer_your_registration_info', 'biz_jmaconsulting_eer_current_user_profile', 'biz_jmaconsulting_eer_other_parent_or_guardian', 'biz_jmaconsulting_eer_first_emergency_contacts', 'biz_jmaconsulting_eer_second_emergency_contacts') AND is_active = 1" );
      
      if ( $profileCount != 5 ) {
        $error = 'The Enhanced Event Registration module is misconfigured - please enable all profiles used in the configuration.';
        $form->addElement('hidden', 'email-51');
        $form->setElementError('email-51',$error);
      }
      $profArray = array( 'Current User Profile' => 1, 'Other Parent Or Guardian' => 2, 'First Emergency Contacts' => 3, 'Second Emergency Contacts' => 4, 'New Individual' => 6 );
      
      $profiles = CRM_Core_DAO::executeQuery(" SELECT uf_group_id, weight FROM civicrm_event_enhanced_profile LEFT JOIN civicrm_uf_group ON civicrm_event_enhanced_profile.uf_group_id = civicrm_uf_group.id WHERE civicrm_event_enhanced_profile.event_id = {$form->_eventId} AND civicrm_event_enhanced_profile.area = 2  AND civicrm_uf_group.is_active =1 ORDER BY civicrm_event_enhanced_profile.weight ");
      
      while( $profiles->fetch( ) ) {
        $ids[] = $profiles->uf_group_id;
      }
      $form->_fields = array();
      $option = array( '1' =>'Yes', '0' => "No" );
      $form->addRadio('is_spouse' , ts( 'Is my Spouse' ),$option, NULL,  NULL, FALSE);
      $form->addRadio('is_shareAdd',ts( 'Shares My Address' ),$option, NULL,  NULL, FALSE);
      $form->assign('addshareNspouse' , $is_enhanced );
      $contacts = $form->_submitValues;
      foreach ( $ids as $profileKey => $profileID ) {
        $id[$profileKey] = $profileID;
        $form->buildCustom( $id , 'customPost' );
        unset($id[$profileKey]);
        $fields = CRM_Core_BAO_UFGroup::getFields( $profileID, false, CRM_Core_Action::ADD,
                                                   null , null, false, null,
                                                   false, null, CRM_Core_Permission::CREATE,
                                                   'field_name', true );
        //$profileKey = null;
        foreach( $fields as $key => $value ) {
          $profileKey = $profArray[$value['groupTitle']];
          
          $newKey = $key;
          if( !empty($profileKey) ) {
            if ( strstr( $key , 'custom' ) ){ 
              $newKey = $key.'#'.$profileKey;
            } else {
              $newKey = $key.$profileKey;
            }
          }
          $form->_fields[$newKey] = $form->_fields[$key];
          $form->_elementIndex[$newKey] = $form->_elementIndex[$key];
          $form->_elements[$form->_elementIndex[$key]]->_attributes['name'] = $newKey;
          $form->_elements[$form->_elementIndex[$key]]->_flagFrozen = null;
          if ( !empty( $form->_submitValues ) ) {
            if( strstr($newKey, (string)$profArray['New Individual'] ) ) {
              $form->_elements[$form->_elementIndex[$key]]->_attributes['value'] = $form->_submitValues[$key];
            } else {
              $form->_elements[$form->_elementIndex[$key]]->_attributes['value'] = $form->_submitValues[$newKey];
            }
          }
          $form->_elements[$form->_elementIndex[$key]]->_name = $newKey;
          //$form->_rules[$newKey] = $form->_rules[$key];
          
          $fields[$key]['name'] = $newKey;
          $form->_fields[$newKey] = $fields[$key];
          unset( $form->_defaultValues[$key] );
          unset( $form->_defaults[$key] );
          unset( $form->_elementIndex[$key] );
          unset( $form->_fields[$key] );
          unset( $form->_rules[$key] );
        }
      }
      $allCount = $individualCount = 0; $head = null;
      foreach( $form->_fields as $fieldKey => $fieldValue ) {
        $allCount++;
        if( $form->_fields[$fieldKey]['groupTitle'] == 'New Individual' ) {
          if( !isset( $head ) ) {
            $head = $allCount - 1;
          }
          $individualCount++;
          if( strstr( $fieldKey , 'custom' ) ) {
            $newKey = rtrim( $fieldKey, $profArray['New Individual'] );
            $newKey = rtrim( $newKey, '#' );
          } else {
            $newKey = rtrim( $fieldKey, $profArray['New Individual'] );
          }
          $form->_fields[$fieldKey]['groupTitle'] = 'First Child';
          $form->_fields[$fieldKey]['name'] = $newKey;
          $form->_elementIndex[$newKey] = $form->_elementIndex[$fieldKey];
          $individual[$newKey] = $form->_fields[$fieldKey];
          $form->_elements[$form->_elementIndex[$fieldKey]]->_attributes['name'] = $newKey;
          $form->_elements[$form->_elementIndex[$fieldKey]]->_name = $newKey;
          unset($form->_fields[$fieldKey]);
          unset($form->_elementIndex[$fieldKey]);
        } 
      }
      
      if($individual) {
        $pre = array_slice( $form->_fields, 0, $head);
        $tail = array_slice( $form->_fields, $head , $allCount - $individualCount  );
        $form->_fields = array_merge( $pre, $individual, $tail );
      }
          
      if ( !empty( $contacts )) {
        foreach ($form->_fields as $field => $value ) {
          if ( array_key_exists('multiple', $form->_elements[$form->_elementIndex[$field]]->_attributes) ) {
            $form->_elements[$form->_elementIndex[$field]]->_values = $contacts[$field];
            $form->_elements[$form->_elementIndex[$field]]->_attributes['value'] = implode( ',', $contacts[$field] );
          } elseif ( array_key_exists('_elements', (array) $form->_elements[$form->_elementIndex[$field]]) ) {
            foreach ($form->_elements[$form->_elementIndex[$field]]->_elements as $readioKey => $radioVal ) {
              if ($radioVal->_type == 'radio' ) {
                if ( $contacts[$field] == $form->_elements[$form->_elementIndex[$field]]->_elements[$readioKey]->_attributes['value']  ) {
                  $form->_elements[$form->_elementIndex[$field]]->_elements[$readioKey]->_attributes['checked'] = 'checked';
                } else {
                  unset($form->_elements[$form->_elementIndex[$field]]->_elements[$readioKey]->_attributes['checked']);// = '';
                }
              }
              if ($radioVal->_type == 'checkbox' ) {  
                if ( $contacts[$field][$form->_elements[$form->_elementIndex[$field]]->_elements[$readioKey]->_attributes['id']]  == 1 ) {
                  $form->_elements[$form->_elementIndex[$field]]->_elements[$readioKey]->_attributes['checked'] = 'checked';
                } else {
                  unset($form->_elements[$form->_elementIndex[$field]]->_elements[$readioKey]->_attributes['checked']);// = '';
                }
              } 
            }
          } else {
            $form->_elements[$form->_elementIndex[$field]]->_values = array($contacts[$field]);
          }
        }
      }
      
      $form->assign( 'customPost', $form->_fields );
      $profilesPre = CRM_Core_DAO::singleValueQuery(" SELECT uf_group_id FROM civicrm_event_enhanced_profile LEFT JOIN civicrm_uf_group ON civicrm_event_enhanced_profile.uf_group_id = civicrm_uf_group.id WHERE civicrm_event_enhanced_profile.event_id = {$form->_eventId} AND civicrm_event_enhanced_profile.area = 1  AND civicrm_uf_group.is_active =1 ");
      
      $form->buildCustom( $profilesPre , 'customPre' );
      $fields = CRM_Core_BAO_UFGroup::getFields( $profilesPre, false, CRM_Core_Action::ADD,
                                                 null , null, false, null,
                                                 false, null, CRM_Core_Permission::CREATE,
                                                 'field_name', true );
      
      foreach( $fields as $fieldKey => $fieldValues ) {
        $newKey = $fieldKey;
        if( $fields[$fieldKey]['groupTitle'] == 'New Individual' ) {
          $fields[$fieldKey]['groupTitle'] = 'First Child';
        } else {
          if ( strstr( $fieldKey , 'custom' ) ) { 
            $newKey = $fieldKey.'#'.$profArray[$fieldValues['groupTitle']];
          } else {
            $newKey = $fieldKey.$profArray[$fieldValues['groupTitle']];
          }
        }

        $form->_fields[$newKey] = $form->_fields[$fieldKey];
        $form->_elementIndex[$newKey] = $form->_elementIndex[$fieldKey];
        $form->_elements[$form->_elementIndex[$fieldKey]]->_attributes['name'] = $newKey;
        $form->_elements[$form->_elementIndex[$fieldKey]]->_flagFrozen = null;
        if ( !empty( $form->_submitValues ) ) {
          $form->_elements[$form->_elementIndex[$fieldKey]]->_attributes['value'] = $form->_submitValues[$newKey];
        }
        $form->_elements[$form->_elementIndex[$fieldKey]]->_name = $newKey;
        $fields[$fieldKey]['name'] = $newKey;
        
        $firstChild[$newKey] = $fields[$fieldKey];
      }

          
      if ( !empty( $contacts )) {
        foreach ($firstChild as $field => $value ) { 
          if ( array_key_exists('multiple', $form->_elements[$form->_elementIndex[$field]]->_attributes) ) {
            $form->_elements[$form->_elementIndex[$field]]->_values = $contacts[$field];
            $form->_elements[$form->_elementIndex[$field]]->_attributes['value'] = implode( ',', $contacts[$field] );
          } elseif ( array_key_exists('_elements', (array) $form->_elements[$form->_elementIndex[$field]]) ) {
            foreach ($form->_elements[$form->_elementIndex[$field]]->_elements as $readioKey => $radioVal ) {
              if ($radioVal->_type == 'radio' ) {
                if ( $contacts[$field] == $form->_elements[$form->_elementIndex[$field]]->_elements[$readioKey]->_attributes['value']  ) {
                  $form->_elements[$form->_elementIndex[$field]]->_elements[$readioKey]->_attributes['checked'] = 'checked';
                } else {
                  //$form->_elements[$form->_elementIndex[$field]]->_elements[$readioKey]->_attributes['checked'] = '';
                  unset($form->_elements[$form->_elementIndex[$field]]->_elements[$readioKey]->_attributes['checked']);
                }  
              }
            
              if ($radioVal->_type == 'checkbox' ) {  
                if ( $contacts[$field][$form->_elements[$form->_elementIndex[$field]]->_elements[$readioKey]->_attributes['id']]  == 1 ) {
                  $form->_elements[$form->_elementIndex[$field]]->_elements[$readioKey]->_attributes['checked'] = 'checked';
                } else {
                  unset($form->_elements[$form->_elementIndex[$field]]->_elements[$readioKey]->_attributes['checked']);// = '';
                }
              } 
            }
          } else {
            $form->_elements[$form->_elementIndex[$field]]->_values = array($contacts[$field]);
          }
        }
      }
      $form->assign( 'customPre', $firstChild );
    }
  }

  if( $formName == 'CRM_Event_Form_ManageEvent_Registration' ) {
    $profileCount = CRM_Core_DAO::singleValueQuery( " SELECT count(id) FROM  civicrm_uf_group WHERE name IN ('biz_jmaconsulting_eer_your_registration_info', 'biz_jmaconsulting_eer_current_user_profile', 'biz_jmaconsulting_eer_other_parent_or_guardian', 'biz_jmaconsulting_eer_first_emergency_contacts', 'biz_jmaconsulting_eer_second_emergency_contacts') AND is_active = 1" );
    if ( $profileCount != 5 ) {
      $error = 'The Enhanced Event Registration module is misconfigured - please enable all profiles used in the configuration.';
      $form->addElement('hidden', 'email-51');
      $form->setElementError('email-51',$error);
    }
    $form->addElement( 'checkbox', 'is_enhanced', ts( 'Use Enhanced Registration?' ) );
    $eventID = $form->_id;
    $is_enhanced = null;
    $is_enhanced = CRM_Core_DAO::singleValueQuery( "SELECT is_enhanced FROM civicrm_event_enhanced WHERE event_id = $eventID" );
    $defaults['is_enhanced'] = $is_enhanced;
    $form->setDefaults( $defaults );  
  }
}

function eer_civicrm_validate( $formName, &$fields, &$files, &$form ) {
  $errors = array( );
  if ( $formName == 'CRM_Event_Form_ManageEvent_Registration' && isset($fields['is_enhanced'])) {
    $profileCount = CRM_Core_DAO::singleValueQuery( " SELECT count(id) FROM  civicrm_uf_group WHERE name IN ('biz_jmaconsulting_eer_your_registration_info', 'biz_jmaconsulting_eer_current_user_profile', 'biz_jmaconsulting_eer_other_parent_or_guardian', 'biz_jmaconsulting_eer_first_emergency_contacts', 'biz_jmaconsulting_eer_second_emergency_contacts') AND is_active = 1" );
    
    if ( $profileCount != 5 ) {
      $errors['is_enhanced'] = ts( 'The Enhanced Event Registration module is misconfigured - please enable all profiles used in the configuration.' );
    }
  }
  return empty( $errors ) ? true : $errors;
}

function eer_civicrm_post( $op, $objectName, $objectId, &$objectRef ) {
  if ( $objectName == 'Participant' && $op == 'create' ) {
    require_once 'api/api.php';
    $config =& CRM_Core_Config::singleton( );
    $form   = $config->_form;
    $addedProfiles = $config->_addedProfiles;
    $parts  = count($form->_part);
    $config->_participants[] = $objectId;
    $participants = $config->_participants;
    $config->_pContactId[$objectId] = $objectRef->contact_id;
    $pContactIds = $config->_pContactId;
    $pCount      = count($participants);
    $is_shareAdd = $config->_is_shareAdd;
    $is_spouse   = $config->_is_spouse;
    if ( $parts == $pCount ) {
      $is_enhanced = CRM_Core_DAO::singleValueQuery( "SELECT is_enhanced FROM civicrm_event_enhanced WHERE event_id = {$objectRef->event_id}" );
      if ( $is_enhanced ) {
        $profArray = array( 'Current User Profile' => 1, 'Other Parent Or Guardian' => 2, 'First Emergency Contacts' => 3, 'Second Emergency Contacts' => 4);
        
        foreach( $profArray as $profileKey => $profileValues) {
          if(!in_array( $profileKey, $addedProfiles )) {
            unset($profArray[$profileKey]);
          }
        }
		
        $createContactsResult2 = $createContactsResult3 = $createContactsResult4 = null;
        $relationshipTypeDAO = new CRM_Contact_BAO_RelationshipType();
        $relationshipTypeDAO->find();
        while( $relationshipTypeDAO->fetch( ) ) {
          $relationshipTypes[$relationshipTypeDAO->name_a_b] = $relationshipTypeDAO->id;
        }
        $participantIds = $participants;
        foreach( $participantIds as $partKey => $partID ) {
          $contactA = $pContactIds[$partID];
          unset($participantIds[$partKey]);
          foreach( $participantIds as $partKey => $partID ) {
            $contactB = $pContactIds[$partID];
            $siblingParams = array( 
                                   'contact_id_a'         => $contactA,
                                   'contact_id_b'         => $contactB,
                                   'relationship_type_id' => $relationshipTypes['Sibling of'],
                                   'is_active'            => 1,
                                   'version'              => 3,
                                    );
            $siblingResult = civicrm_api( 'relationship', 'create', $siblingParams );
          }
        }
    
        $participantIds = $participants;
        foreach( $participantIds as $key => $pID ) {
          if ( $key == 0 ) {
            $otherParams = array();
            
            foreach( $profArray as $profKey ) {
              $checkDupResult = $addressResult = array();
              if ( !empty($form->_submitValues['first_name'.$profKey]) && !empty($form->_submitValues['last_name'.$profKey]) && !empty($form->_submitValues['email-Primary'.$profKey]) ) {
                $createContactsParams = 'createContactsParams'.$profKey;
                $createContactsResult = 'createContactsResult'.$profKey;
                $contactsCustomParams = $otherParams = array();
                $checkData = array(
                                   'first_name'   => $form->_submitValues['first_name'.$profKey] ,
                                   'last_name'    => $form->_submitValues['last_name'.$profKey],
                                   'contact_type' => 'Individual',
                                   'email'        => $form->_submitValues['email-Primary'.$profKey],
                                   'version'      => 3
                                   );
                $checkDupResult = civicrm_api( 'contact', 'get', $checkData );
                if( !empty($checkDupResult['values'] ) ) {
                  $checkData['id'] = $checkDupResult['id'];
                  $addressParams['contact_id'] = $checkDupResult['id'];
                  $addressParams['version']    = 3;
                  $addressParams['location_type_id'] = 1;
                  $addressResult = civicrm_api( 'address', 'get', $addressParams );
                  if( !empty($addressResult['values'] ) ) {
                    $otherParams[$profKey]['api.address.create']['id'] = $addressResult['id'];
                  }
                }
              }
              $$createContactsParams = $checkData;
            
              foreach( $form->_submitValues as $contactsKeys => $contactsValues ) {
                $search = '#'.$profKey;
                if ( strstr( $contactsKeys, $search) ) {
                  $keyResult = explode('#', $contactsKeys);
                  $newKey = $keyResult[0];
                  $contactsCustomParams[$newKey] = $contactsValues;
                } else {
                  if ( ! strstr($contactsKeys, 'custom') && ! strstr($contactsKeys, 'first_name') && ! strstr($contactsKeys, 'last_name') && ! strstr($contactsKeys, 'email')) {
                    $keyResult = explode('-', $contactsKeys);
                    $newKey = $keyResult[0];
                    if ( $profKey == 1 ) {
                      $otherParams[$profKey]['api.address.create'][$newKey] = $form->_submitValues[$contactsKeys];
                      if ( strstr( $contactsKeys, 'state_province') ) {
                        $otherParams[$profKey]['api.address.create']['state_province_id'] = $form->_submitValues[$contactsKeys];
                      }
                      // $otherParams[$i]['api.address.create']['city']           = $form->_submitValues['city-Primary1'];
                      // $otherParams[$i]['api.address.create']['state_province'] = $form->_submitValues['state_province-Primary1'];
                      // $otherParams[$i]['api.address.create']['postal_code']    = $form->_submitValues['postal_code-Primary1'];
                      $otherParams[$profKey]['api.address.create']['location_type_id'] = 1;
                    } elseif ( strstr( $contactsKeys, (string)$profKey )) {
                      $otherParams[$profKey]['api.address.create'][$newKey] = $contactsValues; 
                      if ( strstr( $contactsKeys, 'state_province') ) {
                        $otherParams[$profKey]['api.address.create']['state_province_id'] = $form->_submitValues[$contactsKeys];
                      }
                      $otherParams[$profKey]['api.address.create']['location_type_id'] = 1;
                    }
                  }
                }
              }
              if ( $profKey == $profArray['Other Parent Or Guardian'] && $is_shareAdd ) {
                $addressGet['contact_id'] =  $createContactsResult1['id'];
                $addressGet['version']    =  3;
                $addressGet['location_type_id'] = 1;
                $result = civicrm_api( 'address','get' , $addressGet );
                $otherParams[$profKey]['api.address.create']['master_id'] = $result['id'];
                $shareOtherParams = $otherParams[$profKey];
                $shareOtherParams['id'] = $pContactIds[$pID];
                $shareOtherParams['version'] = 3;
                $childAddress = civicrm_api( 'contact', 'create', $shareOtherParams );
              }
              $contactData = $$createContactsParams;
              if ( !empty($contactsCustomParams) ) {
                $contactData = array_merge($contactData, $contactsCustomParams );
              }
              if( is_array( $otherParams ) && !empty( $otherParams )) {
                $contactData = array_merge($contactData, $otherParams[$profKey] );
              }
            
              $contactsCustomParams = array();
              $$createContactsResult = civicrm_api( 'contact', 'create', $contactData );
            }
            $child   = $pContactIds[$pID];
            $current = $createContactsResult1['id'];
            $other = $firstEmergency = $secondEmergency = null;
            if(isset($createContactsResult2)) {
              $other   = $createContactsResult2['id'];
            }
            if($createContactsResult3) {
              $firstEmergency  = $createContactsResult3['id'];
            }
            if($createContactsResult4) {
              $secondEmergency = $createContactsResult4['id'];
            }
            if( $is_shareAdd == 1 ) { 
              if ( $form->_submitValues['last_name'.$profArray['Current User Profile']] == $form->_submitValues['last_name2'] ) {
                $houseHoldName = $form->_submitValues['first_name'.$profArray['Current User Profile']].' & '.$form->_submitValues['first_name'.$profArray['Other Parent Or Guardian']].' '.$form->_submitValues['last_name'.$profArray['Current User Profile']].' Household';
              } else {
                $houseHoldName = $form->_submitValues['first_name'.$profArray['Current User Profile']].' '.$form->_submitValues['last_name'.$profArray['Current User Profile']].', '.$form->_submitValues['first_name'.$profArray['Other Parent Or Guardian']].' '.$form->_submitValues['last_name'.$profArray['Other Parent Or Guardian']].' Household';
              }
              
              $createHouseholdParams = array(
                                             'household_name' => $houseHoldName,
                                             'contact_type'   => 'Household',
                                             'email'          => $form->_submitValues['email-Primary'.$profArray['Current User Profile']],
                                             'version'        => 3
                                             );
              $getHouseholdResult = civicrm_api( 'contact', 'get', $createHouseholdParams ); 
              if( !empty($getHouseholdResult['values']) ) {
                $createHouseholdParams['id'] = $getHouseholdResult['id'];
              }
              if( !empty( $shareOtherParams )) {
                unset( $shareOtherParams['id'] );
                $createHouseholdParams= array_merge( $createHouseholdParams, $shareOtherParams );
              }
              $createHouseholdResult = civicrm_api( 'contact', 'create', $createHouseholdParams );  
        
              $household = $createHouseholdResult['id'];
              $householdHeadRelationshipParams = array( 
                                                       'contact_id_a'         => $current,
                                                       'contact_id_b'         => $household,
                                                       'relationship_type_id' => $relationshipTypes['Head of Household for'],
                                                       'is_permission_a_b'    => 1,
                                                       'is_permission_b_a'    => 1,
                                                       'is_active'            => 1,
                                                       'version'              => 3,
                                                        );
          
              $householdCurrentHeadRelationshipResult = civicrm_api( 'relationship', 'create', $householdHeadRelationshipParams );
          
              $householdHeadRelationshipParams['contact_id_a'] = $other;
              $householdHeadRelationshipParams['relationship_type_id'] = $relationshipTypes['Household Member of'];
              $householdOtherHeadRelationshipResult = civicrm_api( 'relationship', 'create', $householdHeadRelationshipParams );
          
              $householdMemberRelationshipParams = array( 
                                                         'contact_id_a'         => $child,
                                                         'contact_id_b'         => $household,
                                                         'relationship_type_id' => $relationshipTypes['Household Member of'],
                                                         'is_permission_b_a'    => 1,
                                                         'is_active'            => 1,
                                                         'version'              => 3,
                                                          );
        
              $householdMemberRelationshipResult = civicrm_api( 'relationship', 'create', $householdMemberRelationshipParams );
            }
      
            if( $is_spouse == 1 ) {
              $spouseRelationshipParams = array( 
                                                'contact_id_a'         => $current,
                                                'contact_id_b'         => $other,
                                                'relationship_type_id' => $relationshipTypes['Spouse of'],
                                                'is_active'            => 1,
                                                'is_permission_a_b'    => 1,
                                                'is_permission_b_a'    => 1,
                                                'version'              => 3,
                                                 );
              $spouseRelationshipResult = civicrm_api( 'relationship', 'create', $spouseRelationshipParams);
            }
       
            $parentRelationshipParams = array( 
                                              'contact_id_a'         => $child,
                                              'contact_id_b'         => $current,
                                              'relationship_type_id' => $relationshipTypes['Child of'],
                                              'is_active'            => 1,
                                              'is_permission_b_a'    => 1,
                                              'version'              => 3,
                                               );
      
            $parentRelationshipResult = civicrm_api( 'relationship', 'create', $parentRelationshipParams );
      
            // create relationship between child and other parent
            if( $other ) {
              $otherParentRelationshipParams = array( 
                                                     'contact_id_a'         => $child,
                                                     'contact_id_b'         => $other,
                                                     'relationship_type_id' => 1,
                                                     'is_active'            => 1,
                                                     'is_permission_b_a'    => 1,
                                                     'version'              => 3,
                                                      );
      
              $otherParentRelationshipResult = civicrm_api( 'relationship', 'create', $otherParentRelationshipParams );
            }
            if( $firstEmergency && $secondEmergency ) {
              // create a new relationship type 'is emergency contact of'
              $emergencyTypeParams = array( 
                                           'name_a_b'       => 'emergency contact is',
                                           'name_b_a'       => 'emergency contact for',
                                           'contact_type_a' => 'Individual',
                                           'contact_type_b' => 'Individual',
                                           'is_reserved'    => 0,
                                           'is_active'      => 1,
                                           'version'        => 3,
                                            );
      
              $getEmergencyTypeResult = civicrm_api( 'relationship_type', 'get', $emergencyTypeParams );
              if( $getEmergencyTypeResult['count'] == 0 ) {
                $createEmergencyTypeResult = civicrm_api( 'relationship_type', 'create', $emergencyTypeParams );
                $relId = $createEmergencyTypeResult['id'];
              }
              else {
                $relId = $getEmergencyTypeResult['id'];
              }
            }
            // create relationship of first emergency contact and child
            if( $firstEmergency ) {
              $emergency1ChildRelationshipParams = array( 
                                                         'contact_id_a'         => $child,
                                                         'contact_id_b'         => $firstEmergency,
                                                         'relationship_type_id' => $relId.'_a_b',
                                                         'is_active'            => 1,
                                                         'contact_check'        => array( $firstEmergency => $firstEmergency ),
                                                          );
              $ids['contact'] = $child;
              CRM_Contact_BAO_Relationship::create(&$emergency1ChildRelationshipParams, &$ids);
            }
            if( $secondEmergency ) {
              // create relationship of second emergency contact and child
              $emergency2ChildRelationshipParams = array( 
                                                         'contact_id_a'         => $child,
                                                         'contact_id_b'         => $secondEmergency,
                                                         'relationship_type_id' => $relId.'_a_b',
                                                         'is_active'            => 1,
                                                         'contact_check'        => array( $secondEmergency => $secondEmergency ),
                                                          );

              CRM_Contact_BAO_Relationship::create(&$emergency2ChildRelationshipParams, &$ids);
            }
          } else {
            $otherChildId = $ids['contact'] = $pContactIds[$pID];
            $parentRelationshipParams['contact_id_a'] = $otherChildId;
            $otherParentRelationshipParams['contact_id_a'] = $otherChildId;
            $emergency1ChildRelationshipParams['contact_id_a'] = $otherChildId;
            $emergency2ChildRelationshipParams['contact_id_a'] = $otherChildId;
            $householdMemberRelationshipParams['contact_id_a'] = $otherChildId;
            $parentRelationshipResult      = civicrm_api( 'relationship', 'create', $parentRelationshipParams );
            if($otherParentRelationshipParams) {
              $otherParentRelationshipResult = civicrm_api( 'relationship', 'create', $otherParentRelationshipParams );
            } 
            if($emergency1ChildRelationshipParams) {
              CRM_Contact_BAO_Relationship::create(&$emergency1ChildRelationshipParams, &$ids);
            }
            if($emergency2ChildRelationshipParams) {
              CRM_Contact_BAO_Relationship::create(&$emergency2ChildRelationshipParams, &$ids);
            }
            if ( $is_shareAdd == 1 ) {
              $householdMemberRelationshipResult = civicrm_api( 'relationship', 'create', $householdMemberRelationshipParams );
              $shareOtherParams['id'] = $otherChildId;
              $childAddress = civicrm_api( 'contact', 'create', $shareOtherParams );
            }
          }
        }
      }
    } 
  }
} 

function eer_civicrm_postProcess( $formName, &$form  ) { 
                
  if( $formName == 'CRM_Event_Form_ManageEvent_Registration' ) {                    
    $eventId = $form->_id;
    $isenhanced = $form->_submitValues['is_enhanced'];
    if( !$isenhanced ) { 
      $isenhanced = 0;
      CRM_Core_DAO::executeQuery( "DELETE FROM civicrm_event_enhanced_profile WHERE event_id = $eventId" );
      CRM_Core_DAO::executeQuery( "DELETE FROM civicrm_event_enhanced WHERE event_id = $eventId" );
    }
    if( $isenhanced ) {
      $isEnhanced = CRM_Core_DAO::singleValueQuery( "SELECT id FROM civicrm_event_enhanced WHERE event_id = $eventId" );
      if (empty($isEnhanced) ) {
        $newIndProfile = CRM_Core_DAO::getFieldValue('CRM_Core_DAO_UFGroup', 'biz_jmaconsulting_eer_your_registration_info', 'id', 'name');
        $curUserProfile = CRM_Core_DAO::getFieldValue('CRM_Core_DAO_UFGroup', 'biz_jmaconsulting_eer_current_user_profile', 'id', 'name');
        $otherPG = CRM_Core_DAO::getFieldValue('CRM_Core_DAO_UFGroup', 'biz_jmaconsulting_eer_other_parent_or_guardian', 'id', 'name');
        $firstEmerContacts = CRM_Core_DAO::getFieldValue('CRM_Core_DAO_UFGroup', 'biz_jmaconsulting_eer_first_emergency_contacts', 'id', 'name');
        $secondEmerContacts = CRM_Core_DAO::getFieldValue('CRM_Core_DAO_UFGroup', 'biz_jmaconsulting_eer_second_emergency_contacts', 'id', 'name');
        CRM_Core_DAO::executeQuery( "INSERT INTO civicrm_event_enhanced( id, event_id, is_enhanced ) values( null,'$eventId','$isenhanced' )" );
        CRM_Core_DAO::executeQuery( "INSERT INTO civicrm_event_enhanced_profile(event_id, uf_group_id, area, weight, label, shares_address ) values({$eventId}, $newIndProfile, 2, 1, null,0)" );
        CRM_Core_DAO::executeQuery( "INSERT INTO civicrm_event_enhanced_profile(event_id, uf_group_id, area, weight, label, shares_address ) values({$eventId}, $curUserProfile, 1, 1, null,0)" );
        CRM_Core_DAO::executeQuery( "INSERT INTO civicrm_event_enhanced_profile(event_id, uf_group_id, area, weight, label, shares_address ) values({$eventId}, $otherPG, 2, 2, null,0)" );
        CRM_Core_DAO::executeQuery( "INSERT INTO civicrm_event_enhanced_profile(event_id, uf_group_id, area, weight, label, shares_address ) values({$eventId}, $firstEmerContacts, 2, 3, null,0)" );
        CRM_Core_DAO::executeQuery( "INSERT INTO civicrm_event_enhanced_profile(event_id, uf_group_id, area, weight, label, shares_address ) values({$eventId}, $secondEmerContacts, 2, 4, null,0)" );
      }
    }
  }
}