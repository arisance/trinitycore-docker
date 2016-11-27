# setrna nekonecna smycka, ktera hned skonci na prichozim signalu, takze
# neblokuje docker stop
trap 'exit 0' SIGTERM
while true; do
	sleep 10000 &
	wait $!
done

