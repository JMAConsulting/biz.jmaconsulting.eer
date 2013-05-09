{literal}
<script type="text/javascript">
	cj(document).ready(function() {

	cj(".crm-event-manage-registration-form-block-registration_link_text").before('<tr class="crm-event-manage-registration-form-block-is_enhanced"> <td class="label">{/literal}{$form.is_enhanced.label}{literal}</td><td>{/literal}{$form.is_enhanced.html}{literal}<span class="description">Enable or disable is enhanced for this event.</span></td></tr>');

	if( cj("#is_enhanced").attr('checked') == 'checked') {
	      cj(".crm-event-manage-registration-form-block-custom_pre_id").hide();
	      cj("#profile_post").hide();
              cj("#additional_profile_pre").hide();
	      cj("#additional_profile_post").hide();
	      cj(".crm-event-manage-registration-form-block-create-new-profile").hide();
	}
	});
	cj("#is_enhanced").click(function(){
		if( cj("#is_enhanced").attr('checked') == 'checked') {
		    var r = confirm("Are you sure you want to change the profiles for this event to those used in Enhanced Registration?");
		    if(r == true) {
		    	cj("#is_enhanced").attr('checked',true);
			cj("#is_multiple_registrations").attr('checked',true);

		   	cj("#custom_pre_id").val(4);
		   	cj("#additional_custom_pre_id").val(4);
			cj(".crm-event-manage-registration-form-block-custom_pre_id").hide();
			cj("#profile_post").hide();
			cj("#additional_profile_pre").hide();
			cj("#additional_profile_post").hide();
			cj(".crm-event-manage-registration-form-block-create-new-profile").hide();
		    } else {
		    	 cj("#is_enhanced").attr('checked',false);
			 cj("#is_multiple_registrations").attr('checked',false);
		    }
                } else {
		     cj("#is_multiple_registrations").attr('checked',false);
		     cj(".crm-event-manage-registration-form-block-custom_pre_id").show();
		     cj("#profile_post").show();
		     cj("#additional_profile_pre").show();
		     cj("#additional_profile_post").show();
		     cj(".crm-event-manage-registration-form-block-create-new-profile").show();
		}
	});
</script>
{/literal}