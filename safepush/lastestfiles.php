<?php

//2021-06-12 10:39:50 - Fichier récupérateurs des derniers fichiers modifiés sur un serveur

date_default_timezone_set($tz="America/Martinique");

$excludes=array(
    "./vendor/"
    ,"\/uploads/"
    ,"./_conn_/"); //Exclude patterns

$daysAgo=2; // 2 derniers jours à partir de la date la plus récente du serveur
//$nLastFiles=1; // 20 derniers fichiers
$VERBOSE = false;
 


$dtNow = new DateTime();
$dtAgo= clone $dtNow; //dtDaysAgo
$ts = $dtNow->getTimestamp();
$minutesAgo = $daysAgo * 24 *60; //convertir en minute pour récupérer l'ancien code qui suit
$dtAgo->setTimestamp($ts-($minutesAgo*60) );
 


$ignoredPaths=array();
//$ignoredPaths[]="./vendor"; //path to ignore analyse

//visi_job functionn
$local_list=array(); 

function visi_job($value)
{
    global $local_list,$dtAgo, $excludes, $VERBOSE;
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
            if( $modif_time_ts > $dtAgo->getTimestamp() )
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
   global $VERBOSE, $local_list ;
   $local_list=array();//reset list
   $results =  dirToArray($dir,"visi_job");   
   //var_dump( $results );
   $cnt = count($local_list);
   if($VERBOSE) echo " $cnt fichier(s) trouvé(s).\n";
      /*
       ["filemtime"]=>
   string(19) "2021-06-06 19:19:12"
   ["fullname"]=>
   string(9) "./app.php"

   */
   foreach( $local_list as $fileinfo):
         $frDate = date("d/m/Y H:i:s", $fileinfo["mtime"] );
         $fname= $fileinfo["fullname"];
         echo "$frDate => $fname \n";
   endforeach;
}//scan



scan(".");

?>