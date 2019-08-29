<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF8" />
        <title>CAMBOX Open Telephony</title>
        <link rel="stylesheet" href="themes/{$THEMENAME}/styles.css" />
        <link rel="stylesheet" href="themes/{$THEMENAME}/help.css" />
	<link rel="shortcut icon" href="/themes/{$THEMENAME}/images/favicon.ico" type="image/x-icon" />
		<link rel="stylesheet" media="screen" type="text/css" href="themes/{$THEMENAME}/sticky_note.css" />
	{$HEADER_LIBS_JQUERY}
        <script src="libs/js/base.js"></script>
        <script src="libs/js/iframe.js"></script>
		<script type='text/javascript' src="libs/js/sticky_note.js"></script>
        {$HEADER}
	{$HEADER_MODULES}
    </head>
    <body leftmargin="0" topmargin="0" marginwidth="0" marginheight="0" {$BODYPARAMS}>
        {$MENU} <!-- Viene del tpl menu.tlp-->
                <td align="left" valign="top">
                    {if !empty($mb_message)}
                        <!-- Message board -->
                        <table width="100%" border="0" cellspacing="0" cellpadding="0" align="center" class="message_board">
                            <tr>
                                <td valign="middle" class="mb_title">&nbsp;{$mb_title}</td>
                            </tr>
                            <tr>
                                <td valign="middle" class="mb_message">{$mb_message}</td>
                            </tr>
                        </table><br />
                        <!-- end of Message board -->
                    {/if}
                    <table border="0" cellpadding="6" width="100%">
			<tr class="moduleTitle">
			  <td class="moduleTitle" valign="middle" colspan='2'>&nbsp;&nbsp;{if $icon ne null}<img src="{$icon}" border="0" align="absmiddle">&nbsp;&nbsp;{/if}{$title}</td>
			</tr>
                        <tr>
                            <td>
                            {$CONTENT}
                            </td>
                        </tr>
                    </table><br />
                    <div align="center" class="copyright"><a href="http://www.camtecnologia.com.br" target='_blank'>CAMBOX Open Telephony</a> is running over Elastix. {$currentyear}.</div>
                    <br>
                </td>
            </tr>
        </table>
		<div id="neo-sticky-note" class="neo-display-none">
		  <div id="neo-sticky-note-text"></div>
		  <div id="neo-sticky-note-text-edit" class="neo-display-none">
			<textarea id="neo-sticky-note-textarea"></textarea>
			<div id="neo-sticky-note-text-char-count"></div>
			<input type="button" value="{$SAVE_NOTE}" class="neo-submit-button" id="neo-submit-button" onclick="send_sticky_note()" />
			<div id="auto-popup">AutoPopUp <input type="checkbox" id="neo-sticky-note-auto-popup" value="1"></div>
		  </div>
	          <div id="neo-sticky-note-text-edit-delete"></div>
		</div>
		<div class="neo-modal-elastix-popup-box">
			<div class="neo-modal-elastix-popup-title"></div>
			<div class="neo-modal-elastix-popup-close"></div>
			<div class="neo-modal-elastix-popup-content"></div>
		</div>
		<div class="neo-modal-elastix-popup-blockmask"></div>
    </body>
</html>
