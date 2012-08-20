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
 
DROP TABLE IF EXISTS civicrm_event_enhanced;
DROP TABLE IF EXISTS civicrm_event_enhanced_profile;
DROP TABLE IF EXISTS civicrm_event_enhanced_relationship;

CREATE TABLE civicrm_event_enhanced (
id INT NOT NULL AUTO_INCREMENT,
event_id INT NOT NULL ,
is_enhanced tinyint(4) default 0,
PRIMARY KEY(id)
);

CREATE TABLE civicrm_event_enhanced_profile (
  id INT NOT NULL AUTO_INCREMENT,
  event_id INT NOT NULL,
  uf_group_id INT NOT NULL,
  contact_position varchar(255) CHARACTER SET utf8 COLLATE utf8_unicode_ci DEFAULT NULL,
  shares_address tinyint(4) NOT NULL DEFAULT 0,
  PRIMARY KEY (id)
);

CREATE TABLE civicrm_event_enhanced_relationship (
id INT NOT NULL AUTO_INCREMENT,
event_enhanced_profile_id_a INT NOT NULL ,
relationship_type_id INT NOT NULL ,
event_enhanced_profile_id_b INT NOT NULL ,
is_optional tinyint(4) default 0 ,
label varchar(255) NULL ,
is_permission_a_b tinyint(4) default 0 ,
is_permission_b_a tinyint(4) default 0,
PRIMARY KEY(id)
);

INSERT INTO `civicrm_uf_group` ( `is_active`, `group_type`, `title`, `help_pre`, `help_post`, `limit_listings_group_id`, `post_URL`, `add_to_group_id`, `add_captcha`, `is_map`, `is_edit_link`, `is_uf_link`, `is_update_dupe`, `cancel_URL`, `is_cms_user`, `notify`, `is_reserved`, `name`, `created_id`, `created_date`, `is_proximity_search`) VALUES( 1, 'Contact', 'Your Registration Info', NULL, NULL, NULL, NULL, NULL, 0, 0, 0, 0, 0, NULL, 0, NULL, NULL, 'Your_Registration_Info', NULL, NULL, 0);

INSERT INTO `civicrm_uf_field` ( `uf_group_id`, `field_name`, `is_active`, `is_view`, `is_required`, `weight`, `help_post`, `help_pre`, `visibility`, `in_selector`, `is_searchable`, `location_type_id`, `phone_type_id`, `label`, `field_type`, `is_reserved`) VALUES
( (SELECT MAX(id) FROM civicrm_uf_group ), 'email', 1, 0, 1, 1, '', '', 'User and User Admin Only', 0, 0, NULL, NULL, 'Email Address', 'Contact', NULL);

INSERT INTO `civicrm_uf_join` ( `is_active`, `module`, `entity_table`, `entity_id`, `weight`, `uf_group_id`) VALUES
( 1, 'Profile', NULL, NULL, ( Select MAX(id) FROM civicrm_uf_group ) , ( Select MAX(id) FROM civicrm_uf_group ) );

UPDATE  `civicrm_uf_join` SET `weight` = weight+1 ORDER BY id DESC LIMIT 1 ;

INSERT INTO `civicrm_uf_group` ( `is_active`, `group_type`, `title`, `help_pre`, `help_post`, `limit_listings_group_id`, `post_URL`, `add_to_group_id`, `add_captcha`, `is_map`, `is_edit_link`, `is_uf_link`, `is_update_dupe`, `cancel_URL`, `is_cms_user`, `notify`, `is_reserved`, `name`, `created_id`, `created_date`, `is_proximity_search`) VALUES ( 1, 'Individual,Contact', 'Current User Profile', NULL, NULL, NULL, NULL, NULL, 0, 0, 0, 0, 0, NULL, 0, NULL, NULL, 'Current_User_Profile', NULL, NULL, 0);

