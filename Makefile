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

test_php: reset
	# Populate redis and warm up php+nginx
	curl -X POST http://127.0.0.1:8080/test/ -d '{ "data": "12345" }'
	curl -X GET http://127.0.0.1:8080/test/

	siege --concurrent=200 --time=10s --benchmark http://localhost:8080/test/

test_lua: reset
	# Populate redis and warm up php+nginx
	curl -X POST http://127.0.0.1:8081/test/ -d '{ "data": "12345" }'
	curl -X GET http://127.0.0.1:8081/test/

	siege --concurrent=200 --time=10s --benchmark http://localhost:8081/test/

reset:
	docker-compose stop; docker-compose rm -f; docker-compose up -d
	sleep 1