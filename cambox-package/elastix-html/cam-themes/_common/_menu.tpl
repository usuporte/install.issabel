{* SE GENERA EL AUTO POPUP SI ESTA ACTIVADO *} 
{if $AUTO_POPUP eq '1'}
   {literal}
   	<script type='text/javascript'>
 	$('.togglestickynote').ready(function(e) {
            $("#neo-sticky-note-auto-popup").attr('checked', true);
	    note();
	});
	</script>
   {/literal}
{/if}
<div id="fullMenu">
  <table cellspacing=0 cellpadding=0 width="100%" border=0>
    <tr>
      <td>
        <table cellSpacing="0" cellPadding="0" width="100%" border="0" height="76">
          <tr>
            <td class="menulogo" width=380><a href='http://www.camtecnologia.com.br' target='_blank'><img src="themes/{$THEMENAME}/images/logo.png" border='0' /></a></td>
            {foreach from=$arrMainMenu key=idMenu item=menu}
            {if $idMenu eq $idMainMenuSelected}
            <td class="headlinkon" valign="bottom">
              <table cellSpacing="0" cellPadding="2" height="30" border="0">
                <tr><td class="menutabletabon_left" nowrap valign="top"><IMG src="themes/{$THEMENAME}/images/1x1.gif"></td><td class="menutabletabon" title="" nowrap><a
                        class="menutableon" href="index.php?menu={$idMenu}">{$menu.Name}</a></td><td class="menutabletabon_right" nowrap valign="top"><IMG src="themes/{$THEMENAME}/images/1x1.gif"></td>
                </tr>
              </table>
            </td>
            {else}
            <td class="headlink" valign="bottom">
              <div style="position:absolute; z-index:200; top:65px;"><a href="javascript:mostrar_Menu('{$idMenu}')"><img src="themes/{$THEMENAME}/images/corner.gif" border="0"></a></div>
              <input type="hidden" id="idMenu" value=""></input>
              <div class="vertical_menu_oculto" id="{$idMenu}">
                <table cellpadding=0 cellspacing=0>
                    {$arrMenuTotal.$idMenu}
                </table>
              </div>
              <table cellSpacing="0" cellPadding="2" height="29" border="0">
                <tr><td class="menutabletaboff_left" nowrap valign="top"><IMG src="themes/{$THEMENAME}/images/1x1.gif"></td><td class="menutabletaboff" title="" nowrap><a
                        class="menutable" href="index.php?menu={$idMenu}">{$menu.Name}</a></td><td class="menutabletaboff_right" nowrap valign="top"><IMG src="themes/{$THEMENAME}/images/1x1.gif"></td>
                </tr>
              </table> 
            </td>
            {/if}
            {/foreach}
            <td>
                <div id='acerca_de'>
                    <table border='0' cellspacing="0" cellpadding="2" width='100%'>
                        <tr class="moduleTitle">
                            <td class="moduleTitle" align="center" colspan='2'>
                                CAM TECNOLOGIA LTDA ME - CAMBOX Soluções de telefonia
                            </td>
                        </tr>
                        <tr class="tabForm" >
                            <td class="tabForm"  height='138' colspan='2' align='center'>
                                Soluções de voz, dados e vídeo<br />
                                <a href='http://www.camtecnologia.com.br' target='_blank'>www.camtecnologia.com.br</a>
                            </td>
                        </tr>
                        <tr>
                            <td class="moduleTitle" align="center" colspan='2'>
                                <input type='button' value='{$ABOUT_CLOSED}' onclick="javascript:cerrar();" />
                            </td>
                        </tr>
                    </table> 
                </div>
            </td>
	    <td class="menuaftertab" align="right"><span><a class="register_link" style="color: {$ColorRegister}; cursor: pointer; font-weight: bold; font-size: 13px;" onclick="showPopupElastix('registrar','{$Register}',538,400)">{$Registered}</a></span>&nbsp;&nbsp;&nbsp;&nbsp;</td>
            <td class="menuaftertab" width="40%" align="right">&nbsp;<a class="logout" id="viewDetailsRPMs">{$VersionDetails}</a></td>
            <td class="menuaftertab" width="40%" align="right">&nbsp;<a href="javascript:mostrar();">{$ABOUT_ELASTIX}</a></td>
            <td class="menuaftertab" width="20%" align="right">&nbsp;<a href="index.php?logout=yes">{$LOGOUT}</a></td>
          </tr>
        </table>
      </td>
    </tr>
    <tr>
      <td class="menudescription">
        <table cellspacing="0" cellpadding="2" width="100%">
          <tr>
            <td>
              <table cellspacing="2" cellpadding="4" border="0">
                <tr>
                  {foreach from=$arrSubMenu key=idSubMenu item=subMenu}
                  {if $idSubMenu eq $idSubMenuSelected}
                  <td title="" class="botonon"><a href="index.php?menu={$idSubMenu}" class="submenu_on">{$subMenu.Name}</td>
                  {else}
                  <td title="" class="botonoff"><a href="index.php?menu={$idSubMenu}">{$subMenu.Name}</a></td>
                  {/if}
                  {/foreach}
                </tr>
              </table>
            </td>
            <td align="right" valign="middle">
				<img src="themes/{$THEMENAME}/images/tab_notes.png" alt="tabnotes" id="togglestickynote1" class="togglestickynote" style="cursor: pointer;" border="0" />&nbsp;
				<a href="javascript:popUp('help/?id_nodo={$idSubMenuSelected}&name_nodo={$nameSubMenuSelected}','1000','460')"><img
                src="themes/{$THEMENAME}/images/help_top.gif" border="0"></a>&nbsp;&nbsp;<a href="javascript:changeMenu()"><img
                src="themes/{$THEMENAME}/images/arrow_top.gif" border="0"></a>&nbsp;&nbsp;</td>
          </tr>
        </table>
      </td>
    </tr>
    <tr class="downshadow"><td><img src="themes/{$THEMENAME}/images/1x1.gif" height="5"></td></tr>
  </table>
