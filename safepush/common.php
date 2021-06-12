<?php

//Couleurs dans la console linux
//$_DEF ="\e[39m";
$_DEF = "\033[0m";
$_ORAN="\033[0;33m";
$_RED ="\033[0;31m";
$_GREEN="\033[0;32m"; #echo "$_LRED'$tasks' does not exists.$_DEF\n";
$_LGREEN="\033[1;32m";
$_WHITE="\033[1;37m";
$_YELL="\033[1;33m";
$_RED="\033[0;31m";
$_LRED="\033[1;31m";
$_MAG="\033[0;35m";
$_LMAG="\033[1;35m";
$_CYAN="\033[0;36m";
$_LCYAN="\033[1;36m";

//2021-06-12 13:11:48 starts with function for older php
function startsWith($haystack, $needle) { $length = strlen($needle); return (substr($haystack, 0, $length) === $needle); } 

/**
 * Clean comments of json content and decode it with json_decode().
 * Work like the original php json_decode() function with the same params
 *
 * @param   string  $json    The json string being decoded
 * @param   bool    $assoc   When TRUE, returned objects will be converted into associative arrays. 
 * @param   integer $depth   User specified recursion depth. (>=5.3)
 * @param   integer $options Bitmask of JSON decode options. (>=5.4)
 * @return  array/object
 */
function json_clean_decode($json, $assoc = false, $depth = 512, $options = 0) {

    // search and remove comments like /* */ and //
    $json = preg_replace("#(/\*([^*]|[\r\n]|(\*+([^*/]|[\r\n])))*\*+/)|([\s\t]//.*)|(^//.*)#", '', $json);

    if(version_compare(phpversion(), '5.4.0', '>=')) { 
        return json_decode($json, $assoc, $depth, $options);
    }
    elseif(version_compare(phpversion(), '5.3.0', '>=')) { 
        return json_decode($json, $assoc, $depth);
    }
    else {
        return json_decode($json, $assoc);
    }
}//json_clean_decode

///2021-06-05 16:24:44 - returns last json error (json_decode ) project safepush
function getLastJsonError()
{

    switch (json_last_error()) {
        case JSON_ERROR_NONE:
            $err= ' - Aucune erreur';
        break;
        case JSON_ERROR_DEPTH:
            $err= ' - Profondeur maximale atteinte';
        break;
        case JSON_ERROR_STATE_MISMATCH:
            $err= ' - Inadéquation des modes ou underflow';
        break;
        case JSON_ERROR_CTRL_CHAR:
            $err= ' - Erreur lors du contrôle des caractères';
        break;
        case JSON_ERROR_SYNTAX:
            $err= ' - Erreur de syntaxe ; JSON malformé';
        break;
        case JSON_ERROR_UTF8:
            $err= ' - Caractères UTF-8 malformés, probablement une erreur d\'encodage';
        break;
        default:
        $err= ' - Erreur inconnue';
        break;
    }
    return $err;
}//last Json error



// Exemple de résultat
// string(91) "Last-Modified: Sat, 05 Jun 2021 22:58:55 GMT
// Content-Length: 16944
// Accept-ranges: bytes
function curlRequestFileDate($url)
{
    $curl = curl_init();
    curl_setopt($curl, CURLOPT_URL,$url);
 
    curl_setopt($curl, CURLOPT_RETURNTRANSFER, 1);
    curl_setopt($curl, CURLOPT_NOBODY, 1);

    curl_setopt($curl, CURLOPT_FILETIME, TRUE );

    $result = curl_exec ($curl);
    var_dump($result);
    $time = curl_getinfo($curl, CURLINFO_FILETIME);
    print date('d/m/y H:i:s', $time);

    curl_close ($curl);
}


function curlRequest($url)
{ 
        // Initialisez une session CURL.
        $ch = curl_init();          
        // Récupérer le contenu de la page
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1); 
        
        //Saisir l'URL et la transmettre à la variable.
        curl_setopt($ch, CURLOPT_URL, $url); 
        //récupérer le datage distant du fichier
        //curl_setopt($ch, CURLOPT_FILETIME, true);

        //Désactiver la vérification du certificat puisque server utilise HTTPS
        //curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, false);

        //Exécutez la requête 
        $result = curl_exec($ch); 
        //Afficher le résultat
        return $result;  
}//curlRequest




//----------- vscode tasks read ----------------------------
// {
//     "label": "ftp_download",
//     "type": "shell",
//     "command": "safecurl",
//     "args": [
//         "ftp://${config:tasks.credentials}/${config:tasks.context}/${relativeFile}",
//         "-o",
//         "${file}",
//         "--create-dirs"
//         ,"--check"
//         ,".vscode/metadata/${relativeFile}"
//     ],
//     "group": "build",
//     "problemMatcher": []
// }



//Find a vscode task by label
function findTask($tjson,$label)
{
    foreach($tjson->tasks as $task):
        if($task->label==$label)
        return $task;
    endforeach;
    return null; //none found
}//find vscode findTask

function rplcVscodeVars($tjson,$var_vals, $str)
{
  foreach($var_vals as $var=>$val)
  {
      $str = str_replace($var,$val,$str);
  }
  return $str;
}

//Try to execute vscode task
function runtask($task,$tjson,$args)
{   
     $vscode_vars = array(
        "\${config:tasks.credentials}"=>$tjson->credentials
        ,"\${config:tasks.context}"=>$tjson->context
        ,"\${relativeFile}"=>$args["relativeFile"]     
        ,"\${file}"=>$args["file"]        
    );
    //"ftp://${config:tasks.credentials}/${config:tasks.context}/${relativeFile}"
    $fullcom="";
    $command = $task->command;
    $args = $task->args;
    foreach($args as &$arg):
        //echo "AVANT :[$arg]\n";
        $arg = "\"".rplcVscodeVars($tjson, $vscode_vars, $arg)."\"";
        //echo "arg Apres [$arg] :";
    endforeach;
    $argstr= implode(" ",$args);
    $fullcom=$command." ".$argstr;
    echo "\nfullcom=[$fullcom]\n";
    //exec()
    //var_dump($task);
}//safecurl command
?>