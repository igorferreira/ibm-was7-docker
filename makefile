build:
	docker image build -t websphere:7.0.0.45 .

run:
	docker run -d -p 8880:8880 -p 9060:9060 -p 9043:9043 -p 9080:9080 --name was70045 websphere:7.0.0.45

enter-root:
	docker container exec -it -u 0 -e COLUMNS=$COLUMNS -e LINES=$LINES -e TERM=$TERM was70045 bash

enter:
	docker container exec -it -e COLUMNS=$COLUMNS -e LINES=$LINES -e TERM=$TERM was70045 bash
