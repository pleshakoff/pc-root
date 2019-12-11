
echo root
cd  d:\jprojects\parcom\pc-root\
git.exe -c "credential.helper=C:/Program\ Files/SmartGit/lib/credentials.cmd" checkout develop
git.exe -c "credential.helper=C:/Program\ Files/SmartGit/lib/credentials.cmd" merge --no-commit --ff master

echo classroom
cd  d:\jprojects\parcom\pc-classroom\
git.exe -c "credential.helper=C:/Program\ Files/SmartGit/lib/credentials.cmd" checkout develop
git.exe -c "credential.helper=C:/Program\ Files/SmartGit/lib/credentials.cmd" merge --no-commit --ff master

echo security
cd  d:\jprojects\parcom\pc-security\
git.exe -c "credential.helper=C:/Program\ Files/SmartGit/lib/credentials.cmd" checkout develop
git.exe -c "credential.helper=C:/Program\ Files/SmartGit/lib/credentials.cmd" merge --no-commit --ff master

echo notifier
cd  d:\jprojects\parcom\pc-notifier\
git.exe -c "credential.helper=C:/Program\ Files/SmartGit/lib/credentials.cmd" checkout develop
git.exe -c "credential.helper=C:/Program\ Files/SmartGit/lib/credentials.cmd" merge --no-commit --ff master

echo pc-notifier-agent-email
cd  d:\jprojects\parcom\pc-notifier-agent-email\
git.exe -c "credential.helper=C:/Program\ Files/SmartGit/lib/credentials.cmd" checkout develop
git.exe -c "credential.helper=C:/Program\ Files/SmartGit/lib/credentials.cmd" merge --no-commit --ff master

echo pc-notifier-agent-push
cd  d:\jprojects\parcom\pc-notifier-agent-push\
git.exe -c "credential.helper=C:/Program\ Files/SmartGit/lib/credentials.cmd" checkout develop
git.exe -c "credential.helper=C:/Program\ Files/SmartGit/lib/credentials.cmd" merge --no-commit --ff master


cd d:\jprojects\parcom\pc-root\win