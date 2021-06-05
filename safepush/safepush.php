#!/bin/env php
<?php
$nowStr = date("d/m/Y H:i:s") ;
$APP_NAME="SafePush Tool";
$VERSION="1.03";


$_DEF ="\e[39m";
$_YELL="\033[0;33m";
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


$ignoredPaths[]="/home/boony/Documents/dev/web"; //path to ignore
//visi_job functionn
function visi_job($value)
{
       $modif_time = filemtime($value);
       var_dump($value, date("F d Y h:i:s",$modif_time) );
      //echo $value."\n";
}//visi_job


function dirToArray($dir, $fn) {       
   global $ignoredPaths;
    $result = array();

       $cdir = scandir($dir);

       foreach ($cdir as $key => $value)
       {//remove ignored
                  
          if (!in_array($value,array(".","..")))
          {        
             if (is_dir($dir . DIRECTORY_SEPARATOR . $value))
             {
                $result[$value] = dirToArray($dir . DIRECTORY_SEPARATOR . $value,$fn);
             }
 
                $fullpath=$dir . DIRECTORY_SEPARATOR . $value;
                $foundIndexOrFalse = array_search($fullpath, $ignoredPaths);
                if($foundIndexOrFalse === false)
                {                              
                
                      //echo "chek time for: [".$fullpath."] \n";
                      call_user_func($fn,$fullpath);
                      $result[] = $value;
                      
                }//ignore this folder
                else
                {
                   //echo "$fullpath-----------------IGNORED  \n";
                   //die("ignored");
                }
 
          }
       }//next dir in list
 
    return $result;
 }//dir to array
 
function scan($dir)
{
   global $visi_latest_time;
   $results =  dirToArray($dir,"visi_job");

   
   //var_dump( $results );
}//scan













//Greetings --------------------
echo "$_YELL $APP_NAME"." Version $VERSION $_DEF\n";

$tasks=".vscode/tasks.json";

if(!file_exists($tasks))
{
    echo "$_LRED'$tasks' does not exists.$_DEF\n";
    die("Oups...\n");
}

$tasks_json=file_get_contents($tasks);

$tjson = json_clean_decode($tasks_json);

if($tjson===null)
{
    echo "$_LRED decode $tasks failed.$_DEF\n".getLastJsonError()."\n";

    die("Sorry...\n");
}

//var_dump($tasks_json ,$tjson);
//var_dump( $tjson->credentials );

scan(".");
   


?>