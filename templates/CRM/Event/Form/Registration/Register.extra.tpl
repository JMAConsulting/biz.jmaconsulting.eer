{if $addshareNspouse } {literal} 
<script type="text/javascript">
cj('fieldset legend').each(function(index) {
if (cj(this).text() == 'Other Parent Or Guardian' ) {
cj(this).after(' <div class = "crm-section"><div class ="label" >{/literal}{$form.is_spouse.label}{literal}</div><div class ="content" id = "is_spouse" >{/literal}{$form.is_spouse.html}{literal}</div><div class="clear"></div></div><div class = "crm-section"><div class ="label" >{/literal}{$form.is_shareAdd.label}{literal}</div><div class ="content" id = "is_share">{/literal}{$form.is_shareAdd.html}{literal}</div><div class="clear"></div></div>');
}
});

cj(document).ready(function() {
 if ( !cj('#email-Primary1').val() && cj('#email-5').val()) {
cj('#email-Primary1').val(cj('#email-5').val());
cj('#email-5').val('');
}

cj('#is_share input:radio').each( function() {
if ( cj(this).is(':checked') ) {
   if( cj(this).val() == 1 ) {
    cj(".street_address-Primary2-section").hide();
    cj(".city-Primary2-section").hide();
    cj(".state_province-Primary2-section").hide();
    cj(".postal_code-Primary2-section").hide();
   }
}
});	
	
});
cj('#is_share input').click( function() {
if ( cj(this).val() == 1 ) {
  cj("#street_address-Primary2").val(cj('#street_address-Primary1').val());
  cj("#city-Primary2").val(cj('#city-Primary1').val());
  cj("#state_province-Primary2").val(cj('#state_province-Primary1').val());
  cj("#postal_code-Primary2").val(cj('#postal_code-Primary1').val());
  cj(".street_address-Primary2-section").hide();
  cj(".city-Primary2-section").hide();
  cj(".state_province-Primary2-section").hide();
  cj(".postal_code-Primary2-section").hide();
} else {
  cj("#street_address-Primary2").val('');
  cj("#city-Primary2").val('');
  cj("#state_province-Primary2").val('');
  cj("#postal_code-Primary2").val('');
  cj(".street_address-Primary2-section").show();
  cj(".city-Primary2-section").show();
  cj(".state_province-Primary2-section").show();
  cj(".postal_code-Primary2-section").show();
}
});

</script>
{/literal}
{/if}
