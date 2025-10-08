import "dotenv/config";
import express from "express";
import cors from "cors";
import bcrypt from "bcrypt";
import jwt from "jsonwebtoken";

const app = express();
app.use(express.json());

// --- env/config ---
const PORT = Number(process.env.PORT || 3000);
const CORS_ORIGIN = process.env.CORS_ORIGIN?.split(",").map(s => s.trim());
const BCRYPT_ROUNDS = Number(process.env.BCRYPT_ROUNDS || 12);
const JWT_SECRET = process.env.JWT_SECRET ?? "";
if (!JWT_SECRET) throw new Error("Missing JWT_SECRET in .env");

// CORS: lock down origins in production by setting CORS_ORIGIN
app.use(cors({ origin: CORS_ORIGIN || true }));

const users = new Map<string, string>(); // email -> hashed password

app.get("/ping", (_req, res) => res.status(200).send("ok"));

// --- Auth middleware: validates Bearer JWT ---
function auth(req: express.Request, res: express.Response, next: express.NextFunction) {
  const header = req.headers.authorization;
  if (!header?.startsWith("Bearer ")) return res.status(401).send("Missing token");
  const token = header.slice(7);
  try {
    const payload = jwt.verify(token, JWT_SECRET) as jwt.JwtPayload;
    (req as any).user = payload; // attach decoded claims
    next();
  } catch {
    return res.status(401).send("Invalid token");
  }
}

app.post("/signup", async (req, res) => {
  const { email, password } = req.body ?? {};
  if (!email || !password) return res.status(400).send("missing fields");

  const hash = await bcrypt.hash(password, BCRYPT_ROUNDS);
  users.set(String(email).toLowerCase(), hash);
  return res.status(201).send("created");
});

app.post("/login", async (req, res) => {
  const { email, password } = req.body ?? {};
  if (!email || !password) return res.status(400).send("missing fields");

  const storedHash = users.get(String(email).toLowerCase());
  if (!storedHash) return res.status(401).send("invalid credentials");

  const ok = await bcrypt.compare(password, storedHash);
  if (!ok) return res.status(401).send("invalid credentials");

  // generate real JWT
  const token = jwt.sign({ email }, JWT_SECRET, { expiresIn: "1h" });
  return res.status(200).json({ accessToken: token });
});

// --- Authenticated route: /me ---
app.get("/me", auth, (req, res) => {
  const user = (req as any).user as jwt.JwtPayload | undefined;
  const email = user?.email ?? null;
  // For this demo, use email as a stable id
  res.json({ id: email ?? "unknown", email });
});

app.listen(PORT, () => console.log(`Server on http://127.0.0.1:${PORT}`));
