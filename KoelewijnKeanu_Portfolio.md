# Portfolio M122

Autor: Keanu Maleeq Koelewijn

Datum: 01-07-2023

Version: 1.0

# Einleitung

Für diese Leistungsbeurteilung haben wir die Möglichkeit, unser eigenes Skript zu erstellen. Mein Skript kann mehrere Unterordner gleichzeitig komprimieren (in ein .zip-Format umwandeln), um Speicherplatz zu sparen. Gleichzeitig kann man die Dateien auch wieder dekomprimieren, um den Inhalt in voller Grösse zu erhalten. Zusätzlich werden alle Aktionen automatisch in einer Protokolldatei erfasst, um die Nachverfolgung zu erleichtern.



## Bedeutung der Komprimierung und Dekomprimierung

Beim Komprimieren von Dateien werden die Informationen innerhalb der Datei so umstrukturiert, dass sie weniger Speicherplatz einnehmen. Dies geschieht, indem wiederholte Datenmuster identifiziert und effizienter dargestellt werden. Beim Erstellen eines ZIP-Archivs werden mehrere Dateien und Ordner in einer einzigen Datei zusammengefasst. Diese komprimierte Datei hat eine kleinere Grössse als die ursprünglichen Dateien zusammen.



## Beschreibung des Themas

In diesem Modul 122 geht es darum, Skriptsprachen kennenzulernen, insbesondere Powershell, und sich mit der Automatisierung von Abläufen mithilfe einer Skriptsprache auseinanderzusetzen.



## Aufgabenstellung

Sie formulieren eine Problemstellung, dokumentieren diese und implementieren eine Lösung in PowerShell.



## Was habe ich gelernt?

In diesem Portfolio werde ich dokumentieren, wie ich gelernt habe, Ordner zu komprimieren und zu dekomprimieren und den dadurch eingesparten Speicherplatz auszugeben.

## Beschreibung

PowerShell ist eine Skriptsprache, die verwendet wird, um Programme zu erstellen, die bestimmte Aufgaben oder Abläufe durchführen, um eine Problemstellung zu lösen. Der grosse Unterschied zwischen Skriptsprachen und Programmiersprachen besteht darin, dass sie nicht vor der Ausführung des Programms in Maschinencode kompiliert werden müssen und direkt von einem Interpreter ausgeführt werden. 

Mein erstes eigenes Skriptsprachenprojekt ist ein Programm, das ausgewählte Ordner komprimiert und dekomprimiert. Es zeigt auch den eingesparten Speicherplatz an. Dafür wird zunächst der Dateipfad benötigt. Als Beispiel wird hier ```C:\Beispielordner``` verwendet.

Um die Grösse der Datei zu bestimmen, erstellt man eine neue Funktion. Funktionen sind benannte Codeblöcke, die eine bestimmte Aufgabe oder Operation ausführen. Um die Grösse herauszufinden, benötigt man das Cmdlet ```Get-ChildItem```. 

Mit diesen drei Schritten kann man bereits die Grösse eines Ordners herausfinden. Zusammengefasst sieht das dann so aus.

```powershell
#deklaration des Pfades in einer variabel
$pfad = C:\Beispielordner

#funktion um die grösse zu berrechnen
function Get-FolderSize($pfad) {
return (Get-ChildItem -Path $pfad -Recurse | Measure-Object -Property Length -Sum).Sum
}
```

Die Funktion ```Get-ChildItem``` liefert eine Liste aller Dateien und Unterordner im angegebenen Pfad. Mit der Option ```-Recurse``` wird festgelegt, dass alle Dateien und Unterordner rekursiv (alle Elemente in einer Verzeichnishierarchie durchsuchen und sie auf einfache Weise verarbeiten.) durchlaufen werden sollen. Das Cmdlet ```Measure-Object``` berechnet die Grösse der Dateien, indem es die Eigenschaft ```Length``` summiert. Am Ende wird der Wert mit ```return``` zurückgegeben.

Nun wurde die Grösse des Ordners ermittelt. Es fehlt jedoch noch die Komprimierung. Mit der Funktion ```Compress-Archive``` kann eine Datei komprimiert werden. Hierfür wird erneut eine Funktion erstellt, jedoch diesmal um den Ordner zu komprimieren. Zum Dekomprimieren kann man einfach ```Compress-Archive``` durch ```Expand-Archive``` ersetzen.

```powershell
#deklaration des Zielpfades
$zielPfad = C:\Beispielordner.zip
$pfad = C:\Beispielordner

#funktion um zu komprimieren
function Get-Compression() {
    Compress-Archive -Path $pfad -DestinationPath $zielPfad
}
```

Die Variable `$zielPfad` repräsentiert den gewünschten Pfad der Datei oder des Ordners nach der Komprimierung, wobei der Dateiname mit `.zip` endet. Eine neue Funktion mit dem Namen `Get-Compression` wird erstellt. Diese Funktion kann jedoch auch einen anderen Namen haben, dies entscheidet man selber.

