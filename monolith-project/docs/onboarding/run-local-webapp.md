# Run Local Webapp (with Backend/API tests)

## Prereqs
- Node 20+
- npm
- Docker (optional for DB alternatives)

```bash
cd ~/Desktop/platform-portfolio/apps/webapp
npm install
1) Unit tests
bash

npm run test:unit
2) UI tests
Playwright should own server startup through playwright.config.* webServer.
Do not manually run npm start & in parallel with npm run test:ui.

bash

npm run test:ui
3) Run app locally
bash

npm start
Default URL:

http://127.0.0.1:3000
4) Health and API checks
bash

curl -i http://127.0.0.1:3000/health
curl -i http://127.0.0.1:3000/api/messages
curl -i -X POST http://127.0.0.1:3000/api/messages \
  -H "Content-Type: application/json" \
  -d '{"content":"local test message"}'
curl -i http://127.0.0.1:3000/api/messages
5) DB wiring for local backend tests
The app requires:

DB_HOST
DB_USER
DB_PASSWORD
DB_NAME
Example:

bash

export DB_HOST=127.0.0.1
export DB_USER=appadmin
export DB_PASSWORD=changeme
export DB_NAME=appdb
npm start
If DB vars are missing, API returns:

503 {"error":"Database is not configured"}
If DB is unreachable, API returns:

503 {"error":"connect ETIMEDOUT"}