INSERT INTO `civicrm_uf_field` ( `uf_group_id`, `field_name`, `is_active`, `is_view`, `is_required`, `weight`, `help_post`, `help_pre`, `visibility`, `in_selector`, `is_searchable`, `location_type_id`, `phone_type_id`, `label`, `field_type`, `is_reserved`) VALUES
( (SELECT MAX(id) FROM civicrm_uf_group ), 'first_name', 1, 0, 1, 1, '', '', 'User and User Admin Only', 0, 0, NULL, NULL, 'First Name', 'Individual', NULL),
( (SELECT MAX(id) FROM civicrm_uf_group ), 'last_name', 1, 0, 1, 2, '', '', 'User and User Admin Only', 0, 0, NULL, NULL, 'Last Name', 'Individual', NULL),
( (SELECT MAX(id) FROM civicrm_uf_group ), 'email', 1, 0, 1, 3, '', '', 'User and User Admin Only', 0, 0, NULL, NULL, 'Email (Primary)', 'Contact', NULL),
( (SELECT MAX(id) FROM civicrm_uf_group ), 'street_address', 1, 0, 0, 4, '', '', 'User and User Admin Only', 0, 0, NULL, NULL, 'Street Address (Primary)', 'Contact', NULL),
( (SELECT MAX(id) FROM civicrm_uf_group ), 'city', 1, 0, 0, 5, '', '', 'User and User Admin Only', 0, 0, NULL, NULL, 'City (Primary)', 'Contact', NULL),
( (SELECT MAX(id) FROM civicrm_uf_group ), 'state_province', 1, 0, 0, 6, '', '', 'User and User Admin Only', 0, 0, NULL, NULL, 'State (Primary)', 'Contact', NULL),
( (SELECT MAX(id) FROM civicrm_uf_group ), 'postal_code', 1, 0, 0, 7, '', '', 'User and User Admin Only', 0, 0, NULL, NULL, 'Postal Code (Primary)', 'Contact', NULL);

INSERT INTO `civicrm_uf_join` ( `is_active`, `module`, `entity_table`, `entity_id`, `weight`, `uf_group_id`) VALUES
( 1, 'Profile', NULL, NULL, ( Select MAX(id) FROM civicrm_uf_group ), ( Select MAX(id) FROM civicrm_uf_group ) );

UPDATE  `civicrm_uf_join` SET `weight` = weight+1 ORDER BY id DESC LIMIT 1 ;

INSERT INTO `civicrm_uf_group` ( `is_active`, `group_type`, `title`, `help_pre`, `help_post`, `limit_listings_group_id`, `post_URL`, `add_to_group_id`, `add_captcha`, `is_map`, `is_edit_link`, `is_uf_link`, `is_update_dupe`, `cancel_URL`, `is_cms_user`, `notify`, `is_reserved`, `name`, `created_id`, `created_date`, `is_proximity_search`) VALUES ( 1, 'Individual,Contact', 'Other Parent Or Guardian', NULL, NULL, NULL, NULL, NULL, 0, 0, 0, 0, 0, NULL, 0, NULL, NULL, 'Other_Parent_Or_Guardian', NULL, NULL, 0);

