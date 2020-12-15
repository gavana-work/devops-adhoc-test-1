###########
#CLEANUP
###########

echo
echo
echo "[removing previous image build]"
echo
echo "[<none>]"
docker image rm $(docker images | grep "<none>" | awk '{print $3}') --force
echo "[app]"
docker image rm $(docker images | grep containerize_nginx | awk '{print $3}') --force

###########
#BUILD
###########

echo
echo
echo "[building new image]"
echo
docker build -t containerize_nginx .