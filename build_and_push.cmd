set branch=hw2

echo classroom
cd  d:\jprojects\parcom\pc-classroom\
git -c "credential.helper=C:/Program\ Files/SmartGit/lib/credentials.cmd" checkout %branch%
docker image build -t pleshakoff/pc-classroom:%branch% .
docker image push pleshakoff/pc-classroom:%branch%


echo security
cd  d:\jprojects\parcom\pc-security\
git -c "credential.helper=C:/Program\ Files/SmartGit/lib/credentials.cmd" checkout %branch%
docker image build -t pleshakoff/pc-security:%branch% .
docker image push pleshakoff/pc-security:%branch%

echo notifier
cd  d:\jprojects\parcom\pc-notifier\
git -c "credential.helper=C:/Program\ Files/SmartGit/lib/credentials.cmd" checkout %branch%
docker image build -t pleshakoff/pc-notifier:%branch% .
docker image push pleshakoff/pc-notifier:%branch%