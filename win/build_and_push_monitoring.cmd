set branch=hw7

echo monitoring
cd D:\jprojects\parcom\pc-root\monitoring

docker image build -f DockerfilePrometheus -t pleshakoff/pc-prometheus:%branch% .
docker image push pleshakoff/pc-prometheus:%branch%

docker image build -f DockerfileGrafana -t pleshakoff/pc-grafana:%branch% .
docker image push pleshakoff/pc-grafana:%branch%


cd d:\jprojects\parcom\pc-root\win
