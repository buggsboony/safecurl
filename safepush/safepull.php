#!/bin/env php
<?php
$nowStr = date("d/m/Y H:i:s") ;
$APP_NAME="SafePull Tool";
$VERSION="1.08";


include_once("common.php");


date_default_timezone_set($tz="America/Martinique");
$excludes=array("./.vscode/metadata");
$daysAgo=2; // 2 derniers jours à partir de la date la plus récente du serveur
$nLastFiles=1; // 20 derniers fichiers
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






//$dir = $tjson->context;
// $url="ftp://".$tjson->credentials."/".$dir."/"; //Slash à la fin pour demander la liste contenu par le dossier
// //echo "url:"; var_dump( $url );
// $content="-rw-r--r--   1 adminev02 psacln      12999 Jun 11 14:22 app.php\n"; //exemple avec un fichier
// $content="drwxr-xr-x   2 adminev02 psacln          6 Apr 28 11:24 class\n"; //Exemple avec un dossier
// //$content = curlRequest($url);
// $lines = explode("\n",$content);
// $sepDate = array(" "," ");//Séparateur de date dans la chaine exemple: Jun  5 18:58 scripts.js

// $list=array();
// foreach($lines as $line_untrimmed):
//     $line =  trim($line_untrimmed);   //-rw-r--r--   1 adminev02 psacln      16944 Jun  5 18:58 scripts.js
//     if( $line )
//     {
//         $parts = preg_split('/\s+/', $line);
//         $type=$parts[0][0];
//         echo "parts:";var_dump($parts);
//         echo "\nLine: [$line]\n";
//         $filesize=$parts[4];
//         $day_and_hours=$parts[6].$sepDate[1].$parts[7];
//         $filedate=$parts[5].$sepDate[0].$day_and_hours;
//         $ident_split = $filesize." ".$parts[5];
//         //séparer gauche et droite, pour avoir le nom du fichier
//         $pair = explode($day_and_hours,$line);
//         $filename=null;
//         if(count($pair)>1) $filename=trim($pair[1]);
//         else echo "Prob avec ligne:[$line]\n";
//         $datetime=date("Y-m-d H:i:s", $timestamp=strtotime($filedate) );        
//         //echo "analyse:";var_dump($filesize,$filedate,$filename);
//         $fullname=$dir."/".$filename;
//         $key=$timestamp."_".$fullname;//sort key
//         $current=compact("type","fullname","filename", "filedate", "filesize");
//         //Sort by date desc :
//         $list[$key]=$current;
//     }
// endforeach;
//          krsort($list);
//          $keys = array_keys($list);
//          $latestDateKey = $keys[0];
//          echo "Latest file date is : ".$latestDateKey."\n";
//          //echo "\nkrsort=>\n";var_dump($list);

$URL_BASE="ftp://".$tjson->credentials;
function getFileList($dir)
{
    global $URL_BASE;
    $url=$URL_BASE."/".$dir."/"; //Slash à la fin pour demander la liste contenu par le dossier
    //echo "url:"; var_dump( $url );
    // $content="-rw-r--r--   1 adminev02 psacln      12999 Jun 11 14:22 app.php\n"; //exemple avec un fichier
    // $content="drwxr-xr-x   2 adminev02 psacln          6 Apr 28 11:24 class\n"; //Exemple avec un dossier
    $content = curlRequest($url);
    $lines = explode("\n",$content);
    $sepDate = array(" "," ");//Séparateur de date dans la chaine exemple: Jun  5 18:58 scripts.js
    
    $list=array();
    foreach($lines as $line_untrimmed):
        $line =  trim($line_untrimmed);   //-rw-r--r--   1 adminev02 psacln      16944 Jun  5 18:58 scripts.js
        if( $line )
        {
            $parts = preg_split('/\s+/', $line);
            $type=$parts[0][0];
            // echo "parts:";var_dump($parts);
            // echo "\nLine: [$line]\n";
            $filesize=$parts[4];
            $day_and_hours=$parts[6].$sepDate[1].$parts[7];
            $filedate=$parts[5].$sepDate[0].$day_and_hours;
            $ident_split = $filesize." ".$parts[5];
            //séparer gauche et droite, pour avoir le nom du fichier
            $pair = explode($day_and_hours,$line);
            $filename=null;
            if(count($pair)>1) $filename=trim($pair[1]);
            else echo "Prob avec ligne:[$line]\n";
            $datetime=date("Y-m-d H:i:s", $timestamp=strtotime($filedate) );        
            //echo "analyse:";var_dump($filesize,$filedate,$filename);
            $fullname=$dir."/".$filename;
            $key=$timestamp."_".$fullname;//sort key
            $current=compact("type","fullname","filename", "filedate", "filesize");
            //Sort by date desc :
            $list[$key]=$current;
        }
    endforeach;
             krsort($list);
             $keys = array_keys($list);
             $latestDateKey = $keys[0];
            // echo "Latest file date is : ".$latestDateKey."\n";
             //echo "\nkrsort=>\n";var_dump($list);
    return $list;    
} //getFileList


