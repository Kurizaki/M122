<# Scriptname: KoelewijnKeanu_Skript.ps1
Author: Keanu Maleeq Koelewijn
Date: 01-07-2023
Version: 1.0
Description: Komprimiert Unterordner und Dekompremiert sie.
#> 

# Funktion zum Hinzufügen eines Protokolleintrags
function Add-ProtokollEintrag($text, $protokollDatei) {
    try {
        $datum = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        $eintrag = "$datum - $text"
        Add-Content -Path $protokollDatei -Value $eintrag
        # Taktischer Kommentar (Q1.1): Protokolleintrag wird hinzugefügt
    }
    catch {
        Fehlerbehebung
    }
}

# Funktion zum Initialisieren der Protokolldatei, falls sie nicht existiert
function InitialisiereProtokollDatei($protokollDatei) {
    try {
        if (!(Test-Path $protokollDatei)) {
            New-Item -ItemType File -Path $protokollDatei -Force | Out-Null
            # Taktischer Kommentar (Q1.2): Protokolldatei wird initialisiert, wenn sie nicht existiert.
        }
    }
    catch {
        Fehlerbehebung
    }
}

# Funktion zur Berechnung der Größe eines Ordners
function Get-OrdnerGroesse($pfad) {
    try {
        return (Get-ChildItem -Path $pfad -Recurse | Measure-Object -Property Length -Sum).Sum
        # Taktischer Kommentar (Q1.3): Die Größe des Ordners wird berechnet.
    }
    catch {
        Fehlerbehebung
    }
}

# Funktion zum Entzippen ausgewählter Ordner
function EntzippeAusgewaehlteElemente($auswahlArray, $alleElemente, $ordnerPfad, $protokollDatei) {
    try {
        Write-Host "Entzippen gestartet..."
        $gesamtGroesseVorher = 0
        $gesamtGroesseNachher = 0

        foreach ($index in $auswahlArray) {
            $element = $alleElemente[$index]
            $zielPfad = Join-Path $ordnerPfad $element.BaseName
            $groesseVorher = (Get-Item $element.FullName).Length
            $gesamtGroesseVorher += $groesseVorher

            Expand-Archive -Path $element.FullName -DestinationPath $zielPfad
            $groesseNachher = Get-OrdnerGroesse $zielPfad
            $gesamtGroesseNachher += $groesseNachher
            # Taktischer Kommentar (Q1.5): Der ausgewählte gezippte Ordner wird entzippt.

            Remove-Item -Path $element.FullName -Force
            # Taktischer Kommentar (Q1.6): Die gezippte Datei wird nach dem Entzippen gelöscht.
            Write-Host "Ordner '$($element.Name)' dekomprimiert."
            Add-ProtokollEintrag "Datei '$($element.Name)' entzippt." $protokollDatei
        }

        return $gesamtGroesseVorher, $gesamtGroesseNachher
    }
    catch {
        Fehlerbehebung
    }
}

function Fehlerbehebung {
    try {
        Write-Host "Fehlerhaftes Ereignis. Skript wird neu gestartet."
        Start-Sleep -Seconds 2
        Clear-Host
        Hauptprogramm
    }
    catch {
        Fehlerbehebung
    }
}

# Funktion zum Ausgeben der Ordner mit Numerierung
function AusgebenOrdner($ordnerArray) {
    try {
        $ordnerArray | ForEach-Object { 
            $index = [array]::IndexOf($ordnerArray, $_) + 1
            Write-Host "$index. $($_.Name)"
        }
        # Taktischer Kommentar (Q2.0): Die gefundenen Ordner und gezippten Dateien werden numeriert ausgegeben.
    }
    catch {
        Fehlerbehebung
    }
}

