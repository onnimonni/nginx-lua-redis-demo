# Few helpers for developing with nginx and lua
start:
	docker-compose up -d
restart:
	docker-compose up --force-recreate -d
reload:
	docker-compose exec nginx openresty -s reload
logs:
	docker-compose logs -f
stop:
	docker-compose stop
	docker-compose rm

test:
	curl -X POST http://127.0.0.1:8080/test/ -d '{ "data": "test" }'
	ab -r -n 1000 -c 100 http://127.0.0.1:8080/test/
	ab -r -n 1000 -c 100 http://127.0.0.1:8081/test/