INSERT INTO `civicrm_uf_field` ( `uf_group_id`, `field_name`, `is_active`, `is_view`, `is_required`, `weight`, `help_post`, `help_pre`, `visibility`, `in_selector`, `is_searchable`, `location_type_id`, `phone_type_id`, `label`, `field_type`, `is_reserved`) VALUES
( (SELECT MAX(id) FROM civicrm_uf_group ), 'first_name', 1, 0, 1, 1, '', '', 'User and User Admin Only', 0, 0, NULL, NULL, 'First Name', 'Individual', NULL),
( (SELECT MAX(id) FROM civicrm_uf_group ), 'last_name', 1, 0, 1, 2, '', '', 'User and User Admin Only', 0, 0, NULL, NULL, 'Last Name', 'Individual', NULL),
( (SELECT MAX(id) FROM civicrm_uf_group ), 'email', 1, 0, 1, 3, '', '', 'User and User Admin Only', 0, 0, NULL, NULL, 'Email', 'Contact', NULL),
( (SELECT MAX(id) FROM civicrm_uf_group ), 'street_address', 1, 0, 0, 4, '', '', 'User and User Admin Only', 0, 0, NULL, NULL, 'Street Address (Primary)', 'Contact', NULL),
( (SELECT MAX(id) FROM civicrm_uf_group ), 'city', 1, 0, 0, 5, '', '', 'User and User Admin Only', 0, 0, NULL, NULL, 'City (Primary)', 'Contact', NULL),
( (SELECT MAX(id) FROM civicrm_uf_group ), 'state_province', 1, 0, 0, 6, '', '', 'User and User Admin Only', 0, 0, NULL, NULL, 'State (Primary)', 'Contact', NULL),
( (SELECT MAX(id) FROM civicrm_uf_group ), 'postal_code', 1, 0, 0, 7, '', '', 'User and User Admin Only', 0, 0, NULL, NULL, 'Postal Code (Primary)', 'Contact', NULL);

INSERT INTO `civicrm_uf_join` ( `is_active`, `module`, `entity_table`, `entity_id`, `weight`, `uf_group_id`) VALUES
( 1, 'Profile', NULL, NULL,( Select MAX(id) FROM civicrm_uf_group ), ( Select MAX(id) FROM civicrm_uf_group ) );

UPDATE  `civicrm_uf_join` SET `weight` = weight+1 ORDER BY id DESC LIMIT 1 ;

INSERT INTO `civicrm_uf_group` ( `is_active`, `group_type`, `title`, `help_pre`, `help_post`, `limit_listings_group_id`, `post_URL`, `add_to_group_id`, `add_captcha`, `is_map`, `is_edit_link`, `is_uf_link`, `is_update_dupe`, `cancel_URL`, `is_cms_user`, `notify`, `is_reserved`, `name`, `created_id`, `created_date`, `is_proximity_search`) VALUES ( 1, 'Individual,Contact', 'First Emergency Contacts', NULL, NULL, NULL, NULL, NULL, 0, 0, 0, 0, 0, NULL, 0, NULL, NULL, 'First_Emergency_Contacts', NULL, NULL, 0);

INSERT INTO `civicrm_uf_field` ( `uf_group_id`, `field_name`, `is_active`, `is_view`, `is_required`, `weight`, `help_post`, `help_pre`, `visibility`, `in_selector`, `is_searchable`, `location_type_id`, `phone_type_id`, `label`, `field_type`, `is_reserved`) VALUES
( (SELECT MAX(id) FROM civicrm_uf_group ), 'first_name', 1, 0, 1, 1, '', '', 'User and User Admin Only', 0, 0, NULL, NULL, 'First Name', 'Individual', NULL),
( (SELECT MAX(id) FROM civicrm_uf_group ), 'last_name', 1, 0, 1, 2, '', '', 'User and User Admin Only', 0, 0, NULL, NULL, 'Last Name', 'Individual', NULL),
( (SELECT MAX(id) FROM civicrm_uf_group ), 'email', 1, 0, 1, 3, '', '', 'User and User Admin Only', 0, 0, NULL, NULL, 'Email', 'Contact', NULL),
( (SELECT MAX(id) FROM civicrm_uf_group ), 'street_address', 1, 0, 0, 4, '', '', 'User and User Admin Only', 0, 0, NULL, NULL, 'Street Address (Primary)', 'Contact', NULL),
( (SELECT MAX(id) FROM civicrm_uf_group ), 'city', 1, 0, 0, 5, '', '', 'User and User Admin Only', 0, 0, NULL, NULL, 'City (Primary)', 'Contact', NULL),
( (SELECT MAX(id) FROM civicrm_uf_group ), 'state_province', 1, 0, 0, 6, '', '', 'User and User Admin Only', 0, 0, NULL, NULL, 'State (Primary)', 'Contact', NULL),
( (SELECT MAX(id) FROM civicrm_uf_group ), 'postal_code', 1, 0, 0, 7, '', '', 'User and User Admin Only', 0, 0, NULL, NULL, 'Postal Code (Primary)', 'Contact', NULL);

