@echo off
title Instalador - Copiloto SNP (IA Local) - SEGEPLAN
color 1F
setlocal EnableDelayedExpansion
set KIT=%~dp0
set DEST=%USERPROFILE%\Documents\CopilotoSNP
set LOG=%TEMP%\copiloto_instalacion.log
echo Inicio de instalacion %date% %time% > "%LOG%"
echo Carpeta del kit: %KIT% >> "%LOG%"
echo Destino local: %DEST% >> "%LOG%"

echo.
echo  ==========================================================
echo    COPILOTO SNP - ENTORNO DE IA LOCAL
echo    SEGEPLAN - DFCSNP - I Encuentro Nacional 2026
echo  ==========================================================
echo    Ejecutando desde: %KIT%
echo    Se instalara en:  %DEST%
echo    Registro tecnico: %LOG%
echo  ==========================================================
echo.

echo  [1/7] Verificando requisitos del equipo...
for /f %%A in ('powershell -NoProfile -Command "[math]::Round((Get-CimInstance Win32_ComputerSystem).TotalPhysicalMemory/1GB)"') do set RAMGB=%%A
for /f %%A in ('powershell -NoProfile -Command "[math]::Round((Get-PSDrive -Name $env:SystemDrive.Substring(0,1)).Free/1GB)"') do set LIBREGB=%%A
echo        Memoria RAM: !RAMGB! GB ^| Espacio libre en disco: !LIBREGB! GB
echo RAM=!RAMGB!GB LIBRE=!LIBREGB!GB >> "%LOG%"
if !RAMGB! LSS 8 (
    echo        AVISO: se recomiendan 8 GB de RAM. El modelo puede funcionar lento.
)
if !LIBREGB! LSS 10 (
    echo        ERROR: se necesitan al menos 10 GB libres en disco y hay !LIBREGB! GB.
    echo        Libere espacio y vuelva a ejecutar este instalador.
    echo ERROR: disco insuficiente >> "%LOG%"
    pause
    exit /b 1
)

echo  [2/7] Verificando Ollama...
where ollama >nul 2>&1
if %errorlevel%==0 (
    echo        Ollama ya esta instalado.
    echo Ollama ya instalado >> "%LOG%"
) else (
    if exist "%KIT%1_Instaladores\OllamaSetup.exe" (
        echo        Instalando Ollama en modo silencioso...
        echo        Esto toma 1 a 3 minutos. Si pasan mas de 5 minutos sin avance,
        echo        cierre esta ventana y ejecute manualmente:
        echo        %KIT%1_Instaladores\OllamaSetup.exe
        echo Lanzando OllamaSetup.exe >> "%LOG%"
        start /wait "" "%KIT%1_Instaladores\OllamaSetup.exe" /VERYSILENT /NORESTART /LOG="%TEMP%\ollama_setup.log"
        where ollama >nul 2>&1
        if !errorlevel!==0 (
            echo        Ollama instalado correctamente.
            echo Ollama instalado OK >> "%LOG%"
        ) else (
            echo        AVISO: la instalacion silenciosa no se confirmo.
            echo        Se abrira el instalador en modo normal; siga el asistente.
            echo Instalacion silenciosa fallo, modo visible >> "%LOG%"
            start /wait "" "%KIT%1_Instaladores\OllamaSetup.exe"
        )
    ) else (
        echo        ERROR: falta OllamaSetup.exe en la carpeta 1_Instaladores.
        echo        Verifique que copio el kit COMPLETO, con todas sus carpetas.
        echo ERROR: OllamaSetup.exe no encontrado >> "%LOG%"
        pause
        exit /b 1
    )
)

echo  [3/7] Configurando permisos de comunicacion local...
setx OLLAMA_ORIGINS "*" >nul
echo OLLAMA_ORIGINS configurado >> "%LOG%"

echo  [4/7] Preparando el motor de IA...
taskkill /f /im "ollama app.exe" >nul 2>&1
taskkill /f /im ollama.exe >nul 2>&1

echo  [5/7] Copiando modelos de IA al equipo (2 a 3 GB)...
echo        Vera pasar los archivos; en USB lenta puede tomar 10-15 minutos.
if exist "%KIT%2_Modelos_IA\models" (
    robocopy "%KIT%2_Modelos_IA\models" "%USERPROFILE%\.ollama\models" /E /NJH /NJS /NDL >> "%LOG%"
    if !errorlevel! GEQ 8 (
        echo        ERROR al copiar los modelos. Revise el registro: %LOG%
        pause
        exit /b 1
    )
    echo        Modelos copiados correctamente.
    echo Modelos copiados >> "%LOG%"
) else (
    echo        AVISO: no se encontro 2_Modelos_IA\models en el kit.
    echo        Debera descargar los modelos con internet:
    echo           ollama pull llama3.2:3b
    echo           ollama pull nomic-embed-text
    echo AVISO: carpeta models ausente >> "%LOG%"
)

echo  [6/7] Instalando el Copiloto en este equipo...
robocopy "%KIT%4_Aplicacion" "%DEST%\4_Aplicacion" /E /NJH /NJS /NDL /NFL >> "%LOG%"
if !errorlevel! GEQ 8 (
    echo        ERROR al copiar la aplicacion. Revise el registro: %LOG%
    pause
    exit /b 1
)
if exist "%KIT%3_Corpus_SNP" robocopy "%KIT%3_Corpus_SNP" "%DEST%\3_Corpus_SNP" /E /NJH /NJS /NDL /NFL >> "%LOG%"
if exist "%KIT%5_Documentacion" robocopy "%KIT%5_Documentacion" "%DEST%\5_Documentacion" /E /NJH /NJS /NDL /NFL >> "%LOG%"
if exist "%KIT%LEEME_PRIMERO.html" copy /y "%KIT%LEEME_PRIMERO.html" "%DEST%\" >nul
powershell -NoProfile -Command "$s=(New-Object -ComObject WScript.Shell).CreateShortcut([Environment]::GetFolderPath('Desktop')+'\Copiloto SNP.lnk');$s.TargetPath='%DEST%\4_Aplicacion\Copiloto_SNP.html';if(Test-Path '%DEST%\4_Aplicacion\icono.ico'){$s.IconLocation='%DEST%\4_Aplicacion\icono.ico,0'};$s.Save()" >> "%LOG%" 2>&1
echo        Copiloto instalado en Documentos\CopilotoSNP
echo        Acceso directo creado en el Escritorio.
echo App local + acceso directo listos >> "%LOG%"

echo  [7/7] Iniciando el motor y abriendo el Copiloto...
set OLLAMA_ORIGINS=*
start "MotorIA" /min cmd /c "ollama serve"
timeout /t 5 /nobreak >nul
start "" "%DEST%\4_Aplicacion\Copiloto_SNP.html"
echo Copiloto abierto desde copia local >> "%LOG%"
echo.
echo  ==========================================================
echo    LISTO. Ya puede RETIRAR LA MEMORIA USB con seguridad.
echo.
echo    En la aplicacion:
echo    1. Verifique el indicador VERDE (arriba a la derecha)
echo    2. Pulse "Importar contexto" y elija corpus_vectorizado.json
echo       de la carpeta Documentos\CopilotoSNP\3_Corpus_SNP
echo    3. Formule su primera consulta
echo.
echo    Para usar el Copiloto en adelante: icono "Copiloto SNP"
echo    en su Escritorio.
echo  ==========================================================
echo.
pause
