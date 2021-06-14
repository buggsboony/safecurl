#!/bin/env php
<?php
$nowStr = date("d/m/Y H:i:s") ;
$APP_NAME="SafePush Tool";
$VERSION="1.03";


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


date_default_timezone_set($tz="America/Martinique");
$excludes=array("./.vscode/metadata");
$minutesAgo=720; // 720minutes => 12h
$VERBOSE = false;

//récupérer les arguments :    $>    safepush -x "pattern to exclude"  -x "pattern2 to exclude" -t minutesAgo
for($i=0; $i<count($argv); $i++)
{
    $arg = $argv[$i];
    if( ($arg === "-t" ) || ( $arg === "-m" ) || ( $arg === "--minutes" )  || ( $arg === "--min" ) )
    {
        $minutesAgo=intval($argv[$i+1] );
    }   
    if(  ($arg === "-x") || ($arg === "--exclude")  )
    {
        $exclude= ($argv[$i+1] );
        $excludes[]=$exclude;
    }    
    if(  ($arg === "-v")  )
    {
        $VERBOSE=true;
    }    
}
//var_dump( $argv); die("arg pose");





//Greetings --------------------
echo "$_YELL $APP_NAME"." Version $VERSION $_DEF - TZ: $tz\n";


$dtNow = new DateTime();
$dtMinsAgo= clone $dtNow;
$ts = $dtNow->getTimestamp();
$dtMinsAgo->setTimestamp($ts-($minutesAgo*60) );
 


echo "file modification time : $_ORAN$minutesAgo $_DEF minutes ago\n";
echo "Search files mdate after : ". $dtMinsAgo->format("Y-m-d H:i:s") ." - $_GREEN". $dtMinsAgo->format("d/m/Y H:i:s") ."$_DEF\n";
if(count($excludes)>0) 
{
    echo "Exclusion patterns : \n$_MAG".implode("\n",$excludes)." $_DEF\n";    
}else{
    echo "$_ORAN 0$DEF exclusion pattern\n";
}


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
$local_list=array(); 

function visi_job($value)
{
    global $local_list,$dtMinsAgo, $excludes, $VERBOSE;
       $modif_time_ts = filemtime($value);
       //var_dump($value, date("F d Y H:i:s",$modif_time_ts) );     
    // $dtw =new DateTime( ); $dtw->setTimestamp($modif_time_ts);
    // echo "modiftime=";var_dump($modif_time_ts  , $dtw->format("Y-m-d H:i:s")  ); exit;               
       
       $filemtime = date("Y-m-d H:i:s",$modif_time_ts);
       $mtime = $modif_time_ts;
       $fullname=$value;  
       
       $allowed=true;
       foreach( $excludes as $pattern):
            $found = strpos($fullname,$pattern);
            if($found===false)
            {
                $allowed=true;
            }else
            {
                if($VERBOSE) echo "EXCLUDE : [$fullname]\n";
            }
       endforeach;
       if($allowed)
       {
            if( $modif_time_ts > $dtMinsAgo->getTimestamp() )
            {
                   if($VERBOSE)  echo "ADD : '$fullname' [$filemtime]\n";
                   $local_list[]=compact("filemtime","fullname","mtime");
            }
       }//endif allowed
    
      //echo $value."\n";
}//visi_job


function dirToArray($dir, $fn) 
{       
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
   global $local_list, $_ORAN, $_DEF;
   $local_list=array();//reset list
   $results =  dirToArray($dir,"visi_job");   
   //var_dump( $results ); //Tous les dirs
   $cnt = count($local_list);
   echo " $cnt fichier(s) trouvé(s).\n";
      /*
       ["filemtime"]=>
   string(19) "2021-06-06 19:19:12"
   ["fullname"]=>
   string(9) "./app.php"

   */
   $directories=array();
   foreach( $local_list as $fileinfo):
         $frDate = date("d/m/Y H:i:s", $fileinfo["mtime"] );
         $fname= $fileinfo["fullname"];
         $dir = dirname( $fname);

         if( ! array_key_exists($dir, $directories) ) { $directories[$dir]=array(); }
         $directories[$dir][] = $fname;

         echo $frDate."$_ORAN $fname $_DEF\n";
   endforeach;

   //Parcourir les dir et demander les modifications sur le serveur (Gain de temps car requete sur les dirs et non par fichier
   foreach( $directories as $dir):
        //curlRequest()
   endforeach;

}//scan



/// SafePush Tool Version 1.03  2021-06-05 19:29:55
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

//---------------------------------------    Point d'entrée          -------------------------
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

//scan(".");
   




$sepDate = array(" "," ");//Séparateur de date dans la chaine exemple: Jun  5 18:58 scripts.js
$url=""; die("url vide");
$content = curlRequest($url);
$lines = explode("\n",$content);
$remoteInfos=array();
foreach($lines as $line_untrimmed):
    $line =  trim($line_untrimmed);   //-rw-r--r--   1 adminev02 psacln      16944 Jun  5 18:58 scripts.js
    if( $line )
    {
        $parts = preg_split('/\s+/', $line);
        //echo "parts:";var_dump($parts);
        //echo "Line: [$line]";
        $filesize=$parts[4];
        $filedate=$parts[5]." ".$parts[6].$sepDate[1].$parts[7];
        $dhm=$parts[6].$sepDate[1].$parts[7];
        //séparer gauche et droite, pour avoir le nom du fichier
        $pair = explode($dhm,$line);
        if(count($pair)>1)
        {
             $filename=trim($pair[1]);
             $datetime = strToTime($filedate); //la date est au fuseau local (puisque curl la convertie pour nous)
             $infos = compact("filesize","datetime","filedate","filename");
             $remoteInfos[]=$infos;
             echo "\nLine OK [$line]\n";
             var_dump($infos);
        }
        else 
        {
            echo "date[$filedate] pair :" ;var_dump( $pair);
            echo "Prob avec ligne:[$line]\n";            
        }
        //var_dump($filesize,$filedate,$filename);
    }
endforeach;
         
?>