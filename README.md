LibertyServer Overview

LibertyServer is a lightweight Node.js + TypeScript server that provides authentication services for the Liberty Social application. It’s designed to issue and verify secure JSON Web Tokens (JWTs) for user sessions.

Core Functionality
Express API: Uses Express to define HTTP routes for signup, login, and authentication checks.
Password Security: Hashes user passwords with bcrypt, using a configurable number of salt rounds from .env.
Token-Based Auth: Issues a signed JWT on successful login using the jsonwebtoken library and a secure JWT_SECRET from .env.
Protected Routes: Includes an auth middleware that validates the Authorization: Bearer <token> header and rejects invalid or missing tokens.
/signup: Registers new users by hashing passwords and storing them in memory.
/login: Verifies credentials, issues a JWT valid for 1 hour, and returns it to the frontend.
/me: Protected route returning the decoded user info (email, id) if the provided JWT is valid.
CORS Configuration: Controlled via .env (CORS_ORIGIN) to allow requests from approved frontend origins.
Environment Configuration: Uses .env to manage sensitive configuration values securely (JWT secret, port, bcrypt rounds).



Security Practices
Keeps secrets out of source control via .gitignore and .env.
Uses bcrypt for secure password hashing.
Uses HTTPS-compatible JWT signing (HMAC-SHA256).
Rejects expired or malformed tokens.
Configurable CORS origin whitelist.

Current Architecture
LibertyServer/
├── src/
│   └── index.ts         # Main Express app and route logic
├── .env                 # Local secrets (ignored)
├── .env.example         # Public config template
├── .gitignore           # Excludes sensitive & generated files
├── package.json         # Dependencies and scripts
├── tsconfig.json        # TypeScript configuration

In summary

LibertyServer is a secure, minimal authentication API that powers LibertySocial’s login and session management system. It handles user registration, password hashing, JWT issuance, and token validation — forming the backend foundation for user authentication in the Liberty ecosystem.# LibertyServer
Express server backend for LibertySocial app