</div>
<div id="miniMenu" style="display: none;">
  <table cellspacing="0" cellpadding="0" width="100%" class="menumini">
    <tr>
      <td><img src="themes/{$THEMENAME}/images/logo.png" border="0"></td>
      <td align="right" class="letra_gris" valign="middle">{$nameMainMenuSelected} &rarr; {$nameSubMenuSelected} {if !empty($idSubMenu2Selected)} &rarr; {$nameSubMenu2Selected} {/if}
		  &nbsp;&nbsp;<img src="themes/{$THEMENAME}/images/tab_notes_bottom.png" alt="tabnotes" id="togglestickynote2"  class="togglestickynote" style="cursor: pointer;" border="0"
          align="absmiddle" />
          &nbsp;&nbsp;<a href="javascript:popUp('help/?id_nodo={$idSubMenuSelected}&name_nodo={$nameSubMenuSelected}','1000','460')"><img src="themes/{$THEMENAME}/images/help_bottom.gif" border="0" 
          align="absmiddle"></a>
          &nbsp;&nbsp;<a href="javascript:changeMenu()"><img src="themes/{$THEMENAME}/images/arrow_bottom.gif" border="0" align="absmiddle"></a>&nbsp;&nbsp;
      </td>
    </tr>
  </table>
</div>

