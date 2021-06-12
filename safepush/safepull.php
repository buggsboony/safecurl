#!/bin/env php
<?php
$nowStr = date("d/m/Y H:i:s") ;
$APP_NAME="SafePull Tool";
$VERSION="1.08";


include_once("common.php");


date_default_timezone_set($tz="America/Martinique");
$excludes=array("./.vscode/metadata");
$daysAgo=7; // 7 derniers jours
$nLastFiles=20; // 20 derniers fichiers
$VERBOSE = false;

//récupérer les arguments :    $>    safepull -t 7  ou  -n 10 
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
$dtDaysAgo->setTimestamp($ts-($minutesAgo*60) );
 


echo "file modification time : $_ORAN$minutesAgo $_DEF minutes ago\n";
echo "Search files mdate after : ". $dtDaysAgo->format("Y-m-d H:i:s") ."\nDate FR:\n$_LGREEN". $dtDaysAgo->format("d/m/Y H:i:s") ."$_DEF\n";
if(count($excludes)>0) 
{
    echo "exclusion patterns : \n$_ORAN".implode("\n",$excludes)." $_DEF\n";    
}else{
    echo "$_ORAN 0$DEF exclusion patterns\n";
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


 
         
?>