@ECHO OFF
SETLOCAL ENABLEDELAYEDEXPANSION

@REM ===========================================================================
@REM �g�p����Python�̃o�[�W�������w��
@REM ===========================================================================
SET PYTHON_VERSION=3.10.11


@REM ===========================================================================
@REM �����ݒ�
@REM ===========================================================================

@REM ���s�f�B���N�g�����C���X�g�[���f�B���N�g���Ƃ���
SET CURRENT_DIR=%~dp0

@REM Version����C���X�g�[���f�B���N�g�������쐬����
SET VERSION_NAME=%PYTHON_VERSION:.=_%
SET INSTALL_DIR=%CURRENT_DIR%%VERSION_NAME%

@REM �o�[�W�����ԍ��𕪉�����
SET N=0
for %%A in ("%PYTHON_VERSION:.=" "%") do (
   SET VERSIONS[!N!]=%%~A
   SET /A N=N+1
)

@REM ===========================================================================
@REM �C���X�g�[�������J�n
@REM ===========================================================================
SET /P SELECTED="Python %PYTHON_VERSION% �� %CURRENT_DIR% �ɍ\�z���܂��B(Y=YES / N=NO): "
IF /i {%SELECTED%}=={y} (GOTO :INSTALL_PYTHON)
IF /i {%SELECTED%}=={yes} (GOTO :INSTALL_PYTHON)

ECHO Python �̃C���X�g�[���𒆎~���܂��B
GOTO :END_INSTALL_PYTHON

:INSTALL_PYTHON
IF EXIST "%INSTALL_DIR%" (

ECHO "%INSTALL_DIR%" �����݂��邽�߁APython �̃C���X�g�[���𒆎~���܂��B
GOTO END_INSTALL_PYTHON
)


@REM ===========================================================================
@REM Python�̓W�J�c�[�����C���X�g�[��
@REM ===========================================================================

@REM WIX�̃C���X�g�[����p�X
SET WIX_DIR="%CURRENT_DIR%WIX"

@REM WIX�̃_�E�����[�hURL
SET WIX_URL="https://github.com/wixtoolset/wix3/releases/download/wix3112rtm/wix311-binaries.zip"

@REM WIX�̃_�E�����[�h��p�X
SET WIX_ZIP_FILE="%CURRENT_DIR%wix311-binaries.zip"

ECHO Python �̃C���X�g�[���ɕK�v�ȃc�[�����_�E�����[�h���܂��B
ECHO %WIX_URL% �� %WIX_ZIP_FILE% �Ƀ_�E�����[�h���܂��B

@REM Wix�̃_�E�����[�h���������s
powershell -ExecutionPolicy Bypass -command Invoke-WebRequest ""%WIX_URL%"" -OutFile ""%WIX_ZIP_FILE%""

ECHO %WIX_ZIP_FILE% �� %WIX_DIR%�ɓW�J���܂��B

@REM �_�E�����[�h����Wix��W�J
powershell -ExecutionPolicy Bypass -command Expand-Archive -Path ""%WIX_ZIP_FILE%"" -DestinationPath ""%WIX_DIR%""

ECHO %WIX_ZIP_FILE% ���폜���܂��B

@REM �_�E�����[�h����Wix���폜
DEL ""%WIX_ZIP_FILE%""

@REM ===========================================================================
@REM Python���_�E�����[�h
@REM ===========================================================================

@REM Python�̃_�E�����[�hURL
SET PYTHON_URL="https://www.python.org/ftp/python/%PYTHON_VERSION%/python-%PYTHON_VERSION%-amd64.exe"
@REM Python�̃_�E�����[�h��p�X
SET PYTHON_MSI_FILE="%CURRENT_DIR%python-%PYTHON_VERSION%-amd64.exe"

ECHO %PYTHON_URL% �� %PYTHON_MSI_FILE% �Ƀ_�E�����[�h���܂��B

@REM Python�̃_�E�����[�h���������s
powershell -ExecutionPolicy Bypass -command Invoke-WebRequest ""%PYTHON_URL%"" -OutFile ""%PYTHON_MSI_FILE%""

@REM ===========================================================================
@REM Python�C���X�g�[���f�[�^�̓W�J
@REM ===========================================================================

@REM Python�C���X�g�[���f�[�^�̓W�J��p�X
SET PYTHON_EXTRACT_DIR="%CURRENT_DIR%extract"

@REM Python�C���X�g�[���f�[�^�̓W�J�c�[��
SET DARK_EXE="%CURRENT_DIR%WIX\dark.exe"

ECHO %PYTHON_MSI_FILE% �� %PYTHON_EXTRACT_DIR%�ɓW�J���܂�

@REM Python�C���X�g�[���f�[�^�̓W�J
%DARK_EXE% "%PYTHON_MSI_FILE%" -x "%PYTHON_EXTRACT_DIR%"

ECHO �_�E�����[�h���� "%PYTHON_MSI_FILE%" ���폜���܂��B
DEL "%PYTHON_MSI_FILE%"

@REM ===========================================================================
@REM Python �ʃf�[�^�̓W�J
@REM ===========================================================================

@REM Python �ʃf�[�^�̃p�X�擾
SET I=0
FOR %%f IN (%PYTHON_EXTRACT_DIR%\AttachedContainer\*.*) DO (
   SET MSI_FILES[!I!]=%%~ff
   SET /A I=I+1
)

@REM Python �ʃf�[�^�ŗL���Ȃ��̂̂ݏ�������
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

@REM Version����C���X�g�[���f�B���N�g�������쐬����
SET VERSION_NAME=%PYTHON_VERSION:.=_%

SET INSTALL_DIR=%CURRENT_DIR%%VERSION_NAME%

ECHO "!MSI_FILES[%I%]!" �� "%INSTALL_DIR%"�ɓW�J���܂�
@REM Python �ʃf�[�^�ŗL���Ȃ��̂�W�J
msiexec.exe /quiet /a "!MSI_FILES[%I%]!" targetdir="%INSTALL_DIR%"
DEL "%INSTALL_DIR%\%FILENAME%"
:COUNTUP
SET /A I+=1
GOTO LOOP
:ENDLOOP

@REM ===========================================================================
@REM ��ƃf�[�^���폜
@REM ===========================================================================

ECHO %PYTHON_EXTRACT_DIR% ���폜���܂��B
IF EXIST "%PYTHON_EXTRACT_DIR%" RD /S /Q "%PYTHON_EXTRACT_DIR%"

ECHO %WIX_DIR% ���폜���܂��B
IF EXIST "%WIX_DIR%" RD /S /Q "%WIX_DIR%"

@REM ===========================================================================
@REM pip�̃C���X�g�[��
@REM ===========================================================================
ECHO pip ���C���X�g�[�����܂��B
SET PYTHON_EXE="%INSTALL_DIR%\python.exe"

%PYTHON_EXE% -E -s -m ensurepip -U --default-pip

@REM ===========================================================================
@REM venv���̍쐬
@REM ===========================================================================
SET VENV_DIR=%CURRENT_DIR%venv%VERSION_NAME%

ECHO VENV �����쐬���܂��B

%PYTHON_EXE% -m venv %VENV_DIR% --without-pip
CALL %VENV_DIR%\Scripts\activate.bat
python -m ensurepip --upgrade
python -m pip install --upgrade pip

ECHO �Ȍ� Python %PYTHON_VERSION% ���g�p����ꍇ�́A"%VENV_DIR%\Scripts\activate" �����s���Ă��������B
ECHO Python %PYTHON_VERSION% ���C���X�g�[�����܂����B
:END_INSTALL_PYTHON
