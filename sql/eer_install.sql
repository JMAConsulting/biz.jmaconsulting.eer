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

CREATE TABLE IF NOT EXISTS civicrm_event_enhanced_profile (
  id int(11) NOT NULL AUTO_INCREMENT,
  event_id int(11) NOT NULL,
  uf_group_id int(11) NOT NULL,
  area int(10) DEFAULT NULL COMMENT 'NULL means hidden, 1 means top, 2 means bottom',
  weight int(10) DEFAULT NULL COMMENT 'within an area, weight determines position',
  label varchar(255) CHARACTER SET utf8 COLLATE utf8_unicode_ci DEFAULT NULL COMMENT 'Override of the Profile''s title',
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
/*User Registartion Profile */

SELECT @ufGId := id FROM civicrm_uf_group WHERE name = 'biz_jmaconsulting_eer_your_registration_info';

INSERT INTO `civicrm_uf_group` ( `id`, `is_active`, `group_type`, `title`, `help_pre`, `help_post`, `limit_listings_group_id`, `post_URL`, `add_to_group_id`, `add_captcha`, `is_map`, `is_edit_link`, `is_uf_link`, `is_update_dupe`, `cancel_URL`, `is_cms_user`, `notify`, `is_reserved`, `name`, `created_id`, `created_date`, `is_proximity_search`) VALUES( @ufGId, 1, 'Contact', 'Your Registration Info', NULL, NULL, NULL, NULL, NULL, 0, 0, 0, 0, 0, NULL, 0, NULL, NULL, 'biz_jmaconsulting_eer_your_registration_info', NULL, NULL, 0) ON DUPLICATE KEY UPDATE id = @ufGId;

SET @ufGId := '';

SELECT @ufGId := id FROM civicrm_uf_group WHERE name = 'biz_jmaconsulting_eer_your_registration_info';

SET @ufFId := '';

SELECT @ufFId := id FROM civicrm_uf_field WHERE field_name = 'email' AND uf_group_id = @ufGId;

INSERT INTO `civicrm_uf_field` ( `id`, `uf_group_id`, `field_name`, `is_active`, `is_view`, `is_required`, `weight`, `help_post`, `help_pre`, `visibility`, `in_selector`, `is_searchable`, `location_type_id`, `phone_type_id`, `label`, `field_type`, `is_reserved`) VALUES
( @ufFId, @ufGId, 'email', 1, 0, 1, 1, '', '', 'User and User Admin Only', 0, 0, NULL, NULL, 'Email Address', 'Contact', NULL) ON DUPLICATE KEY UPDATE id = @ufFId;

SET @ufFId := '';

SELECT @ufFId := id FROM civicrm_uf_field WHERE field_name = 'email' AND uf_group_id = @ufGId;

SET @ufJId := '';

SELECT @ufGId := id FROM civicrm_uf_group WHERE name = 'biz_jmaconsulting_eer_your_registration_info';

SELECT @ufJId := id FROM civicrm_uf_join WHERE module = 'Profile' AND uf_group_id = @ufGId;
  
INSERT INTO `civicrm_uf_join` ( `id`, `is_active`, `module`, `entity_table`, `entity_id`, `weight`, `uf_group_id`) VALUES
( @ufJId, 1, 'Profile', NULL, NULL, @ufGId , @ufGId ) ON DUPLICATE KEY UPDATE id = @ufJId;


SET @ufGId := '';

SELECT @ufGId := id FROM civicrm_uf_group WHERE name = 'biz_jmaconsulting_eer_current_user_profile';

INSERT INTO `civicrm_uf_group` ( `id`, `is_active`, `group_type`, `title`, `help_pre`, `help_post`, `limit_listings_group_id`, `post_URL`, `add_to_group_id`, `add_captcha`, `is_map`, `is_edit_link`, `is_uf_link`, `is_update_dupe`, `cancel_URL`, `is_cms_user`, `notify`, `is_reserved`, `name`, `created_id`, `created_date`, `is_proximity_search`) VALUES ( @ufGId, 1, 'Individual,Contact', 'Current User Profile', NULL, NULL, NULL, NULL, NULL, 0, 0, 0, 0, 0, NULL, 0, NULL, NULL, 'biz_jmaconsulting_eer_current_user_profile', NULL, NULL, 0) ON DUPLICATE KEY UPDATE id = @ufGId;

SELECT @ufGId := id FROM civicrm_uf_group WHERE name = 'biz_jmaconsulting_eer_current_user_profile';

SET @ufFFNId := '';
SET @ufFLNId := '';
SET @ufFEId := '';
SET @ufFSAId := '';
SET @ufFCId := '';
SET @ufFSPId := '';
SET @ufFPCId := '';

SELECT @ufFFNId := id FROM civicrm_uf_field WHERE field_name = 'first_name' AND uf_group_id = @ufGId;
SELECT @ufFLNId := id FROM civicrm_uf_field WHERE field_name = 'last_name' AND uf_group_id = @ufGId;
SELECT @ufFEId := id FROM civicrm_uf_field WHERE field_name = 'email' AND uf_group_id = @ufGId;
SELECT @ufFSAId := id FROM civicrm_uf_field WHERE field_name = 'street_address' AND uf_group_id = @ufGId;
SELECT @ufFCId := id FROM civicrm_uf_field WHERE field_name = 'city' AND uf_group_id = @ufGId;
SELECT @ufFSPId := id FROM civicrm_uf_field WHERE field_name = 'state_province' AND uf_group_id = @ufGId;
SELECT @ufFPCId := id FROM civicrm_uf_field WHERE field_name = 'postal_code' AND uf_group_id = @ufGId;

INSERT INTO `civicrm_uf_field` ( `id`, `uf_group_id`, `field_name`, `is_active`, `is_view`, `is_required`, `weight`, `help_post`, `help_pre`, `visibility`, `in_selector`, `is_searchable`, `location_type_id`, `phone_type_id`, `label`, `field_type`, `is_reserved`) VALUES ( @ufFFNId, @ufGId, 'first_name', 1, 0, 1, 1, '', '', 'User and User Admin Only', 0, 0, NULL, NULL, 'First Name', 'Individual', NULL) ON DUPLICATE KEY UPDATE id = @ufFFNId;

INSERT INTO `civicrm_uf_field` ( `id`, `uf_group_id`, `field_name`, `is_active`, `is_view`, `is_required`, `weight`, `help_post`, `help_pre`, `visibility`, `in_selector`, `is_searchable`, `location_type_id`, `phone_type_id`, `label`, `field_type`, `is_reserved`) VALUES ( @ufFLNId, @ufGId, 'last_name', 1, 0, 1, 2, '', '', 'User and User Admin Only', 0, 0, NULL, NULL, 'Last Name', 'Individual', NULL) ON DUPLICATE KEY UPDATE id = @ufFLNId;

INSERT INTO `civicrm_uf_field` ( `id`, `uf_group_id`, `field_name`, `is_active`, `is_view`, `is_required`, `weight`, `help_post`, `help_pre`, `visibility`, `in_selector`, `is_searchable`, `location_type_id`, `phone_type_id`, `label`, `field_type`, `is_reserved`) VALUES ( @ufFEId, @ufGId, 'email', 1, 0, 1, 3, '', '', 'User and User Admin Only', 0, 0, NULL, NULL, 'Email (Primary)', 'Contact', NULL) ON DUPLICATE KEY UPDATE id = @ufFEId;

INSERT INTO `civicrm_uf_field` ( `id`, `uf_group_id`, `field_name`, `is_active`, `is_view`, `is_required`, `weight`, `help_post`, `help_pre`, `visibility`, `in_selector`, `is_searchable`, `location_type_id`, `phone_type_id`, `label`, `field_type`, `is_reserved`) VALUES ( @ufFSAId, @ufGId, 'street_address', 1, 0, 0, 4, '', '', 'User and User Admin Only', 0, 0, NULL, NULL, 'Street Address (Primary)', 'Contact', NULL) ON DUPLICATE KEY UPDATE id = @ufFSAId;

INSERT INTO `civicrm_uf_field` ( `id`, `uf_group_id`, `field_name`, `is_active`, `is_view`, `is_required`, `weight`, `help_post`, `help_pre`, `visibility`, `in_selector`, `is_searchable`, `location_type_id`, `phone_type_id`, `label`, `field_type`, `is_reserved`) VALUES ( @ufFCId, @ufGId, 'city', 1, 0, 0, 5, '', '', 'User and User Admin Only', 0, 0, NULL, NULL, 'City (Primary)', 'Contact', NULL) ON DUPLICATE KEY UPDATE id = @ufFCId;

INSERT INTO `civicrm_uf_field` ( `id`, `uf_group_id`, `field_name`, `is_active`, `is_view`, `is_required`, `weight`, `help_post`, `help_pre`, `visibility`, `in_selector`, `is_searchable`, `location_type_id`, `phone_type_id`, `label`, `field_type`, `is_reserved`) VALUES ( @ufFSPId, @ufGId, 'state_province', 1, 0, 0, 6, '', '', 'User and User Admin Only', 0, 0, NULL, NULL, 'State (Primary)', 'Contact', NULL) ON DUPLICATE KEY UPDATE id = @ufFSPId;

INSERT INTO `civicrm_uf_field` ( `id`, `uf_group_id`, `field_name`, `is_active`, `is_view`, `is_required`, `weight`, `help_post`, `help_pre`, `visibility`, `in_selector`, `is_searchable`, `location_type_id`, `phone_type_id`, `label`, `field_type`, `is_reserved`) VALUES ( @ufFPCId, @ufGId, 'postal_code', 1, 0, 0, 7, '', '', 'User and User Admin Only', 0, 0, NULL, NULL, 'Postal Code (Primary)', 'Contact', NULL) ON DUPLICATE KEY UPDATE id = @ufFPCId;

SET @ufJId := '';

SELECT @ufJId := id FROM civicrm_uf_join WHERE module = 'Profile' AND uf_group_id = @ufGId;
  
INSERT INTO `civicrm_uf_join` ( `id`, `is_active`, `module`, `entity_table`, `entity_id`, `weight`, `uf_group_id`) VALUES
( @ufJId, 1, 'Profile', NULL, NULL, @ufGId , @ufGId ) ON DUPLICATE KEY UPDATE id = @ufJId;


SET @ufGId := '';

SELECT @ufGId := id FROM civicrm_uf_group WHERE name = 'biz_jmaconsulting_eer_other_parent_or_guardian';

INSERT INTO `civicrm_uf_group` ( `id`,`is_active`, `group_type`, `title`, `help_pre`, `help_post`, `limit_listings_group_id`, `post_URL`, `add_to_group_id`, `add_captcha`, `is_map`, `is_edit_link`, `is_uf_link`, `is_update_dupe`, `cancel_URL`, `is_cms_user`, `notify`, `is_reserved`, `name`, `created_id`, `created_date`, `is_proximity_search`) VALUES ( @ufGId, 1, 'Individual,Contact', 'Other Parent Or Guardian', NULL, NULL, NULL, NULL, NULL, 0, 0, 0, 0, 0, NULL, 0, NULL, NULL, 'biz_jmaconsulting_eer_other_parent_or_guardian', NULL, NULL, 0) ON DUPLICATE KEY UPDATE id = @ufGId;

SET @ufGId := '';

SELECT @ufGId := id FROM civicrm_uf_group WHERE name = 'biz_jmaconsulting_eer_other_parent_or_guardian';

SET @ufFFNId := '';
SET @ufFLNId := '';
SET @ufFEId := '';
SET @ufFSAId := '';
SET @ufFCId := '';
SET @ufFSPId := '';
SET @ufFPCId := '';

SELECT @ufFFNId := id FROM civicrm_uf_field WHERE field_name = 'first_name' AND uf_group_id = @ufGId;
SELECT @ufFLNId := id FROM civicrm_uf_field WHERE field_name = 'last_name' AND uf_group_id = @ufGId;
SELECT @ufFEId := id FROM civicrm_uf_field WHERE field_name = 'email' AND uf_group_id = @ufGId;
SELECT @ufFSAId := id FROM civicrm_uf_field WHERE field_name = 'street_address' AND uf_group_id = @ufGId;
SELECT @ufFCId := id FROM civicrm_uf_field WHERE field_name = 'city' AND uf_group_id = @ufGId;
SELECT @ufFSPId := id FROM civicrm_uf_field WHERE field_name = 'state_province' AND uf_group_id = @ufGId;
SELECT @ufFPCId := id FROM civicrm_uf_field WHERE field_name = 'postal_code' AND uf_group_id = @ufGId;

INSERT INTO `civicrm_uf_field` ( `id`, `uf_group_id`, `field_name`, `is_active`, `is_view`, `is_required`, `weight`, `help_post`, `help_pre`, `visibility`, `in_selector`, `is_searchable`, `location_type_id`, `phone_type_id`, `label`, `field_type`, `is_reserved`) VALUES ( @ufFFNId, @ufGId, 'first_name', 1, 0, 1, 1, '', '', 'User and User Admin Only', 0, 0, NULL, NULL, 'First Name', 'Individual', NULL) ON DUPLICATE KEY UPDATE id = @ufFFNId;

INSERT INTO `civicrm_uf_field` ( `id`, `uf_group_id`, `field_name`, `is_active`, `is_view`, `is_required`, `weight`, `help_post`, `help_pre`, `visibility`, `in_selector`, `is_searchable`, `location_type_id`, `phone_type_id`, `label`, `field_type`, `is_reserved`) VALUES ( @ufFLNId, @ufGId, 'last_name', 1, 0, 1, 2, '', '', 'User and User Admin Only', 0, 0, NULL, NULL, 'Last Name', 'Individual', NULL) ON DUPLICATE KEY UPDATE id = @ufFLNId;

INSERT INTO `civicrm_uf_field` ( `id`, `uf_group_id`, `field_name`, `is_active`, `is_view`, `is_required`, `weight`, `help_post`, `help_pre`, `visibility`, `in_selector`, `is_searchable`, `location_type_id`, `phone_type_id`, `label`, `field_type`, `is_reserved`) VALUES ( @ufFEId, @ufGId, 'email', 1, 0, 1, 3, '', '', 'User and User Admin Only', 0, 0, NULL, NULL, 'Email (Primary)', 'Contact', NULL) ON DUPLICATE KEY UPDATE id = @ufFEId;

INSERT INTO `civicrm_uf_field` ( `id`, `uf_group_id`, `field_name`, `is_active`, `is_view`, `is_required`, `weight`, `help_post`, `help_pre`, `visibility`, `in_selector`, `is_searchable`, `location_type_id`, `phone_type_id`, `label`, `field_type`, `is_reserved`) VALUES ( @ufFSAId, @ufGId, 'street_address', 1, 0, 0, 4, '', '', 'User and User Admin Only', 0, 0, NULL, NULL, 'Street Address (Primary)', 'Contact', NULL) ON DUPLICATE KEY UPDATE id = @ufFSAId;

INSERT INTO `civicrm_uf_field` ( `id`, `uf_group_id`, `field_name`, `is_active`, `is_view`, `is_required`, `weight`, `help_post`, `help_pre`, `visibility`, `in_selector`, `is_searchable`, `location_type_id`, `phone_type_id`, `label`, `field_type`, `is_reserved`) VALUES ( @ufFCId, @ufGId, 'city', 1, 0, 0, 5, '', '', 'User and User Admin Only', 0, 0, NULL, NULL, 'City (Primary)', 'Contact', NULL) ON DUPLICATE KEY UPDATE id = @ufFCId;

INSERT INTO `civicrm_uf_field` ( `id`, `uf_group_id`, `field_name`, `is_active`, `is_view`, `is_required`, `weight`, `help_post`, `help_pre`, `visibility`, `in_selector`, `is_searchable`, `location_type_id`, `phone_type_id`, `label`, `field_type`, `is_reserved`) VALUES ( @ufFSPId, @ufGId, 'state_province', 1, 0, 0, 6, '', '', 'User and User Admin Only', 0, 0, NULL, NULL, 'State (Primary)', 'Contact', NULL) ON DUPLICATE KEY UPDATE id = @ufFSPId;

INSERT INTO `civicrm_uf_field` ( `id`, `uf_group_id`, `field_name`, `is_active`, `is_view`, `is_required`, `weight`, `help_post`, `help_pre`, `visibility`, `in_selector`, `is_searchable`, `location_type_id`, `phone_type_id`, `label`, `field_type`, `is_reserved`) VALUES ( @ufFPCId, @ufGId, 'postal_code', 1, 0, 0, 7, '', '', 'User and User Admin Only', 0, 0, NULL, NULL, 'Postal Code (Primary)', 'Contact', NULL) ON DUPLICATE KEY UPDATE id = @ufFPCId;

SET @ufJId := '';

SELECT @ufJId := id FROM civicrm_uf_join WHERE module = 'Profile' AND uf_group_id = @ufGId;
  
INSERT INTO `civicrm_uf_join` ( `id`, `is_active`, `module`, `entity_table`, `entity_id`, `weight`, `uf_group_id`) VALUES
( @ufJId, 1, 'Profile', NULL, NULL, @ufGId , @ufGId ) ON DUPLICATE KEY UPDATE id = @ufJId;


SET @ufGId := '';

SELECT @ufGId := id FROM civicrm_uf_group WHERE name = 'biz_jmaconsulting_eer_first_emergency_contacts';

INSERT INTO `civicrm_uf_group` ( `id`, `is_active`, `group_type`, `title`, `help_pre`, `help_post`, `limit_listings_group_id`, `post_URL`, `add_to_group_id`, `add_captcha`, `is_map`, `is_edit_link`, `is_uf_link`, `is_update_dupe`, `cancel_URL`, `is_cms_user`, `notify`, `is_reserved`, `name`, `created_id`, `created_date`, `is_proximity_search`) VALUES ( @ufGId, 1, 'Individual,Contact', 'First Emergency Contacts', NULL, NULL, NULL, NULL, NULL, 0, 0, 0, 0, 0, NULL, 0, NULL, NULL, 'biz_jmaconsulting_eer_first_emergency_contacts', NULL, NULL, 0) ON DUPLICATE KEY UPDATE id = @ufGId;

SET @ufGId := '';

SELECT @ufGId := id FROM civicrm_uf_group WHERE name = 'biz_jmaconsulting_eer_first_emergency_contacts';

SET @ufFFNId := '';
SET @ufFLNId := '';
SET @ufFEId := '';
SET @ufFSAId := '';
SET @ufFCId := '';
SET @ufFSPId := '';
SET @ufFPCId := '';

SELECT @ufFFNId := id FROM civicrm_uf_field WHERE field_name = 'first_name' AND uf_group_id = @ufGId;
SELECT @ufFLNId := id FROM civicrm_uf_field WHERE field_name = 'last_name' AND uf_group_id = @ufGId;
SELECT @ufFEId := id FROM civicrm_uf_field WHERE field_name = 'email' AND uf_group_id = @ufGId;
SELECT @ufFSAId := id FROM civicrm_uf_field WHERE field_name = 'street_address' AND uf_group_id = @ufGId;
SELECT @ufFCId := id FROM civicrm_uf_field WHERE field_name = 'city' AND uf_group_id = @ufGId;
SELECT @ufFSPId := id FROM civicrm_uf_field WHERE field_name = 'state_province' AND uf_group_id = @ufGId;
SELECT @ufFPCId := id FROM civicrm_uf_field WHERE field_name = 'postal_code' AND uf_group_id = @ufGId;

INSERT INTO `civicrm_uf_field` ( `id`, `uf_group_id`, `field_name`, `is_active`, `is_view`, `is_required`, `weight`, `help_post`, `help_pre`, `visibility`, `in_selector`, `is_searchable`, `location_type_id`, `phone_type_id`, `label`, `field_type`, `is_reserved`) VALUES ( @ufFFNId, @ufGId, 'first_name', 1, 0, 1, 1, '', '', 'User and User Admin Only', 0, 0, NULL, NULL, 'First Name', 'Individual', NULL) ON DUPLICATE KEY UPDATE id = @ufFFNId;

INSERT INTO `civicrm_uf_field` ( `id`, `uf_group_id`, `field_name`, `is_active`, `is_view`, `is_required`, `weight`, `help_post`, `help_pre`, `visibility`, `in_selector`, `is_searchable`, `location_type_id`, `phone_type_id`, `label`, `field_type`, `is_reserved`) VALUES ( @ufFLNId, @ufGId, 'last_name', 1, 0, 1, 2, '', '', 'User and User Admin Only', 0, 0, NULL, NULL, 'Last Name', 'Individual', NULL) ON DUPLICATE KEY UPDATE id = @ufFLNId;

INSERT INTO `civicrm_uf_field` ( `id`, `uf_group_id`, `field_name`, `is_active`, `is_view`, `is_required`, `weight`, `help_post`, `help_pre`, `visibility`, `in_selector`, `is_searchable`, `location_type_id`, `phone_type_id`, `label`, `field_type`, `is_reserved`) VALUES ( @ufFEId, @ufGId, 'email', 1, 0, 1, 3, '', '', 'User and User Admin Only', 0, 0, NULL, NULL, 'Email (Primary)', 'Contact', NULL) ON DUPLICATE KEY UPDATE id = @ufFEId;

INSERT INTO `civicrm_uf_field` ( `id`, `uf_group_id`, `field_name`, `is_active`, `is_view`, `is_required`, `weight`, `help_post`, `help_pre`, `visibility`, `in_selector`, `is_searchable`, `location_type_id`, `phone_type_id`, `label`, `field_type`, `is_reserved`) VALUES ( @ufFSAId, @ufGId, 'street_address', 1, 0, 0, 4, '', '', 'User and User Admin Only', 0, 0, NULL, NULL, 'Street Address (Primary)', 'Contact', NULL) ON DUPLICATE KEY UPDATE id = @ufFSAId;

INSERT INTO `civicrm_uf_field` ( `id`, `uf_group_id`, `field_name`, `is_active`, `is_view`, `is_required`, `weight`, `help_post`, `help_pre`, `visibility`, `in_selector`, `is_searchable`, `location_type_id`, `phone_type_id`, `label`, `field_type`, `is_reserved`) VALUES ( @ufFCId, @ufGId, 'city', 1, 0, 0, 5, '', '', 'User and User Admin Only', 0, 0, NULL, NULL, 'City (Primary)', 'Contact', NULL) ON DUPLICATE KEY UPDATE id = @ufFCId;

INSERT INTO `civicrm_uf_field` ( `id`, `uf_group_id`, `field_name`, `is_active`, `is_view`, `is_required`, `weight`, `help_post`, `help_pre`, `visibility`, `in_selector`, `is_searchable`, `location_type_id`, `phone_type_id`, `label`, `field_type`, `is_reserved`) VALUES ( @ufFSPId, @ufGId, 'state_province', 1, 0, 0, 6, '', '', 'User and User Admin Only', 0, 0, NULL, NULL, 'State (Primary)', 'Contact', NULL) ON DUPLICATE KEY UPDATE id = @ufFSPId;

INSERT INTO `civicrm_uf_field` ( `id`, `uf_group_id`, `field_name`, `is_active`, `is_view`, `is_required`, `weight`, `help_post`, `help_pre`, `visibility`, `in_selector`, `is_searchable`, `location_type_id`, `phone_type_id`, `label`, `field_type`, `is_reserved`) VALUES ( @ufFPCId, @ufGId, 'postal_code', 1, 0, 0, 7, '', '', 'User and User Admin Only', 0, 0, NULL, NULL, 'Postal Code (Primary)', 'Contact', NULL) ON DUPLICATE KEY UPDATE id = @ufFPCId;

SET @ufJId := '';

SELECT @ufJId := id FROM civicrm_uf_join WHERE module = 'Profile' AND uf_group_id = @ufGId;
  
INSERT INTO `civicrm_uf_join` ( `id`, `is_active`, `module`, `entity_table`, `entity_id`, `weight`, `uf_group_id`) VALUES
( @ufJId, 1, 'Profile', NULL, NULL, @ufGId , @ufGId ) ON DUPLICATE KEY UPDATE id = @ufJId;


SET @ufGId := '';

SELECT @ufGId := id FROM civicrm_uf_group WHERE name = 'biz_jmaconsulting_eer_second_emergency_contacts';

INSERT INTO `civicrm_uf_group` ( `id`, `is_active`, `group_type`, `title`, `help_pre`, `help_post`, `limit_listings_group_id`, `post_URL`, `add_to_group_id`, `add_captcha`, `is_map`, `is_edit_link`, `is_uf_link`, `is_update_dupe`, `cancel_URL`, `is_cms_user`, `notify`, `is_reserved`, `name`, `created_id`, `created_date`, `is_proximity_search`) VALUES ( @ufGId, 1, 'Individual,Contact', 'Second Emergency Contacts', NULL, NULL, NULL, NULL, NULL, 0, 0, 0, 0, 0, NULL, 0, NULL, NULL, 'biz_jmaconsulting_eer_second_emergency_contacts', NULL, NULL, 0) ON DUPLICATE KEY UPDATE id = @ufGId;

SET @ufGId := '';

SELECT @ufGId := id FROM civicrm_uf_group WHERE name = 'biz_jmaconsulting_eer_second_emergency_contacts';

SET @ufFFNId := '';
SET @ufFLNId := '';
SET @ufFEId := '';
SET @ufFSAId := '';
SET @ufFCId := '';
SET @ufFSPId := '';
SET @ufFPCId := '';

SELECT @ufFFNId := id FROM civicrm_uf_field WHERE field_name = 'first_name' AND uf_group_id = @ufGId;
SELECT @ufFLNId := id FROM civicrm_uf_field WHERE field_name = 'last_name' AND uf_group_id = @ufGId;
SELECT @ufFEId := id FROM civicrm_uf_field WHERE field_name = 'email' AND uf_group_id = @ufGId;
SELECT @ufFSAId := id FROM civicrm_uf_field WHERE field_name = 'street_address' AND uf_group_id = @ufGId;
SELECT @ufFCId := id FROM civicrm_uf_field WHERE field_name = 'city' AND uf_group_id = @ufGId;
SELECT @ufFSPId := id FROM civicrm_uf_field WHERE field_name = 'state_province' AND uf_group_id = @ufGId;
SELECT @ufFPCId := id FROM civicrm_uf_field WHERE field_name = 'postal_code' AND uf_group_id = @ufGId;

INSERT INTO `civicrm_uf_field` ( `id`, `uf_group_id`, `field_name`, `is_active`, `is_view`, `is_required`, `weight`, `help_post`, `help_pre`, `visibility`, `in_selector`, `is_searchable`, `location_type_id`, `phone_type_id`, `label`, `field_type`, `is_reserved`) VALUES ( @ufFFNId, @ufGId, 'first_name', 1, 0, 1, 1, '', '', 'User and User Admin Only', 0, 0, NULL, NULL, 'First Name', 'Individual', NULL) ON DUPLICATE KEY UPDATE id = @ufFFNId;

INSERT INTO `civicrm_uf_field` ( `id`, `uf_group_id`, `field_name`, `is_active`, `is_view`, `is_required`, `weight`, `help_post`, `help_pre`, `visibility`, `in_selector`, `is_searchable`, `location_type_id`, `phone_type_id`, `label`, `field_type`, `is_reserved`) VALUES ( @ufFLNId, @ufGId, 'last_name', 1, 0, 1, 2, '', '', 'User and User Admin Only', 0, 0, NULL, NULL, 'Last Name', 'Individual', NULL) ON DUPLICATE KEY UPDATE id = @ufFLNId;

INSERT INTO `civicrm_uf_field` ( `id`, `uf_group_id`, `field_name`, `is_active`, `is_view`, `is_required`, `weight`, `help_post`, `help_pre`, `visibility`, `in_selector`, `is_searchable`, `location_type_id`, `phone_type_id`, `label`, `field_type`, `is_reserved`) VALUES ( @ufFEId, @ufGId, 'email', 1, 0, 1, 3, '', '', 'User and User Admin Only', 0, 0, NULL, NULL, 'Email (Primary)', 'Contact', NULL) ON DUPLICATE KEY UPDATE id = @ufFEId;

INSERT INTO `civicrm_uf_field` ( `id`, `uf_group_id`, `field_name`, `is_active`, `is_view`, `is_required`, `weight`, `help_post`, `help_pre`, `visibility`, `in_selector`, `is_searchable`, `location_type_id`, `phone_type_id`, `label`, `field_type`, `is_reserved`) VALUES ( @ufFSAId, @ufGId, 'street_address', 1, 0, 0, 4, '', '', 'User and User Admin Only', 0, 0, NULL, NULL, 'Street Address (Primary)', 'Contact', NULL) ON DUPLICATE KEY UPDATE id = @ufFSAId;

INSERT INTO `civicrm_uf_field` ( `id`, `uf_group_id`, `field_name`, `is_active`, `is_view`, `is_required`, `weight`, `help_post`, `help_pre`, `visibility`, `in_selector`, `is_searchable`, `location_type_id`, `phone_type_id`, `label`, `field_type`, `is_reserved`) VALUES ( @ufFCId, @ufGId, 'city', 1, 0, 0, 5, '', '', 'User and User Admin Only', 0, 0, NULL, NULL, 'City (Primary)', 'Contact', NULL) ON DUPLICATE KEY UPDATE id = @ufFCId;

INSERT INTO `civicrm_uf_field` ( `id`, `uf_group_id`, `field_name`, `is_active`, `is_view`, `is_required`, `weight`, `help_post`, `help_pre`, `visibility`, `in_selector`, `is_searchable`, `location_type_id`, `phone_type_id`, `label`, `field_type`, `is_reserved`) VALUES ( @ufFSPId, @ufGId, 'state_province', 1, 0, 0, 6, '', '', 'User and User Admin Only', 0, 0, NULL, NULL, 'State (Primary)', 'Contact', NULL) ON DUPLICATE KEY UPDATE id = @ufFSPId;

INSERT INTO `civicrm_uf_field` ( `id`, `uf_group_id`, `field_name`, `is_active`, `is_view`, `is_required`, `weight`, `help_post`, `help_pre`, `visibility`, `in_selector`, `is_searchable`, `location_type_id`, `phone_type_id`, `label`, `field_type`, `is_reserved`) VALUES ( @ufFPCId, @ufGId, 'postal_code', 1, 0, 0, 7, '', '', 'User and User Admin Only', 0, 0, NULL, NULL, 'Postal Code (Primary)', 'Contact', NULL) ON DUPLICATE KEY UPDATE id = @ufFPCId;

SET @ufJId := '';

SELECT @ufJId := id FROM civicrm_uf_join WHERE module = 'Profile' AND uf_group_id = @ufGId;
  
INSERT INTO `civicrm_uf_join` ( `id`, `is_active`, `module`, `entity_table`, `entity_id`, `weight`, `uf_group_id`) VALUES
( @ufJId, 1, 'Profile', NULL, NULL, @ufGId , @ufGId ) ON DUPLICATE KEY UPDATE id = @ufJId;

