# Tickets Alert

#### Fill the environment file: ####
```
cp .env.to_compile .env
```

#### Run application locally: ####
```
docker-compose down --volumes && docker-compose run --service-ports api bash
```
```
./script/run_dev.sh
```

#### Run tests: ####
```
docker-compose down --volumes && docker-compose run --service-ports api bash
```
```
./script/run_dev_test.sh
```

#### Run tests (with coverage): ####
```
docker-compose down --volumes && docker-compose run --service-ports api bash
```
```
./script/run_dev_test_with_coverage.sh
```

#### Run application in production: ####
```
docker-compose down && docker-compose run -d --service-ports api "run_prod"
```

#### Enter to running application process: ####
```
ps -aux | more -20
```