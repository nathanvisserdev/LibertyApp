import "dotenv/config";
import express from "express";
import cors from "cors";
import bcrypt from "bcrypt";
import jwt from "jsonwebtoken";
import { PrismaClient } from "./generated/prisma";

const app = express();
const prisma = new PrismaClient();
app.use(express.json());

// --- Environment ---
const PORT = Number(process.env.PORT || 3000);
const CORS_ORIGIN = process.env.CORS_ORIGIN?.split(",").map(s => s.trim());
const BCRYPT_ROUNDS = Number(process.env.BCRYPT_ROUNDS || 12);
const JWT_SECRET = process.env.JWT_SECRET ?? "";
if (!JWT_SECRET) throw new Error("Missing JWT_SECRET in .env");

// --- CORS ---
app.use(cors({ origin: CORS_ORIGIN || true }));

// --- Ping route ---
app.get("/ping", (_req, res) => res.status(200).send("ok"));

// --- Auth middleware ---
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

// --- Signup ---
app.post("/signup", async (req, res) => {
  const { firstName, lastName, email, username, password, dateOfBirth, gender } = req.body ?? {};
  if (!email || !password || !username || !firstName || !lastName || !dateOfBirth)
    return res.status(400).send("missing required fields");

  try {
    const hash = await bcrypt.hash(password, BCRYPT_ROUNDS);
    const user = await prisma.user.create({
      data: {
        firstName,
        lastName,
        email: email.toLowerCase(),
        username: username.toLowerCase(),
        password: hash,
        dateOfBirth: new Date(dateOfBirth),
        gender: Boolean(gender),
      },
    });
    res.status(201).json({ id: user.id, email: user.email });
  } catch (err: any) {
    res.status(400).json({ error: err.message });
  }
});

// --- Login ---
app.post("/login", async (req, res) => {
  const { email, password } = req.body ?? {};
  if (!email || !password) return res.status(400).send("missing fields");

  const user = await prisma.user.findUnique({ where: { email: email.toLowerCase() } });
  if (!user) return res.status(401).send("invalid credentials");

  const ok = await bcrypt.compare(password, user.password);
  if (!ok) return res.status(401).send("invalid credentials");

  const token = jwt.sign({ id: user.id, email: user.email }, JWT_SECRET, { expiresIn: "1h" });
  return res.status(200).json({ accessToken: token });
});

// --- Authenticated user info ---
app.get("/me", auth, async (req, res) => {
  const payload = (req as any).user as jwt.JwtPayload;
  const user = await prisma.user.findUnique({ where: { id: payload.id } });
  if (!user) return res.status(404).send("User not found");
  res.json(user);
});

// --- User list ---
app.get("/users", async (_req, res) => {
  const users = await prisma.user.findMany();
  res.json(users);
});

// --- Create Group ---
app.post("/groups", auth, async (req, res) => {
  const { name, description } = req.body;
  if (!name) return res.status(400).send("Missing name");
  try {
    const group = await prisma.group.create({ data: { name, description } });
    res.json(group);
  } catch (e: any) {
    res.status(400).json({ error: e.message });
  }
});

// --- List Groups ---
app.get("/groups", async (_req, res) => {
  const groups = await prisma.group.findMany();
  res.json(groups);
});

// --- Join Group ---
app.post("/groups/:groupId/join", auth, async (req, res) => {
  const payload = (req as any).user as jwt.JwtPayload;
  const { groupId } = req.params;
  try {
    const membership = await prisma.membership.create({
      data: { userId: payload.id, groupId },
    });
    res.json(membership);
  } catch (e: any) {
    res.status(400).json({ error: e.message });
  }
});

// --- Create Post ---
app.post("/posts", auth, async (req, res) => {
  const payload = (req as any).user as jwt.JwtPayload;
  const { groupId, content } = req.body;
  if (!groupId || !content) return res.status(400).send("Missing fields");
  try {
    const post = await prisma.post.create({
      data: { userId: payload.id, groupId, content },
    });
    res.json(post);
  } catch (e: any) {
    res.status(400).json({ error: e.message });
  }
});

// --- Get Posts ---
app.get("/posts", auth, async (req, res) => {
  const groupId = req.query.groupId as string | undefined;
  const posts = await prisma.post.findMany({
    where: groupId ? { groupId } : undefined,
    include: { user: true, group: true },
    orderBy: { createdAt: "desc" },
  });
  res.json(posts);
});

// --- Start server ---
app.listen(PORT, () => console.log(`Server on http://127.0.0.1:${PORT}`));
