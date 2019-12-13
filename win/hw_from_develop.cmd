set branch=%1
set dir=%2

cd %dir%
git.exe -c "credential.helper=C:/Program\ Files/SmartGit/lib/credentials.cmd" checkout develop
git.exe branch --no-track %branch%
git.exe -c "credential.helper=C:/Program\ Files/SmartGit/lib/credentials.cmd" checkout %branch%
cd d:\jprojects\parcom\pc-root\win