<div id="boxRPM" style="display:none;">
    <div class="popup">
        <table>
            <tr>
                <td class="tl"/>
                <td class="b"/>
                <td class="tr"/>
            </tr>
            <tr>
                <td class="b"/>
                <td class="body">
                    <div class="content_box">
                        <div id="table_boxRPM">
                           <table width="100%" border="0" cellspacing="0" cellpadding="4" align="center">
                                <tr class="moduleTitle">
                                    <td class="moduleTitle">
                                        <div>
                                            <div style="float: left;">&nbsp;&nbsp;{$VersionPackage}&nbsp;</div>
                                            <div align="right" style="padding-top: 5px;"><a id="changeMode" style="visibility: hidden;">({$textMode})</a></div>
                                        </div>
                                    </td>
                                </tr>
                                <tr>
                                    <td class="moduleTitle" id="loadingRPM" align="center" style="display: block;">
                                        <img class="loadingRPMimg" alt="loading" src="images/loading.gif"  />
                                    </td>
                                </tr>
                                <tr>
                                    <td id="tdRpm" style="display: block;">
                                        <table  id="tableRMP" width="100%" border="1" cellspacing="0" cellpadding="4" align="center">

                                        </table> 
                                    </td>
                                </tr>
                                <tr>
                                    <td id="tdTa" style="display: none;">
                                        <textarea  id="txtMode" value="" rows="60" cols="60"></textarea>
                                    </td>
                                </tr>
                            </table>
                        </div>
                    </div>
                    <div class="footer">
                        <a class="close_box_RPM">
                        <img src="images/closelabel.gif" title="close" class="close_image_box" />
                        </a>
                    </div>
                </td>
                <td class="b"/>
            </tr>
            <tr>
                <td class="bl"/>
                <td class="b"/>
                <td class="br"/>
            </tr>
        </table>
    </div>
</div><div id="fade_overlay" class="black_overlay"></div>

<table width="100%" cellpadding="0" cellspacing="0" height="100%">
  <tr>
    {if !empty($idSubMenu2Selected)}
    <td width="200px" align="left" valign="top" bgcolor="#f6f6f6" id="tdMenuIzq">
      <table cellspacing="0" cellpadding="0" width="100%" class="" align="left">
        {foreach from=$arrSubMenu2 key=idSubMenu2 item=subMenu2}
          {if $idSubMenu2 eq $idSubMenu2Selected}
          <tr><td title="" class="menuiz_botonon"><a href="index.php?menu={$idSubMenu2}">{$subMenu2.Name}</td></tr>
          {else}
          <tr><td title="" class="menuiz_botonoff"><a href="index.php?menu={$idSubMenu2}">{$subMenu2.Name}</a></td></tr>
          {/if}
        {/foreach}
      </table>
    </td>
    {/if}
<!-- Va al tpl index.tlp-->

<div id="PopupElastix" style="position: absolute; top: 0px; left: 0px;">
</div>

{literal}
<style type='text/css'>
#acerca_de{
    position:fixed;
    background-color:#FFFFFF; 
    width:440px;
    height:203px;
    border:1px solid #800000;
    z-index: 10000;
}
</style>
<script type='text/javascript'>
cerrar();
function cerrar()
{
    var div_contenedor = document.getElementById('acerca_de');
    div_contenedor.style.display = 'none';
}

function mostrar()
{
    var ancho = 440;
    var div_contenedor = document.getElementById('acerca_de');
    var eje_x=(screen.width - ancho) / 2;
    div_contenedor.setAttribute("style","left:"+ eje_x + "px; top:123px");
    div_contenedor.style.display = 'block';
}

function mostrar_Menu(element)
{
    var subMenu;

    var idMenu = document.getElementById("idMenu");
    if(idMenu.value!="")
    {
        subMenu = document.getElementById(idMenu.value);
        subMenu.setAttribute("class", "vertical_menu_oculto");
    }
    if(element != idMenu.value)
    {
        subMenu = document.getElementById(element);
        subMenu.setAttribute("class", "vertical_menu_visible");
        idMenu.setAttribute("value", element);
    }
    else idMenu.setAttribute("value", "");
}
</script>
{/literal}

<input type="hidden" id="lblTextMode" value="{$textMode}" />
<input type="hidden" id="lblHtmlMode" value="{$htmlMode}" />
<input type="hidden" id="lblRegisterCm"   value="{$lblRegisterCm}" />
<input type="hidden" id="lblRegisteredCm" value="{$lblRegisteredCm}" />
<input type="hidden" id="amount_char_label" value="{$AMOUNT_CHARACTERS}" />
<input type="hidden" id="save_note_label" value="{$MSG_SAVE_NOTE}" />
<input type="hidden" id="get_note_label" value="{$MSG_GET_NOTE}" />
<input type="hidden" id="elastix_theme_name" value="{$THEMENAME}" />
<input type="hidden" id="lbl_no_description" value="{$LBL_NO_STICKY}" />
