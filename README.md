# Tickets Alert

## LOCAL ##
#### run application: ####
```
docker-compose down --volumes && docker-compose run --service-ports app bash
```
```
./script/run_dev.sh
```

#### run tests: ####
```
docker-compose down --volumes && docker-compose run --service-ports app bash
```
```
./script/run_dev_test.sh
```

#### run tests (with coverage): ####
```
docker-compose down --volumes && docker-compose run --service-ports app bash
```
```
./script/run_dev_test_with_coverage.sh
```
## PRODUCTION ##
#### fill the environment file with real data: ####
```
vim ./app/.env
```

#### run application in production: ####
```
docker-compose down && docker-compose run -d --service-ports app "run_prod"
```


## HELPER ##
#### enter to running application process: ####
```
ps -aux | more -20
```

#### enter to redis db: ####
```
docker exec -it ${redis_container_id} sh
```

```
redis-cli
```

```
SELECT 1
```

```
KEYS *
```

```
GET ${key}
```

```
TTL ${key}
```

```
FLUSHDB
```