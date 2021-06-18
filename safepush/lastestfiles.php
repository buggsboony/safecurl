<?php
//Fichier récupérateurs des derniers fichiers modifiés sur un serveur
//Version du 2021-06-12 11:21:58
//Utilisation :
//http://ei-eval02.com/stationpilotage/latestfiles.php?pwd=safecurl&d=12&n=6

if(  !isset($_REQUEST["pwd"]) )
{
    die("pwd");
}

$pwd=$_REQUEST["pwd"];
if($pwd=="safecurl")
{
    //ok
}else
{
    die("Oups, bad pwd");
}



date_default_timezone_set($tz="America/Martinique");

$excludes=array(
    "./vendor/"
    ,"\/uploads/"
    ,"./_conn_/"); //Exclude patterns

$daysAgo=2;
if( isset($_REQUEST["d"]) )
{    
    $daysAgo=intval($_REQUEST["d"]); // x derniers jours à partir de la date la plus récente du serveur
}
 
$nLastFiles=null; // 20 derniers fichiers
if( isset($_REQUEST["n"]) )
{    
    $nLastFiles=intval($_REQUEST["n"]);
}

$VERBOSE = false;
if( isset($_REQUEST["v"]) )
{    
    $VERBOSE=intval($_REQUEST["v"]);  
}



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
       $isdir = is_dir($value);
       
       $allowed=true;
       foreach( $excludes as $pattern):
            $found = strpos($fullname,$pattern);
            if($found===false)
            {
                $allowed=true;
            }else
            {
                if($VERBOSE>1) echo "EXCLUDE : [$fullname]\n";
            }
       endforeach;
       if($allowed)
       {
            if( $modif_time_ts > $dtAgo->getTimestamp() )
            {
                   if($VERBOSE>1)  echo "ADD : '$fullname' [$filemtime]\n";
                   $local_list[]=compact("isdir","filemtime","fullname","mtime");
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
   $jsonlist=array();
   global $VERBOSE, $dtAgo,$nLastFiles, $local_list ;
   $local_list=array();//reset list
   $results =  dirToArray($dir,"visi_job");   
   //var_dump( $results );
   $cnt = count($local_list);
   if($VERBOSE) echo " $cnt fichier(s) trouvé(s).\n";
      /*       
               ["filemtime"]=>   string(19) "2021-06-06 19:19:12"
               ["fullname"]=>   string(9) "./app.php"
      */
   foreach( $local_list as $fileinfo):
      if($VERBOSE>1) { echo "fileinfo: "; var_dump( $fileinfo); }
         $mtime= $fileinfo["mtime"] ;
         $datetime = date("Y-m-d H:i:s", $fileinfo["mtime"] );
         $frDate = date($frFormat="d/m/Y H:i:s", $fileinfo["mtime"] );
         $fname= $fileinfo["fullname"];
         $isdir= $fileinfo["isdir"];
         //echo "$frDate => $fname \n";
         //$jsonlist[]=compact("fname", "mtime", "datetime");
         //if($mtime>$dtAgo->getTimestamp()) 
         if(!$isdir) //Si c'est un fichier, on empile
         {
           $jsonlist[$mtime]=$fname.";".$mtime.";".$datetime;
         }
   endforeach;
   krsort($jsonlist);//sort by date desc
   if($nLastFiles)
   {
     //Tronquer :
      $topN = array_chunk($jsonlist,$nLastFiles)[0];
      return $topN;
   }
   return $jsonlist;
}//scan


if($VERBOSE) echo "<textarea style=\"width:100%;height:100%; background-color:#565;\">";
$jsonlist = scan(".");
if($VERBOSE) echo count($jsonlist)." fichiers(s)\n";
//echo json_encode($jsonlist,JSON_PRETTY_PRINT);
echo implode("\n",$jsonlist);
if($VERBOSE) echo "</textarea>";
?>