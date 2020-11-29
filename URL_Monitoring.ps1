# URL Liste
# Die Datei aus der die URLs gelesen werden
$URLListFile = "C:\PowershellScript\URLList.txt"

# URLListe wird in die Variable gespeichert
$URLList = Get-Content $URLListFile -ErrorAction SilentlyContinue 

$ResultHtml = @()
$ResultPing = @()


# Für jede URL wird die Schleife durchlaufen
  Foreach($Uri in $URLList) {
  $time = try{
  $request = $null
   ## URL requesten
   # Die Zeit die die Request braucht wird gemessen und in $result1 in ms gespeichert
  $result1 = Measure-Command { $request = Invoke-WebRequest -Uri $uri -UseBasicParsing }
  $result1.TotalMilliseconds
  }  

  # Der Catch-Block filtert Errors heraus und sorgt dafür dass diese später angezeigt werden können. 

  catch
  {
   <# Wenn die URL eine Exception generiert hat (wie z.B 500 -> Internal Server Error), 
   kann man den Statuscode pullen und in die Tabelle eintragen. Sonst ist es ein OK #>
   $request = $_.Exception.Response
   $time = -1
  }
  
  # eigenes Objekt wird erstellt
  # Die Daten die später angezeigt werden sollen werden im Objekt $resulthtml gespeichert
  $resulthtml += [PSCustomObject] @{
  # Uhrzeit
  Time = Get-Date;
  # URI aus der Variable $uri
  Uri = $uri;
  # Statuscode aus $request
  StatusCode = [int] $request.StatusCode;
  # Statusbeschreibung aus $request
  StatusDescription = $request.StatusDescription;
  # Länge der Antwort aus $request
  ResponseLength = $request.RawContentLength;
  # Zeit aus $time -> also die ms aus dem Measure-Command
  TimeTaken =  $time; 
  }

}


# Das Ausgabeobjekt des Skripts sorgt für eine geordnete Tabelle im HTML-Format 
# HTML wird vorbereitet
if($resulthtml -ne $null)
{
    $Outputreport = "<HTML><TITLE>Website Availability Report</TITLE><BODY background-color:peachpuff><font color =""#99000"" 
    face=""Microsoft Tai le""><H2> Website Availability Report </H2></font><Table border=1 cellpadding=0 
    cellspacing=0><TR bgcolor=gray align=center><TD><B>URL</B></TD><TD><B>HTML Code</B></TD><TD><B>Online Status</B></TD>
    <TD><B>ResponseLength</B></TD><TD><B>Zeit gebraucht (ms)</B></TD</TR>"
    Foreach($Entry in $ResultHtml)
    {
        # Wenn Statuscode ungleich 200, wird das Feld rot gefärbt
        if($Entry.StatusCode -ne "200")
        {
            $Outputreport += "<TR bgcolor=red>"
        }
        else
        {
            $Outputreport += "<TR>"
        }
        $Outputreport += "<TD>$($Entry.uri)</TD><TD align=center>$($Entry.StatusCode)</TD><TD align=center>$($Entry.StatusDescription)</TD>
        <TD align=center>$($Entry.ResponseLength)</TD><TD align=center>$($Entry.timetaken)</TD></TR>"
    }    
    $Outputreport += "</Table></BODY></HTML>"
}


# Es wird eine Datei erstellt, in der alle Informationen ausgegeben werden
$Outputreport | out-file C:\PowershellScript\URLTabelle.html
Invoke-Expression C:\PowershellScript\URLTabell.html
