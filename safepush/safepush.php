#!/bin/env php
<?php
$nowStr = date("d/m/Y H:i:s") ;
$APP_NAME="SafePush Tool";
$VERSION="1.03";

include_once("common.php");


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



$dtNow = new DateTime();
$dtMinsAgo= clone $dtNow;
$ts = $dtNow->getTimestamp();
$dtMinsAgo->setTimestamp($ts-($minutesAgo*60) );
 


echo "file modification time : $_ORAN$minutesAgo $_DEF minutes ago\n";
echo "Search files mdate after : ". $dtMinsAgo->format("Y-m-d H:i:s") ."\nDate FR:\n$_LGREEN". $dtMinsAgo->format("d/m/Y H:i:s") ."$_DEF\n";
if(count($excludes)>0) 
{
    echo "Exclusion patterns : \n$_ORAN".implode("\n",$excludes)." $_DEF\n";    
}else{
    echo "$_ORAN 0$DEF exclusion pattern\n";
}

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
   global $local_list, $_ORAN, $_DEF;
   $local_list=array();//reset list
   $results =  dirToArray($dir,"visi_job");   
   //var_dump( $results );
   $cnt = count($local_list);
   echo " $cnt fichier(s) trouvé(s).\n";
      /*
       ["filemtime"]=>
   string(19) "2021-06-06 19:19:12"
   ["fullname"]=>
   string(9) "./app.php"

   */
   foreach( $local_list as $fileinfo):
         $frDate = date("d/m/Y H:i:s", $fileinfo["mtime"] );
         $fname= $fileinfo["fullname"];
         echo "$frDate$_ORAN $fname $_DEF\n";
   endforeach;
}//scan



























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


 

/// SafePush Tool Version 1.03  2021-06-05 19:29:55



//var_dump($tasks_json ,$tjson);
//var_dump( $tjson->credentials );

scan(".");
   




?>