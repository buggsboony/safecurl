#!/bin/env php
<?php
$nowStr = date("d/m/Y H:i:s") ;
$APP_NAME="SafePull Tool";
$VERSION="1.08";


include_once("common.php");


date_default_timezone_set($tz="America/Martinique");
$workspace = getcwd(); //grab vscode workspace path
$excludes=array("./.vscode/metadata");
$daysAgo=15; // 2 derniers jours à partir de la date la plus récente du serveur
$nLastFiles=6; // 20 derniers fichiers
$VERBOSE = false;

//récupérer les arguments :    $>    safepull -t 2  ou  -n 10 
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


echo "file modification time : $_ORAN$daysAgo $_DEF days ago\n";
echo "Search files mdate after : ". $dtDaysAgo->format("Y-m-d H:i:s") ."\nDate FR:\n$_LGREEN". $dtDaysAgo->format("d/m/Y H:i:s") ."$_DEF\n";
if(count($excludes)>0) 
{
    echo "exclusion patterns : \n$_ORAN".implode("\n",$excludes)." $_DEF\n";    
}else{
    echo "$_ORAN 0$_DEF exclusion patterns\n";
}


//Greetings --------------------
echo "$_YELL $APP_NAME"." Version $VERSION $_DEF - TZ: $tz\n";

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
$urlweb=$tjson->url;
echo "Request for last $nLastFiles latest files.\n";
$url_latestfiles=$urlweb."/latestfiles.php?pwd=safecurl&d=".$daysAgo."&n=".$nLastFiles;
echo "url lastfiles :$_ORAN $url_latestfiles $_DEF\n";
$content = file_get_contents($url_latestfiles);
$lines = explode("\n", $content);
$files=array();
foreach($lines as $line)
{
    $file = explode(";",$line);
    $datetime=$file[2];
    $mtime=$file[1]; $frdate=date("d/m/Y H:i:s", $mtime);
    $fname=$file[0];
    $files[]=$file;
    echo "$_GREEN $frdate - $fname$_DEF\n";
}
echo count($files)." files found.\n";
$resp = trim( strtolower( readline("Confirm SafeCurl download (yes,y,oui,o/no) :\n") ));
if( ( $resp[0] =="o" ) || ( $resp[0]=="y" ) )
{    
    //   var_dump($files);
    $task_ftp_download = findTask($tjson,"ftp_download");
    foreach($files as $file):                
         $relativeFile = $fname=$file[0];
        if( startsWith($relativeFile,"./") ) $relativeFile = substr($relativeFile,2); //enlever le ./ devant le relative filename        
        $vscode_local_file = $workspace.DIRECTORY_SEPARATOR.$relativeFile;

        echo "running task: $_YELL".$task_ftp_download->label."$_DEF\n";
        $args = array(
            "relativeFile"=>$relativeFile
            ,"file"=>$vscode_local_file
        );
        runtask($task_ftp_download, $tjson, $args);    
    endforeach;
}else
{
    echo $_WHITE."Terminé.$_DEF\n";
    exit;
}



/// TODO , comment procéder quand ils y a des ficheirs datés de 2 années différentes
?>