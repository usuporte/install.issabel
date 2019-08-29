<?php

function cleanString($text) {
    $utf8 = array(
        '/[áàâãªä]/u'   =>   'a',
        '/[ÁÀÂÃÄ]/u'    =>   'A',
        '/[ÍÌÎÏ]/u'     =>   'I',
        '/[íìîï]/u'     =>   'i',
        '/[éèêë]/u'     =>   'e',
        '/[ÉÈÊË]/u'     =>   'E',
        '/[óòôõºö]/u'   =>   'o',
        '/[ÓÒÔÕÖ]/u'    =>   'O',
        '/[úùûü]/u'     =>   'u',
        '/[ÚÙÛÜ]/u'     =>   'U',
        '/ç/'           =>   'c',
        '/Ç/'           =>   'C',
        '/ñ/'           =>   'n',
        '/Ñ/'           =>   'N',
        '/–/'           =>   '-', // UTF-8 hyphen to "normal" hyphen
        '/[’‘‹›‚]/u'    =>   ' ', // Literally a single quote
        '/[“”«»„]/u'    =>   ' ', // Double quote
        '/[\.,\!@#\$\%\^&\*\(\)_]/'           =>   ' ', // nonbreaking space (equiv. to 0x160)
        '/ /'           =>   ' ', // nonbreaking space (equiv. to 0x160)
    );
    return preg_replace(array_keys($utf8), array_values($utf8), $text);
}

function isEmpty($str)
{
	if ($str == null) return false;	
	else if (strlen($str) == 0) return false;
	else if ($str == "") return false;
	else return true;

}
$fileXML = "cfg%{MAC}.xml";

$fileMODEL = "cam-model.xml";
$fileINFO = "cam-info.csv";
$filePHONEBOOK = "phonebook.xml";

$xmlMain = '<?xml version="1.0" encoding="UTF-8"?><AddressBook>%s</AddressBook>';

$contactStruct = @"
	<Contact>
		<LastName>%{SETOR}</LastName>
		<FirstName>%{NOME}</FirstName>
		<Phone>
			<phonenumber>%{RAMAL}</phonenumber>
			<accountindex>1</accountindex>
		</Phone>
		<Groups>
			<groupid>2</groupid>
		</Groups>
	</Contact>";

$contatos = Array();

$info = Array();

print_r($info);

if (($handle = fopen($fileINFO, "r")) !== FALSE) {
	while (($data = fgetcsv($handle, 1000, ",")) !== FALSE)
		array_push($info, $data);	
    	fclose ($handle);
}
print_r($info);

foreach ($info as $row) 
{
	// 1 => MODELO
	// 2 => RAMAL
	// 5 => NOME
	// 6 => SETOR
	// 11 => MAC
	// 12 => VLAN 

	if ($row[0] == "ID") continue;
	if (!isEmpty($row[1])) continue;
	if (!isEmpty($row[2])) continue;
	if (!isEmpty($row[5])) continue;

	$contatoRow = $contactStruct;
	$contatoRow = str_replace("%{RAMAL}", $row[2], $contatoRow);
	$contatoRow = str_replace("%{NOME}", cleanString($row[5]), $contatoRow);
	$contatoRow = str_replace("%{SETOR}", $row[6], $contatoRow);
	array_push($contatos, $contatoRow);

	$telMODEL = $row[1];

	if ($telMODEL == "GXP1625" || $telMODEL == "GXP1610" || $telMODEL == "GXP1615" || $telMODEL == "GXP1628")
	{
		$fileMODEL = "cam-model-1625.xml";
	} 
	else if ($telMODEL == "2120")
	{	
		$fileMODEL = "cam-model-2120.xml";
	}
	else if ($telMODEL == "IPS212")
	{
		$fileMODEL = "cam-model-ips212.xml";
	}
	else
	{
		continue;
	}

	if (!isEmpty($row[11])) continue;
	//if (!isEmpty($row[12])) continue;

	$model = file_get_contents($fileMODEL);

	$config = $model;

	$config = str_replace("%{RAMAL}", $row[2], $config);
	$config = str_replace("%{NOME}", cleanString($row[5]), $config);
	//$config = str_replace("%{VLAN}", $row[12], $config);

	if ($telMODEL == "2120")
	{
		$config = str_replace("%{BLF1NOME}", $row[17], $config);
		$config = str_replace("%{BLF1ID}", $row[18], $config);
		$config = str_replace("%{BLF2NOME}", $row[19], $config);
		$config = str_replace("%{BLF2ID}", $row[20], $config);
		$config = str_replace("%{BLF3NOME}", $row[21], $config);
		$config = str_replace("%{BLF3ID}", $row[22], $config);
	}
	
	$xml = $fileXML;
	if ($telMODEL == "IPS212")
		$xml = "%{MAC}.xml";

	$xml = str_replace("%{MAC}", strtolower($row[11]), $xml);

	print $xml . "\r\n";

	file_put_contents($xml, $config);

	unset($contatoRow);
	unset($config);
}

file_put_contents($filePHONEBOOK, sprintf($xmlMain, join("\r\n", $contatos) . "\r\n" ));

?>
