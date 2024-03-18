@ECHO OFF
SETLOCAL
CD %~dp0
IF NOT EXIST cygwin-setup.exe (
	ECHO cygwin-setup.exe NOT found! Downloading installer...
	bitsadmin /transfer cygwinDownloadJob /download /priority normal https://cygwin.com/setup-x86_64.exe %CD%\\cygwin-setup.exe
) ELSE ( ECHO cygwin-setup.exe found! Skipping installer download...)

SET SITE=https://mirror.clarkson.edu/cygwin/
SET LOCALDIR=%CD%
SET ROOTDIR=C:/cygwin

REM -- These are the packages we will install (in addition to the default packages)
SET PACKAGES=mintty,wget,ctags,diffutils,git,git-completion,rsync

ECHO *** INSTALLING DEFAULT PACKAGES
cygwin-setup --quiet-mode --no-desktop --download --local-install --no-verify -s %SITE% -l "%LOCALDIR%" -R "%ROOTDIR%"
ECHO *** INSTALLING CUSTOM PACKAGES
cygwin-setup -q -d -D -L -X -s %SITE% -l "%LOCALDIR%" -R "%ROOTDIR%" -P %PACKAGES%

REM -- Append to the global path
SETX /M path "%PATH%;%ROOTDIR%\bin"

ENDLOCAL

PAUSE
EXIT /B 0
