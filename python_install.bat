@ECHO OFF
SETLOCAL ENABLEDELAYEDEXPANSION

@REM ===========================================================================
@REM 使用するPythonのバージョンを指定
@REM ===========================================================================
SET PYTHON_VERSION=3.10.11


@REM ===========================================================================
@REM 初期設定
@REM ===========================================================================

@REM 実行ディレクトリをインストールディレクトリとする
SET CURRENT_DIR=%~dp0

@REM Versionからインストールディレクトリ名を作成する
SET VERSION_NAME=%PYTHON_VERSION:.=_%
SET INSTALL_DIR=%CURRENT_DIR%%VERSION_NAME%

@REM バージョン番号を分解する
SET N=0
for %%A in ("%PYTHON_VERSION:.=" "%") do (
   SET VERSIONS[!N!]=%%~A
   SET /A N=N+1
)

@REM ===========================================================================
@REM インストール処理開始
@REM ===========================================================================
SET /P SELECTED="Python %PYTHON_VERSION% を %CURRENT_DIR% に構築します。(Y=YES / N=NO): "
IF /i {%SELECTED%}=={y} (GOTO :INSTALL_PYTHON)
IF /i {%SELECTED%}=={yes} (GOTO :INSTALL_PYTHON)

ECHO Python のインストールを中止します。
GOTO :END_INSTALL_PYTHON

:INSTALL_PYTHON
IF EXIST "%INSTALL_DIR%" (

ECHO "%INSTALL_DIR%" が存在するため、Python のインストールを中止します。
GOTO END_INSTALL_PYTHON
)


@REM ===========================================================================
@REM Pythonの展開ツールをインストール
@REM ===========================================================================

@REM WIXのインストール先パス
SET WIX_DIR="%CURRENT_DIR%WIX"

@REM WIXのダウンロードURL
SET WIX_URL="https://github.com/wixtoolset/wix3/releases/download/wix3112rtm/wix311-binaries.zip"

@REM WIXのダウンロード先パス
SET WIX_ZIP_FILE="%CURRENT_DIR%wix311-binaries.zip"

ECHO Python のインストールに必要なツールをダウンロードします。
ECHO %WIX_URL% を %WIX_ZIP_FILE% にダウンロードします。

@REM Wixのダウンロード処理を実行
powershell -ExecutionPolicy Bypass -command Invoke-WebRequest ""%WIX_URL%"" -OutFile ""%WIX_ZIP_FILE%""

ECHO %WIX_ZIP_FILE% を %WIX_DIR%に展開します。

@REM ダウンロードしたWixを展開
powershell -ExecutionPolicy Bypass -command Expand-Archive -Path ""%WIX_ZIP_FILE%"" -DestinationPath ""%WIX_DIR%""

ECHO %WIX_ZIP_FILE% を削除します。

@REM ダウンロードしたWixを削除
DEL ""%WIX_ZIP_FILE%""

@REM ===========================================================================
@REM Pythonをダウンロード
@REM ===========================================================================

@REM PythonのダウンロードURL
SET PYTHON_URL="https://www.python.org/ftp/python/%PYTHON_VERSION%/python-%PYTHON_VERSION%-amd64.exe"
@REM Pythonのダウンロード先パス
SET PYTHON_MSI_FILE="%CURRENT_DIR%python-%PYTHON_VERSION%-amd64.exe"

ECHO %PYTHON_URL% を %PYTHON_MSI_FILE% にダウンロードします。

@REM Pythonのダウンロード処理を実行
powershell -ExecutionPolicy Bypass -command Invoke-WebRequest ""%PYTHON_URL%"" -OutFile ""%PYTHON_MSI_FILE%""

@REM ===========================================================================
@REM Pythonインストールデータの展開
@REM ===========================================================================

@REM Pythonインストールデータの展開先パス
SET PYTHON_EXTRACT_DIR="%CURRENT_DIR%extract"

@REM Pythonインストールデータの展開ツール
SET DARK_EXE="%CURRENT_DIR%WIX\dark.exe"

ECHO %PYTHON_MSI_FILE% を %PYTHON_EXTRACT_DIR%に展開します

@REM Pythonインストールデータの展開
%DARK_EXE% "%PYTHON_MSI_FILE%" -x "%PYTHON_EXTRACT_DIR%"

ECHO ダウンロードした "%PYTHON_MSI_FILE%" を削除します。
DEL "%PYTHON_MSI_FILE%"

@REM ===========================================================================
@REM Python 個別データの展開
@REM ===========================================================================

@REM Python 個別データのパス取得
SET I=0
FOR %%f IN (%PYTHON_EXTRACT_DIR%\AttachedContainer\*.*) DO (
   SET MSI_FILES[!I!]=%%~ff
   SET /A I=I+1
)

@REM Python 個別データで有効なもののみ処理する
SET I=0
:LOOP
IF NOT DEFINED MSI_FILES[%I%] GOTO ENDLOOP

FOR %%J in ("!MSI_FILES[%I%]!") do set FILENAME=%%~nxJ

IF "%FILENAME%"=="appendpath.msi" (
GOTO COUNTUP
) ELSE IF "%FILENAME%"=="launcher.msi" (
GOTO COUNTUP
) ELSE IF "%FILENAME%"=="path.msi" (
GOTO COUNTUP
) ELSE IF "%FILENAME%"=="pip.msi" (
GOTO COUNTUP
) ELSE IF "%FILENAME%"=="py.exe" (
GOTO COUNTUP
) 

@REM Versionからインストールディレクトリ名を作成する
SET VERSION_NAME=%PYTHON_VERSION:.=_%

SET INSTALL_DIR=%CURRENT_DIR%%VERSION_NAME%

ECHO "!MSI_FILES[%I%]!" を "%INSTALL_DIR%"に展開します
@REM Python 個別データで有効なものを展開
msiexec.exe /quiet /a "!MSI_FILES[%I%]!" targetdir="%INSTALL_DIR%"
DEL "%INSTALL_DIR%\%FILENAME%"
:COUNTUP
SET /A I+=1
GOTO LOOP
:ENDLOOP

@REM ===========================================================================
@REM 作業データを削除
@REM ===========================================================================

ECHO %PYTHON_EXTRACT_DIR% を削除します。
IF EXIST "%PYTHON_EXTRACT_DIR%" RD /S /Q "%PYTHON_EXTRACT_DIR%"

ECHO %WIX_DIR% を削除します。
IF EXIST "%WIX_DIR%" RD /S /Q "%WIX_DIR%"

@REM ===========================================================================
@REM pipのインストール
@REM ===========================================================================
ECHO pip をインストールします。
SET PYTHON_EXE="%INSTALL_DIR%\python.exe"

%PYTHON_EXE% -E -s -m ensurepip -U --default-pip

@REM ===========================================================================
@REM venv環境の作成
@REM ===========================================================================
SET VENV_DIR=%CURRENT_DIR%venv%VERSION_NAME%

ECHO VENV 環境を作成します。

%PYTHON_EXE% -m venv %VENV_DIR% --without-pip
CALL %VENV_DIR%\Scripts\activate.bat
python -m ensurepip --upgrade
python -m pip install --upgrade pip

ECHO 以後 Python %PYTHON_VERSION% を使用する場合は、"%VENV_DIR%\Scripts\activate" を実行してください。
ECHO Python %PYTHON_VERSION% をインストールしました。
:END_INSTALL_PYTHON
