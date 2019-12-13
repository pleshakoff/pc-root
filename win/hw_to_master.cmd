set branch=%1
set dir=%2

cd %dir%
git.exe -c "credential.helper=C:/Program\ Files/SmartGit/lib/credentials.cmd" checkout master
git.exe -c "credential.helper=C:/Program\ Files/SmartGit/lib/credentials.cmd" merge --no-commit --ff %branch%
cd d:\jprojects\parcom\pc-root\win