Um eine Datei oder einen Ordner zu komprimieren, muss der Pfad zur Quelldatei ```-Path``` bzw. zum Quellordner sowie der Ziel-Pfad ```-DestinationPath``` angegeben werden. Anschliessend wird die Datei oder der Ordner einfach komprimiert.

Nun kann alles zusammengesetzt werden und es werden noch einige kleine Schritte hinzugefügt. Dann ist es möglich, Ordner zu komprimieren und zu sehen, wie viel Speicherplatz dabei eingespart wird.

```powershell
# Deklaration des Pfades in einer Variable
$pfad = "C:\Beispielordner"
$zielPfad = "C:\Beispielordner.zip"

# Funktion um die Grösse zu berechnen
function Get-FolderSize ($pfad) {
    return (Get-ChildItem -Recurse $pfad | Measure-Object -Property Length -Sum).Sum
}

# Funktion zum Komprimieren
function Compress-Folder ($pfad, $zielPfad) {
    Compress-Archive -Path $pfad -DestinationPath $zielPfad -Force
}

$ordnerGroesseVorher = Get-FolderSize $pfad
Compress-Folder $pfad $zielPfad
$ordnerGroesseNacher = (Get-Item $zielPfad).Length

$speicherGespart = $ordnerGroesseVorher - $ordnerGroesseNacher

Write-Host "Gesparter Speicherplatz beträgt $($speicherGespart) Bytes."

```

Die Variable ```ordnerGroesseVorher``` speichert die Grösse des Ordners, bevor er komprimiert wird. Anschliessend wird der Ordner mithilfe der Funktion ```Compress-Folder``` komprimiert. Um den gesparten Speicherplatz zu berechnen, wird die Grösse des komprimierten Ordners in der Variable ```ordnerGroesseNacher``` gespeichert. Diese beiden Werte, ```ordnerGroesseVorher``` und ```ordnerGroesseNacher```, werden subtrahiert, um den gesparten Speicherplatz zu ermitteln. Um die Grösse ```ordnerGroesseNacher``` zu erhalten, wird nicht die Funktion ```Get-FolderSize``` verwendet. Stattdessen greift man auf ```(Get-Item $zielPfad).Length``` zu. Der komprimierte Ordner wird als eine Datei betrachtet, während der unkomprimierte Ordner viele Dateien enthält. Das Ergebnis wird mithilfe von ```Write-Host``` ausgegeben, um es dem Benutzer in der Konsole anzuzeigen.



### Demonstration

![Aufzeichnung 2023-07-02 144848](https://github.com/Kurizaki/M122/assets/110892283/2c035971-7d97-4add-978a-923a39b5c96e)


(Mit PowerShell kann man seine eigene Kreativität ausleben, und es gibt verschiedene Ansätze, um ein Problem zu lösen. Die vorherige Beschreibung war eine vereinfachte Erklärung meiner Lösung für das Problem. Es gibt jedoch viele andere Möglichkeiten, das Problem anzugehen und es gibt Raum für individuelle Herangehensweisen und kreative Lösungen in PowerShell.)



## Verifikation

* Quelle 1: Der Text wurde selbst verfasst, um das Gelernte zu erklären.
* Quelle 2: Code-Snippets wurden aus eigenem Code ausgewählt, angepasst und für das Portfolio verwendet, um die Umsetzung zu erklären.
* Quelle 3: Das Gif wurde selber erstellt, um zu veranschaulichen, was in diesem Portfolio erklärt wurde.

# Reflexion zum Arbeitsprozess

Ich fand das Projekt persönlich sehr interessant und bedeutend. Zunächst hatte ich Schwierigkeiten, mich in die Skriptsprache einzuarbeiten, aber mittlerweile habe ich mich deutlich verbessert. Das Schreiben des Codes selbst war nicht das grösste Problem für mich. Aber es gab bestimmte Funktionen oder Codeabschnitte, bei denen ich nicht in der Lage war, sie wie gewünscht umzusetzen. In solchen Fällen habe ich die Hilfe von ChatGPT benutzt. Das Projektthema der Komprimierung hat mich interessiert, weshalb ich mich dafür entschieden habe, die Komprimierung und Dekomprimierung von Unterordnern als mein Projekt auszuwählen.

Während des Projekts habe ich gelernt, dass es wichtig ist, geduldig zu sein. Anfangs war ich frustriert, als ich Schwierigkeiten mit der Skriptsprache hatte, aber ich wollte immer nach der Lösung suchen und habe mich intensiv damit beschäftigt.

Darüber hinaus habe ich erkannt, dass es wichtig ist, sich für ein Thema zu entscheiden, das einem persönlich auch gefällt. Durch die Auswahl dieses Themas für mein Projekt wollte ich das ein guter Code dabei raus kommt.
