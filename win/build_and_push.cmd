set branch=%1
set service=%2

echo %service%
cd d:\jprojects\parcom\%service%\
git -c "credential.helper=C:/Program\ Files/SmartGit/lib/credentials.cmd" checkout %branch%
cmd /C gradlew assemble
docker image build -t pleshakoff/%service%:%branch% .
docker image push pleshakoff/%service%:%branch%

cd d:\jprojects\parcom\pc-root\win
