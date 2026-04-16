# Webapp

Simple Node.js web application used for CI/CD, Docker image build, and GitOps deployment.

## Endpoints

- `/` HTML status page
- `/health` health check endpoint
- `/version` deployed application version (from `APP_VERSION`)
- `/api/backend` backend status including DB connectivity
- `/api/messages` list messages from MySQL (GET)
- `/api/messages` create message in MySQL (POST)

## Database Environment Variables

- `DB_HOST`
- `DB_PORT` (default: `3306`)
- `DB_NAME`
- `DB_USER`
- `DB_PASSWORD`

If DB variables are not provided, the app still runs and reports DB as unconfigured.

## Local run

```bash
npm install
npm start
```

## Tests

```bash
npm run test:unit
npm run test:ui
```

## Docker build

```bash
docker build --build-arg GIT_SHA=local-dev -t project1-webapp:local .
```
