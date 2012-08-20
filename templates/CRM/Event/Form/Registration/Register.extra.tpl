{if $addshareNspouse } {literal} 
<script type="text/javascript">

cj('.first_name1-section').before(' <div class = "crm-section"><div class ="label" >{/literal}{$form.is_spouse.label}{literal}</div><div class ="content" id = "is_spouse" >{/literal}{$form.is_spouse.html}{literal}</div><div class="clear"></div></div><div class = "crm-section"><div class ="label" >{/literal}{$form.is_shareAdd.label}{literal}</div><div class ="content" id = "is_share">{/literal}{$form.is_shareAdd.html}{literal}</div><div class="clear"></div></div>');
cj(document).ready(function() {
 if ( !cj('#email0').val() && cj('#email-5').val()) {
cj('#email0').val(cj('#email-5').val());
cj('#email-5').val('');
}

cj('#is_share input:radio').each( function() {
if ( cj(this).is(':checked') ) {
   if( cj(this).val() == 1 ) {
    cj(".street_address1-section").hide();
    cj(".city1-section").hide();
    cj(".state_province1-section").hide();
    cj(".postal_code1-section").hide();
   }
}
});	
	
});
cj('#is_share input').click( function() {
if ( cj(this).val() == 1 ) {
  cj("#street_address1").val(cj('#street_address0').val());
  cj("#city1").val(cj('#city0').val());
  cj("#state_province1").val(cj('#state_province0').val());
  cj("#postal_code1").val(cj('#postal_code0').val());
  cj(".street_address1-section").hide();
  cj(".city1-section").hide();
  cj(".state_province1-section").hide();
  cj(".postal_code1-section").hide();
} else {
  cj("#street_address1").val('');
  cj("#city1").val('');
  cj("#state_province1").val('');
  cj("#postal_code1").val('');
  cj(".street_address1-section").show();
  cj(".city1-section").show();
  cj(".state_province1-section").show();
  cj(".postal_code1-section").show();
}
});

</script>
{/literal}
{/if}
