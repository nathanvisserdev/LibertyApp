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

// --- Ping ---
app.get("/ping", (_req, res) => res.status(200).send("ok"));

// --- Auth middleware ---
function auth(req: express.Request, res: express.Response, next: express.NextFunction) {
  const header = req.headers.authorization;
  if (!header?.startsWith("Bearer ")) return res.status(401).send("Missing token");
  const token = header.slice(7);
  try {
    const payload = jwt.verify(token, JWT_SECRET) as jwt.JwtPayload;
    (req as any).user = payload;
    next();
  } catch {
    return res.status(401).send("Invalid token");
  }
}

// --- Signup (email + password) ---
app.post("/signup", async (req, res) => {
  const { email, password } = req.body ?? {};
  if (!email || !password) return res.status(400).send("missing required fields");
  try {
    const hash = await bcrypt.hash(String(password), BCRYPT_ROUNDS);
    const user = await prisma.users.create({
      data: { email: String(email).toLowerCase(), password: hash },
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

  const user = await prisma.users.findUnique({ where: { email: String(email).toLowerCase() } });
  if (!user) return res.status(401).send("invalid credentials");

  const ok = await bcrypt.compare(String(password), user.password);
  if (!ok) return res.status(401).send("invalid credentials");

  const token = jwt.sign({ id: user.id, email: user.email }, JWT_SECRET, { expiresIn: "1h" });
  return res.status(200).json({ accessToken: token });
});

// --- Current user ---
app.get("/user", auth, async (req, res) => {
  const payload = (req as any).user as jwt.JwtPayload;
  const user = await prisma.users.findUnique({ where: { id: payload.id } });
  if (!user) return res.status(404).send("User not found");
  res.json(user);
});

// --- Create Post (≤500 chars) ---
app.post("/posts", auth, async (req, res) => {
  const payload = (req as any).user as jwt.JwtPayload;
  const { content, groupId } = req.body ?? {};
  if (!content || String(content).length > 500) return res.status(400).send("Invalid content");
  try {
    const post = await prisma.posts.create({
      data: { userId: payload.id, content: String(content), groupId: groupId ?? null },
    });
    res.json(post);
  } catch (e: any) {
    res.status(400).json({ error: e.message });
  }
});

// --- Get Posts (optionally by group) ---
app.get("/posts", auth, async (req, res) => {
  const groupId = (req.query.groupId as string | undefined) || undefined;
  const posts = await prisma.posts.findMany({
    where: groupId ? { groupId } : undefined,
    include: { user: true, group: true },
    orderBy: { createdAt: "desc" },
  });
  res.json(posts);
});

// --- Groups (create/list) ---
app.post("/groups", auth, async (req, res) => {
  const { name, description, isPrivate } = req.body ?? {};
  if (!name) return res.status(400).send("Missing name");
  const me = (req as any).user as jwt.JwtPayload;
  try {
    const group = await prisma.groups.create({
      data: {
        name: String(name),
        description: description ?? null,
        isPrivate: Boolean(isPrivate ?? false),
        adminId: me.id,
      },
    });
    res.json(group);
  } catch (e: any) {
    res.status(400).json({ error: e.message });
  }
});

app.get("/groups", auth, async (_req, res) => {
  const groups = await prisma.groups.findMany({ include: { admin: true } });
  res.json(groups);
});

// ========== Connections ==========
type ConnectionType = "ACQUAINTANCE" | "STRANGER" | "FOLLOW";

// normalize unordered pair for ACQUAINTANCE/STRANGER
function normalizePair(u1: string, u2: string): [string, string] {
  return u1 < u2 ? [u1, u2] : [u2, u1];
}

// Send a connection request (auto-accept FOLLOW if requested user is public)
app.post("/connections/requests", auth, async (req, res) => {
  const me = (req as any).user.id as string;
  const { requestedId, type } = req.body ?? {};

  if (!requestedId || !type) return res.status(400).send("requestedId and type are required");
  if (!["ACQUAINTANCE", "STRANGER", "FOLLOW"].includes(type))
    return res.status(400).send("invalid type");
  if (me === requestedId) return res.status(400).send("cannot request self");

  // Prevent duplicate pending request
  const dup = await prisma.connectionRequest.findFirst({
    where: { requesterId: me, requestedId, type, status: "PENDING" },
  });
  if (dup) return res.status(409).send("request already pending");

  // Prevent duplicate connection
  let exists = null as any;
  if (type === "FOLLOW") {
    exists = await prisma.connections.findUnique({
      where: { requesterId_requestedId_type: { requesterId: me, requestedId, type } },
    });
  } else {
    const [a, b] = normalizePair(me, requestedId);
    exists = await prisma.connections.findUnique({
      where: { requesterId_requestedId_type: { requesterId: a, requestedId: b, type } },
    });
  }
  if (exists) return res.status(409).send("connection already exists");

  // FOLLOW: check target privacy for auto-accept
  if (type === "FOLLOW") {
    const target = await prisma.users.findUnique({ where: { id: requestedId } });
    if (!target) return res.status(404).send("requested user not found");

    if (target.isPrivateUser === false) {
      // Public user: auto-accept follow
      const conn = await prisma.connections.create({
        data: { requesterId: me, requestedId, type: "FOLLOW" },
      });
      return res.status(201).json({ autoAccepted: true, connection: conn });
    }
    // Private user: fall through to create pending request
  }

  const created = await prisma.connectionRequest.create({
    data: { requesterId: me, requestedId, type },
  });
  return res.status(201).json(created);
});

// List my incoming pending requests
app.get("/connections/requests/incoming", auth, async (req, res) => {
  const me = (req as any).user.id as string;
  const items = await prisma.connectionRequest.findMany({
    where: { requestedId: me, status: "PENDING" },
    include: { requester: true },
    orderBy: { createdAt: "desc" },
  });
  res.json(items);
});

// Accept connection request
app.post("/connections/requests/:id/accept", auth, async (req, res) => {
  const me = (req as any).user.id as string;
  const cr = await prisma.connectionRequest.findUnique({ where: { id: req.params.id } });
  if (!cr || cr.requestedId !== me || cr.status !== "PENDING")
    return res.status(400).send("invalid");

  const type = cr.type as ConnectionType;
  const [a, b] =
    type === "FOLLOW"
      ? [cr.requesterId, cr.requestedId] // directed
      : cr.requesterId < cr.requestedId
      ? [cr.requesterId, cr.requestedId]
      : [cr.requestedId, cr.requesterId];

  const conn = await prisma.connections.create({
    data: { requesterId: a, requestedId: b, type },
  });
  await prisma.connectionRequest.update({
    where: { id: cr.id },
    data: { status: "ACCEPTED", decidedAt: new Date() },
  });

  res.json(conn);
});

// Lists
app.get("/connections/acquaintances", auth, async (req, res) => {
  const me = (req as any).user.id as string;
  const rows = await prisma.connections.findMany({
    where: { type: "ACQUAINTANCE", OR: [{ requesterId: me }, { requestedId: me }] },
    select: { requesterId: true, requestedId: true },
  });
  const ids = rows.map(r => (r.requesterId === me ? r.requestedId : r.requesterId));
  res.json({ acquaintances: ids });
});

app.get("/connections/strangers", auth, async (req, res) => {
  const me = (req as any).user.id as string;
  const rows = await prisma.connections.findMany({
    where: { type: "STRANGER", OR: [{ requesterId: me }, { requestedId: me }] },
    select: { requesterId: true, requestedId: true },
  });
  const ids = rows.map(r => (r.requesterId === me ? r.requestedId : r.requesterId));
  res.json({ strangers: ids });
});

app.get("/connections/following", auth, async (req, res) => {
  const me = (req as any).user.id as string;
  const rows = await prisma.connections.findMany({
    where: { type: "FOLLOW", requesterId: me },
    select: { requestedId: true },
  });
  res.json({ following: rows.map(r => r.requestedId) });
});

app.get("/connections/followers", auth, async (req, res) => {
  const me = (req as any).user.id as string;
  const rows = await prisma.connections.findMany({
    where: { type: "FOLLOW", requestedId: me },
    select: { requesterId: true },
  });
  res.json({ followers: rows.map(r => r.requesterId) });
});

// Combined
app.get("/connections", auth, async (req, res) => {
  const me = (req as any).user.id as string;
  const [acq, str, fol, folw] = await Promise.all([
    prisma.connections.findMany({
      where: { type: "ACQUAINTANCE", OR: [{ requesterId: me }, { requestedId: me }] },
      select: { requesterId: true, requestedId: true },
    }),
    prisma.connections.findMany({
      where: { type: "STRANGER", OR: [{ requesterId: me }, { requestedId: me }] },
      select: { requesterId: true, requestedId: true },
    }),
    prisma.connections.findMany({
      where: { type: "FOLLOW", requesterId: me },
      select: { requestedId: true },
    }),
    prisma.connections.findMany({
      where: { type: "FOLLOW", requestedId: me },
      select: { requesterId: true },
    }),
  ]);

  const acquaintances = acq.map(r => (r.requesterId === me ? r.requestedId : r.requesterId));
  const strangers     = str.map(r => (r.requesterId === me ? r.requestedId : r.requesterId));
  const following     = fol.map(r => r.requestedId);
  const followers     = folw.map(r => r.requesterId);
  const connections   = Array.from(new Set([...acquaintances, ...strangers, ...following, ...followers]));

  res.json({ acquaintances, strangers, following, followers, connections });
});

// --- Feed (SELF + acquaintances + strangers + following) ---
app.get("/feed", auth, async (req, res) => {
  const me = (req as any).user.id as string;

  const [undirected, following] = await Promise.all([
    prisma.connections.findMany({
      where: {
        type: { in: ["ACQUAINTANCE", "STRANGER"] },
        OR: [{ requesterId: me }, { requestedId: me }],
      },
      select: { requesterId: true, requestedId: true, type: true },
    }),
    prisma.connections.findMany({
      where: { type: "FOLLOW", requesterId: me },
      select: { requestedId: true },
    }),
  ]);

  const acquaintances = new Set<string>();
  const strangers     = new Set<string>();
  for (const r of undirected) {
    const other = r.requesterId === me ? r.requestedId : r.requesterId;
    (r.type === "ACQUAINTANCE" ? acquaintances : strangers).add(other);
  }
  const followingIds = new Set(following.map(r => r.requestedId));

  const authorIds = Array.from(new Set([me, ...acquaintances, ...strangers, ...followingIds]));

  const posts = await prisma.posts.findMany({
    where: { userId: { in: authorIds } },
    orderBy: { createdAt: "desc" },
    include: { user: true },
    take: 50,
  });

  const toRelation = (authorId: string) =>
    authorId === me
      ? "SELF"
      : acquaintances.has(authorId)
      ? "ACQUAINTANCE"
      : strangers.has(authorId)
      ? "STRANGER"
      : followingIds.has(authorId)
      ? "FOLLOWING"
      : "NONE";

  res.json(
    posts.map(p => ({
      id: p.id,
      userId: p.userId,
      content: p.content,
      createdAt: p.createdAt,
      user: { id: p.user.id, email: p.user.email },
      relation: toRelation(p.userId),
    }))
  );
});

// --- Privacy toggle (make myself public/private) ---
app.post("/privacy/me", auth, async (req, res) => {
  const me = (req as any).user.id as string;
  const { isPrivateUser } = req.body ?? {};
  if (typeof isPrivateUser !== "boolean") return res.status(400).send("isPrivateUser must be boolean");
  try {
    const u = await prisma.users.update({
      where: { id: me },
      data: { isPrivateUser },
    });
    res.json({ id: u.id, isPrivateUser: u.isPrivateUser });
  } catch (e: any) {
    res.status(400).json({ error: e.message });
  }
});

// --- Start server ---
app.listen(PORT, () => console.log(`Server on http://127.0.0.1:${PORT}`));
