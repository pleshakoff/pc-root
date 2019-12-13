set branch=%1
set dir=%2

cd %dir%
git -c "credential.helper=C:/Program\ Files/SmartGit/lib/credentials.cmd" checkout %branch%
docker image build -t pleshakoff/pc-classroom:%branch% .
docker image push pleshakoff/pc-classroom:%branch%

cd d:\jprojects\parcom\pc-root\win
