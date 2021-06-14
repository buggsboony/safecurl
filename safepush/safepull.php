#!/bin/env php
<?php
$nowStr = date("d/m/Y H:i:s") ;
$APP_NAME="SafePull Tool";
$VERSION="1.12";


include_once("common.php");


date_default_timezone_set($tz="America/Martinique");
$workspace = getcwd(); //grab vscode workspace path
$excludes=array("./.vscode/metadata");
$daysAgo=15; // 2 derniers jours à partir de la date la plus récente du serveur
$nLastFiles=6; // 20 derniers fichiers
$skipFirstNfiles=0;
$VERBOSE = false;

//récupérer les arguments :    $>    safepull -t 2  ou  -n 10  --skip 8 #Skip pour ignorer les n premiers fichiers du lot
for($i=0; $i<count($argv); $i++)
{
    $arg = $argv[$i];
    if( ($arg === "-t" ) || ( $arg === "-j" ) || ( $arg === "--days" )  || ( $arg === "-d" ) )
    {
        $daysAgo=intval($argv[$i+1] );
    }   
    if(  ($arg === "-n") || ($arg === "--count") || ($arg === "-f")  || ($arg === "-c")  )
    {
        $nLastFiles=intval($argv[$i+1] );
    }  

    if(  ($arg === "-s") || ($arg === "--skip") || ($arg === "-i") || ($arg === "--ignore") )
    {
        $skipFirstNfiles=intval($argv[$i+1] );
    }    

    if(  ($arg === "-v")  )
    {
        $VERBOSE=true;
    }    
}
//var_dump( $argv); die("arg pose");



$dtNow = new DateTime();
$dtDaysAgo= clone $dtNow;
$ts = $dtNow->getTimestamp();
$minutesAgo = $daysAgo * 24 *60; //convertir en minute pour récupérer l'ancien code qui suit
$dtDaysAgo->setTimestamp($ts-($minutesAgo*60) );


//Greetings --------------------
echo "$_YELL $APP_NAME"." Version $VERSION $_DEF - TZ: $tz\n";

echo "Modification time : $_ORAN$daysAgo$_DEF days ago\n";
echo "Top $_ORAN$nLastFiles$_DEF files \n";
echo "Search files mdate after : ". $dtDaysAgo->format("Y-m-d H:i:s") ."\nDate FR:\n$_LGREEN". $dtDaysAgo->format("d/m/Y H:i:s") ."$_DEF\n";
if(count($excludes)>0) 
{
    echo "exclusion patterns : \n$_ORAN".implode("\n",$excludes)." $_DEF\n";    
}else{
    echo "$_ORAN 0$_DEF exclusion patterns\n";
}


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


$URL_BASE="ftp://".$tjson->credentials;
if( property_exists($tjson,"url") )
{
    $urlweb=$tjson->url;
}else
{
    echo $_RED."Oups, url property is missing in file '$tasks'$_DEF\n";
    exit;
}
echo "Request for last $nLastFiles latest files.\n";
$url_latestfiles=$urlweb."/latestfiles.php?pwd=safecurl&d=".$daysAgo."&n=".$nLastFiles;
echo "URL lastfiles :$_ORAN $url_latestfiles $_DEF\n";
$content = file_get_contents($url_latestfiles);
$lines = explode("\n", $content);
$files=array();
$npos=0;
foreach($lines as $line)
{
    $file = explode(";",$line);
    $datetime=$file[2];
    $mtime=$file[1]; $frdate=date("d/m/Y H:i:s", $mtime);
    $fname=$file[0];
    $files[]=$file;
    $pos = str_pad(++$npos, 2,"0", STR_PAD_LEFT);
    echo $pos.":$_GREEN $frdate - $fname$_DEF\n";
}
echo "\n".count($files)." files found, $skipFirstNfiles will be ignored.\n";
$resp = trim( strtolower( readline("Confirm SafeCurl download (yes,y,oui,o/no) :\n") ));
if( ( $resp[0] =="o" ) || ( $resp[0]=="y" ) )
{    
    //   var_dump($files);
    $dtElapsedStart = new DateTime();
    $task_ftp_download = findTask($tjson,"ftp_download");
    $n=0;
    foreach($files as $file):                
        $relativeFile = $fname=$file[0];        
        if( startsWith($relativeFile,"./") ) $relativeFile = substr($relativeFile,2); //enlever le ./ devant le relative filename        
        $vscode_local_file = $workspace.DIRECTORY_SEPARATOR.$relativeFile;

        if( ++$n <= $skipFirstNfiles )
        {
            echo "Ignored : $_YELL".$relativeFile."$_DEF\n";
        }else
        {
            echo "File :  $_GREEN".$relativeFile."$_DEF\n";
            echo "Running task: $_YELL".$task_ftp_download->label."$_DEF\n";
            $args = array(
                "relativeFile"=>$relativeFile
                ,"file"=>$vscode_local_file
            );
            runtask($task_ftp_download, $tjson, $args);    
        }

    endforeach;
    $dtElapsedEnd = new DateTime();
   $nSec = ( $dtElapsedEnd->getTimestamp() - $dtElapsedStart->getTimestamp() );
   echo intval($nSec/60)." mins ". ($nSec%60) . " secs\n";

}else
{
    //Do nothing
}

echo $_WHITE."Terminé.$_DEF\n";


/// TODO , comment procéder quand ils y a des ficheirs datés de 2 années différentes
?>