//Version 1 2021-06-12 00:06:54
// function getLatestFiles($dir,$count)
// {
   
//     $list = getFileList($dir);
//     //récupérer les count premiers et regarder si parmi eux ya un dossier
//     $tops = array_chunk($list,$count);
//     $top=$tops[0];//Normalement yaura toujours au moins, qui aura soit la taille, soit moins
//     //echo "top=";var_dump($top[0]);
//     $c=0; $cf=0;
//     $filelist=array();//Liste de fichiers épurée (sans les dossiers)
//     foreach($top as $t):
//         $c++; //just count
//         echo "[$dir]====>  $c/$count [".$t["fullname"]."]\n";
//         if($cf>=$count)
//         {  //Le compte de fichier est atteint, on sort
//             return $filelist;
//         }else
//         {
//             //Vérifier le prochain sous dossier
//             if($t["type"]=="d")
//             { //répertoire trouvé
//                 $subdir = $dir."/".$t["filename"];
//                 $countRemain=$count-$c;
//                 $sublist = getLatestFiles($subdir,$countRemain);
//                 $filelist = array_merge( $filelist, $sublist);
//             }else
//             { //it's a file, just add
//                 $cf++; //just count
//                 echo "[$dir]++++> $cf/$count [".$t["fullname"]."]\n";
//                 $filelist[]=$t;
//             }
//         }

//     endforeach;
//     return $filelist; //count non atteind
// }//getLatestFiles


//version 1
// function getLatestFiles($dir,$count)
// {
   
//     $list = getFileList($dir);
//     //récupérer les count premiers et regarder si parmi eux ya un dossier
//     $tops = array_chunk($list,$count);
//     $top=$tops[0];//Normalement yaura toujours au moins, qui aura soit la taille, soit moins
//     //echo "top=";var_dump($top[0]);
//     $c=0; $cf=0;
//     $filelist=array();//Liste de fichiers épurée (sans les dossiers)
//     foreach($top as $t):
//         $c++; //just count
//         echo "[$dir]====>  $c/$count [".$t["fullname"]."]\n";
//         if($cf>=$count)
//         {  //Le compte de fichier est atteint, on sort
//             return $filelist;
//         }else
//         {
//             //Vérifier le prochain sous dossier
//             if($t["type"]=="d")
//             { //répertoire trouvé
//                 $subdir = $dir."/".$t["filename"];
//                 $countRemain=$count-$c;
//                 $sublist = getLatestFiles($subdir,$countRemain);
//                 $filelist = array_merge( $filelist, $sublist);
//             }else
//             { //it's a file, just add
//                 $cf++; //just count
//                 echo "[$dir]++++> $cf/$count [".$t["fullname"]."]\n";
//                 $filelist[]=$t;
//             }
//         }

//     endforeach;
//     return $filelist; //count non atteind
// }//getLatestFiles

//version 2
function getLatestFiles($dir,$count)
{
   
    $list = getFileList($dir);
    echo "\n\n\n\nfull list :\n";var_dump($list);
    //récupérer les count premiers et regarder si parmi eux ya un dossier
    $tops = array_chunk($list,$count);
    $top=$tops[0];//Normalement yaura toujours au moins, qui aura soit la taille, soit moins
    echo "\n\ntop=";var_dump($top[0]);
    $c=0; $cf=0;
    $filelist=array();//Liste de fichiers épurée (sans les dossiers)
    foreach($top as $k=>$t):
        $c++; //just count
        echo "[$dir]====>  $c/$count [".$t["fullname"]."]\n";
        if($cf>=$count)
        {  //Le compte de fichier est atteint, on sort
            return $filelist;
        }else
        {
            //Vérifier le prochain sous dossier
            if($t["type"]=="d")
            { //répertoire trouvé
                $subdir = $dir."/".$t["filename"];
                $countRemain=$count-$c;
                $sublist = getLatestFiles($subdir,$countRemain);
                $filelist = array_merge( $filelist, $sublist);
            }else
            { //it's a file, just add
                $cf++; //just count
                echo "[$dir]++++> $cf/$count [".$t["fullname"]."]\n";
                $filelist[$k]=$t;
            }
        }

    endforeach;
    return $filelist; //count non atteind
}//getLatestFiles


$latestFiles = getLatestFiles($tjson->context, $nLastFiles );
//krsort($latestFiles); //Sort again
echo "sorted latestFiles($nLastFiles): \n ";
var_dump($latestFiles);



/// TODO , comment procéder quand ils y a des ficheirs datés de 2 années différentes
?>