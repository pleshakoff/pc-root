set branch=%1
set service=%2

echo %service%
cd d:\jprojects\parcom\%service%\
git.exe -c "credential.helper=C:/Program\ Files/SmartGit/lib/credentials.cmd" checkout master
git.exe -c "credential.helper=C:/Program\ Files/SmartGit/lib/credentials.cmd" merge --no-commit --ff %branch%
cd d:\jprojects\parcom\pc-root\win