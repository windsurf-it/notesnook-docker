# check=skip=SecretsUsedInArgOrEnv
# Build Stage
FROM node:22 AS builder

WORKDIR /app

# Install git & cleanup cache
RUN apt-get update && apt-get install -y --no-install-recommends git \
    && rm -rf /var/lib/apt/lists/*

# Clone Notesnook monorepo
# RUN git clone --depth=1 https://github.com/beardedtek/notesnook.git .
RUN git clone --depth=1 https://github.com/streetwriters/notesnook.git .

# Install dependencies (monorepo root)
RUN npm ci

# Patch 1: redirect to /login after logout
RUN node -e "\
const fs = require('fs');\
const path = 'apps/web/src/stores/user-store.ts';\
let content = fs.readFileSync(path, 'utf8');\
content = content.replace(\
  'Config.logout();',\
  'Config.logout();\n  window.location.replace(\"/login\");'\
);\
fs.writeFileSync(path, content);\
console.log('Patch 1 applied: logout -> /login');\
"

# Patch 2: require login before accessing app (auth guard on app init)
# Note: useUserStore is already imported in app-effects.tsx as alias from user-store
RUN node -e "\
const fs = require('fs');\
const path = 'apps/web/src/app-effects.tsx';\
let content = fs.readFileSync(path, 'utf8');\
\
const before = '        await initUser();\n        // await resetNotices();';\
const after  = '        await initUser();\n        if (!useUserStore.getState().isLoggedIn) {\n          window.location.replace(\"/login\");\n          return;\n        }\n        // await resetNotices();';\
\
if (!content.includes(before)) { console.error('Patch 2 FAILED: target string not found'); process.exit(1); }\
\
content = content.replace(before, after);\
fs.writeFileSync(path, content);\
console.log('Patch 2 applied: auth guard -> /login');\
"

# Build with placeholders so URLs can be replaced at runtime
ARG NN_API_HOST=__NN_API_HOST__
ARG NN_AUTH_HOST=__NN_AUTH_HOST__
ARG NN_SSE_HOST=__NN_SSE_HOST__
ARG NN_MONOGRAPH_HOST=__NN_MONOGRAPH_HOST__

ENV NN_API_HOST=${NN_API_HOST}
ENV NN_AUTH_HOST=${NN_AUTH_HOST}
ENV NN_SSE_HOST=${NN_SSE_HOST}
ENV NN_MONOGRAPH_HOST=${NN_MONOGRAPH_HOST}

# Build just the web app
RUN npm run build:web

# Production Stage
FROM nginx

# Remove default nginx site
RUN rm -rf /usr/share/nginx/html/*

# Copy build output from builder
COPY --from=builder /app/apps/web/build /usr/share/nginx/html

# Custom nginx config for SPA
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Startup script สำหรับแทน placeholder ด้วยค่าจริงตอน runtime
COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh

EXPOSE 80
CMD ["/docker-entrypoint.sh"]