INSERT INTO `civicrm_uf_join` ( `is_active`, `module`, `entity_table`, `entity_id`, `weight`, `uf_group_id`) VALUES
( 1, 'Profile', NULL, NULL, ( Select MAX(id) FROM civicrm_uf_group ), ( Select MAX(id) FROM civicrm_uf_group ) );

UPDATE  `civicrm_uf_join` SET `weight` = weight+1 ORDER BY id DESC LIMIT 1 ;

INSERT INTO `civicrm_uf_group` ( `is_active`, `group_type`, `title`, `help_pre`, `help_post`, `limit_listings_group_id`, `post_URL`, `add_to_group_id`, `add_captcha`, `is_map`, `is_edit_link`, `is_uf_link`, `is_update_dupe`, `cancel_URL`, `is_cms_user`, `notify`, `is_reserved`, `name`, `created_id`, `created_date`, `is_proximity_search`) VALUES ( 1, 'Individual,Contact', 'Second Emergency Contacts', NULL, NULL, NULL, NULL, NULL, 0, 0, 0, 0, 0, NULL, 0, NULL, NULL, 'Second_Emergency_Contacts', NULL, NULL, 0);

INSERT INTO `civicrm_uf_field` ( `uf_group_id`, `field_name`, `is_active`, `is_view`, `is_required`, `weight`, `help_post`, `help_pre`, `visibility`, `in_selector`, `is_searchable`, `location_type_id`, `phone_type_id`, `label`, `field_type`, `is_reserved`) VALUES
( (SELECT MAX(id) FROM civicrm_uf_group ), 'first_name', 1, 0, 1, 1, '', '', 'User and User Admin Only', 0, 0, NULL, NULL, 'First Name', 'Individual', NULL),
( (SELECT MAX(id) FROM civicrm_uf_group ), 'last_name', 1, 0, 1, 2, '', '', 'User and User Admin Only', 0, 0, NULL, NULL, 'Last Name', 'Individual', NULL),
( (SELECT MAX(id) FROM civicrm_uf_group ), 'email', 1, 0, 1, 3, '', '', 'User and User Admin Only', 0, 0, NULL, NULL, 'Email', 'Contact', NULL),
( (SELECT MAX(id) FROM civicrm_uf_group ), 'street_address', 1, 0, 0, 4, '', '', 'User and User Admin Only', 0, 0, NULL, NULL, 'Street Address (Primary)', 'Contact', NULL),
( (SELECT MAX(id) FROM civicrm_uf_group ), 'city', 1, 0, 0, 5, '', '', 'User and User Admin Only', 0, 0, NULL, NULL, 'City (Primary)', 'Contact', NULL),
( (SELECT MAX(id) FROM civicrm_uf_group ), 'state_province', 1, 0, 0, 6, '', '', 'User and User Admin Only', 0, 0, NULL, NULL, 'State (Primary)', 'Contact', NULL),
( (SELECT MAX(id) FROM civicrm_uf_group ), 'postal_code', 1, 0, 0, 7, '', '', 'User and User Admin Only', 0, 0, NULL, NULL, 'Postal Code (Primary)', 'Contact', NULL);

INSERT INTO `civicrm_uf_join` ( `is_active`, `module`, `entity_table`, `entity_id`, `weight`, `uf_group_id`) VALUES
( 1, 'Profile', NULL, NULL, ( Select MAX(id) FROM civicrm_uf_group ), ( Select MAX(id) FROM civicrm_uf_group ) );

UPDATE  `civicrm_uf_join` SET `weight` = weight+1 ORDER BY id DESC LIMIT 1 ;