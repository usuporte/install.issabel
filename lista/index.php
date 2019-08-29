<?php

$msg[0] = "Conexãeo com o banco falhou!";

$modoOperacao = $_GET['modo'];
$B_ExibirOnline = true;
$B_ExibirOffline = true;

if ($modoOperacao == 1) {
    $B_ExibirOffline = false;
} else if ($modoOperacao == 2) {
    $B_ExibirOnline = false;
}

$host = "localhost";
$db = "asterisk";
$user = "asteriskuser";
$pass = "camtec!2013";
$query = "SELECT u.extension, u.name, u.outboundcid, u.sipname, (CASE WHEN (SELECT COUNT(*) FROM sip s WHERE s.id = u.extension) > 0 THEN 'sip' WHEN (SELECT COUNT(*) FROM iax i WHERE i.id = u.extension) > 0 THEN 'iax' else 'custom' END) AS Type from users u";

$con = mysql_connect($host, $user, $pass);
mysql_select_db($db);
$dados = mysql_query($query);
$linha = mysql_fetch_assoc($dados);
$total = mysql_num_rows($dados);

?>

<html>
<head>
	<title>Lista Telefônica</title>
	<script src="https://ajax.googleapis.com/ajax/libs/jquery/3.1.0/jquery.min.js"></script>
    	<link rel="stylesheet" type="text/css" href="https://cdn.datatables.net/1.10.12/css/jquery.dataTables.min.css">
    	<script type="text/javascript" src="//cdn.datatables.net/1.10.12/js/jquery.dataTables.min.js"></script>
    	<script type='text/javascript'>
        $(document).ready(function(){
	    $('#example').DataTable({
		"language":{
			"info":           "Mostrando página _START_ de _END_ das _TOTAL_ entradas",
			"lengthMenu":     "Mostrar _MENU_ por página",
			"search":         "Buscar:",
			"paginate": {
     			"first":      "Primeiro",
		        "last":       "ultimo",
		        "next":       "Proximo",
		        "previous":   "Anterior"
			 }
		}
		});
	});
	</script>
	<meta charset="UTF-8">
</head>
<body>
	<h1 align="center">Catálogo Telefônico</h1>
	<div align="center">
	<input id="inp" type="button" value="Online" onclick="location.href='?modo=1';" />
        <input id="inp" type="button" value="Offline" onclick="location.href='?modo=2';" />
        <input id="inp" type="button" value="Todos" onclick="location.href='?modo=0';" />
	</div>
	<table id="example" class="display" width="100%" cellspacing="0">
		<thead>
		    <tr>
			<th>Estado</th>
		        <th>Nome</th>
			<th>Telefone</th>
			<th>Tipo</th>
			<th>Departamento</th>
			<th>E-mail</th>
	            </tr>
		</thead>
		<tbody>
			<tr>
	<? if($total > 0) {
		while($linha = mysql_fetch_assoc($dados))
		{
                          if($linha['Type']=="sip"){
                                  $estado = exec("asterisk -x 'sip show peer " . $linha['extension'] ." ' | grep \ Status | cut -d: -f2 | cut -d\  -f2");
                          }
                          elseif($linha['Type']=="iax"){
                                  $estado = exec("asterisk -x 'iax2 show peer " . $linha['extension'] ." ' | grep \ Status | cut -d: -f2 | cut -d\  -f2");
                          }
                          else{
                                $estado = "Custom";
                          }

			if ($B_ExibirOnline == false && ( $estado == "OK" || $estado == "Custom" ) )
				continue;

			if ($B_ExibirOffline == false && (!( $estado == "OK" || $estado == "Custom" ) ) )
				continue;
	?>
                        <td style="text-align:center"><?
				if($estado == "OK" or $estado=="Custom"){
					echo "<p hidden>1</p><img src='images/online.png' width='20px' height='auto' border='none' align='middle'>";
				}
				else{
					echo "<p hidden>2</p><img src='images/offline.png' width='20px' height='auto' border='none' align='middle'>";
				}
                                ?></td>
			<td><?=$linha['name']?></td>
			<td style="text-align:center"><?
				if($linha['outboundcid'] !=""){
					echo ($linha['outboundcid'] . "(" . $linha['extension'] . ")");
				}
				else{
					echo $linha['extension'];
				}?></td>
			<td style="text-align:center"><?=$linha['Type']?></td>
			<td style="text-align:center"><?=$linha['sipname']?></td>
			<td style="text-align:center"><?
				$email = exec("cat /etc/asterisk/voicemail.conf | grep " . $linha['extension']);
				$email = explode(',', $email);
				echo $email[2];
			?></td>
			</tr>
	<?
		}
	}
	?>
		</tbody>
	</table>
	<p>&nbsp;</p>
	<div style=" margin-bottom: 0; background-color:white ; border-top: 1px solid #ddd; position: relative; z-index: 10; font-size: 10px; display: block !important; text-align: center; min-height: 20px; width: 100%;">
		<a href="http://www.camtecnologia.com.br"><img src='images/cam-clean.png' width="150px" height='auto' align='middle' /></a>
                <p>Copyright © 2016 CAM Tecnologia. Todos os direitos reservados.</p>

	</div>
</body>
<?
// tira o resultado da busca da memória
mysql_free_result($dados);
?>
</html>