# Funktion zum Ausführen des Skripts
function AusfuehrenSkript($ordnerPfad, $protokollDatei) {
    try {
        InitialisiereProtokollDatei $protokollDatei
        Add-ProtokollEintrag "Skript ausgeführt $ordnerPfad" $protokollDatei

        Write-Host "Suche nach Ordnern und gezippten Dateien $ordnerPfad"

        if (Test-Path $ordnerPfad) {
            $antwort = Read-Host "Ist dieser Ordner korrekt? (y/n)"

            if ($antwort -eq "y") {
                $unterordner = Get-ChildItem -Path $ordnerPfad -Directory
                $gezippteDateien = Get-ChildItem -Path $ordnerPfad -File -Filter "*.zip"
                $alleElemente = $unterordner + $gezippteDateien
                # Taktischer Kommentar (Q1.7): Es werden alle Unterordner und gezippten Dateien im angegebenen Ordner gesammelt.

                Write-Host "Gefundene Ordner und gezippte Dateien"
                AusgebenOrdner $alleElemente

                $valid = $false
                while (-not $valid) {
                    $auswahl = Read-Host "Geben Sie die Zahlen der gewünschten Ordner/Dateien ein (z.B. 1,5) oder 'all' für alle"

                    if ($auswahl -eq "all" -or $auswahl -match '^(\d+(,\d+)*)?$') {
                        $valid = $true
                    } elseif ([string]::IsNullOrEmpty($auswahl)) {
                        Write-Host "Ungültige Eingabe. Bitte geben Sie eine gültige Auswahl ein."
                    } else {
                        Fehlerbehebung
                    }
                    # Taktischer Kommentar (Q2.0): Überprüfung der Benutzereingabe, ob sie gültig ist.
                }

                $auswahlArray = if ($auswahl -eq "all") { 0..($alleElemente.Count - 1) } else { $auswahl.Split(",").ForEach({ [int]($_) - 1 }) }

                Write-Host "Ausgewählte Ordner/Dateien:"
                $auswahlArray | ForEach-Object { Write-Host "$($_ + 1). $($alleElemente[$_].Name)" }

                $komprimierung = Read-Host "Möchten Sie die ausgewählten Ordner/Dateien komprimieren? (y/n)"

                if ($komprimierung -eq "y") {
                    $gesamtGroesseVorher, $gesamtGroesseNachher = KomprimiereAusgewaehlteElemente $auswahlArray $alleElemente $ordnerPfad $protokollDatei
                    Write-Host "Komprimierung abgeschlossen."
                    Write-Host "Gesamtgröße vor der Komprimierung: $gesamtGroesseVorher Bytes"
                    Write-Host "Gesamtgröße nach der Komprimierung: $gesamtGroesseNachher Bytes"
                }

                $entzippen = Read-Host "Möchten Sie die ausgewählten gezippten Dateien entzippen? (y/n)"

                if ($entzippen -eq "y") {
                    $gesamtGroesseVorher, $gesamtGroesseNachher = EntzippeAusgewaehlteElemente $auswahlArray $alleElemente $ordnerPfad $protokollDatei
                    Write-Host "Entzippen abgeschlossen."
                    Write-Host "Gesamtgröße vor dem Entzippen: $gesamtGroesseVorher Bytes"
                    Write-Host "Gesamtgröße nach dem Entzippen: $gesamtGroesseNachher Bytes"
                }
            }
            else {
                Fehlerbehebung
            }
        }
        else {
            Write-Host "Der angegebene Ordner existiert nicht. Bitte überprüfen Sie den Pfad."
            Fehlerbehebung
        }
    }
    catch {
        Fehlerbehebung
    }
}

# Funktion zum Hauptprogramm
function Hauptprogramm {
    try {
        $ordnerPfad = Read-Host "Geben Sie den Pfad zum Ordner ein:"
        $protokollDatei = "protokoll.txt"
        AusfuehrenSkript $ordnerPfad $protokollDatei
    }
    catch {
        Fehlerbehebung
    }
}

Hauptprogramm

#Quellen:
# Q1.1 = https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.management/add-content?view=powershell-7.3 [19-06-2023]
# Q1.2 = https://linuxhint.com/create-file-using-powershell/ [19-06-2023]
# Q1.3 = https://www.gngrninja.com/script-ninja/2016/5/24/powershell-calculating-folder-sizes [12-06-2023]
# Q1.4 = https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.archive/compress-archive?view=powershell-7.3 [05-06-2023]
# Q1.5 = https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.archive/expand-archive?view=powershell-7.3 [05-06-2023]
# Q1.6 = https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.management/remove-item?view=powershell-7.3 [12-06-2023]
# Q1.7 = https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.management/get-childitem?view=powershell-7.3 [19-06-2023]
# Q2.0 = https://chat.openai.com/ [12-06-2023], [19-06-2023], [26-06-2023]