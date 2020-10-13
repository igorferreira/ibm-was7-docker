
#docker container exec -it -e COLUMNS=$COLUMNS -e LINES=$LINES -e TERM=$TERM was7 bash

#Or run as root user:

docker container exec -it -u 0 -e COLUMNS=$COLUMNS -e LINES=$LINES -e TERM=$TERM was70045 bash
cd /opt/IBM/WebSphere/AppServer/bin
wsadmin.sh -lang jython -javaoption "-Dfile.encoding=UTF-8" -f deployConsole.py remove
sleep 10
wsadmin.sh -lang jython -javaoption "-Dfile.encoding=UTF-8" -f deployConsole.py install