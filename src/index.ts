import "dotenv/config";
import express from "express";
import cors from "cors";
import bcrypt from "bcrypt";
import jwt from "jsonwebtoken";
import { PrismaClient, GroupType, PostVisibility } from "./generated/prisma";

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

// --- Helpers ---
async function isBlockedBetween(a: string, b: string) {
  const hit = await prisma.blocks.findFirst({
    where: { OR: [{ blockerId: a, blockedId: b }, { blockerId: b, blockedId: a }] },
    select: { blockerId: true },
  });
  return !!hit;
}

// (kept for future use; returns PERSONAL group id if present)
async function userSocialCircleGroupId(userId: string) {
  const g = await prisma.groups.findFirst({
    where: { adminId: userId, groupType: "PERSONAL" },
    select: { id: true },
  });
  return g?.id ?? null;
}

// Public feed predicate: visibility PUBLIC and (no group OR group is PUBLIC)
const publicFeedWhere = () => ({
  visibility: PostVisibility.PUBLIC,
  OR: [{ groupId: null }, { group: { groupType: GroupType.PUBLIC } }],
});

// --- Signup (email + password) ---
app.post("/signup", async (req, res) => {
  const { email, password } = req.body ?? {};
  if (!email || !password) return res.status(400).send("missing required fields");
  try {
    const hash = await bcrypt.hash(String(password), BCRYPT_ROUNDS);
    const user = await prisma.users.create({
      data: { email: String(email).toLowerCase(), password: hash },
    });

    // Ensure exactly one PERSONAL group per user (Social Circle)
    await prisma.groups.create({
      data: {
        name: "Social Circle",
        description: "Your personal group",
        groupType: "PERSONAL",
        adminId: user.id,
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

  const user = await prisma.users.findUnique({ where: { email: String(email).toLowerCase() } });
  if (!user) return res.status(401).send("invalid credentials");

  const ok = await bcrypt.compare(String(password), user.password);
  if (!ok) return res.status(401).send("invalid credentials");

  if (user.isBanned) return res.status(403).send("account banned");

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

// --- Block / Unblock ---
app.post("/block", auth, async (req, res) => {
  const me = (req as any).user.id as string;
  const { userId } = req.body ?? {};
  if (!userId || userId === me) return res.status(400).send("invalid target");
  await prisma.blocks.upsert({
    where: { blockerId_blockedId: { blockerId: me, blockedId: userId } },
    update: {},
    create: { blockerId: me, blockedId: userId },
  });
  res.sendStatus(204);
});

app.post("/unblock", auth, async (req, res) => {
  const me = (req as any).user.id as string;
  const { userId } = req.body ?? {};
  if (!userId || userId === me) return res.status(400).send("invalid target");
  await prisma.blocks.deleteMany({ where: { blockerId: me, blockedId: userId } });
  res.sendStatus(204);
});

// --- Create Post (≤500 chars) for Public Feed (auth required, no group) ---
app.post("/posts", auth, async (req, res) => {
  const me = (req as any).user as jwt.JwtPayload; // comes from verified JWT
  const { content } = req.body ?? {};

  if (!content || String(content).trim().length === 0 || String(content).length > 500) {
    return res.status(400).send("Invalid content");
  }

  try {
    const post = await prisma.posts.create({
      data: {
        userId: me.id,               // linked to authenticated user
        content: String(content),    // sanitized content
        // no groupId -> public feed
      },
    });

    // secure, consistent JSON response
    res.status(201).json({
      id: post.id,
      content: post.content,
      createdAt: post.createdAt,
      userId: post.userId,
    });
  } catch (e: any) {
    console.error(e);
    res.status(400).json({ error: e.message });
  }
});





// --- Get Posts (optionally by group) with block filtering ---
app.get("/posts", auth, async (req, res) => {
  const me = (req as any).user.id as string;
  const groupId = (req.query.groupId as string | undefined) || undefined;

  // Block set (both directions)
  const [iBlocked, blockedMe] = await Promise.all([
    prisma.blocks.findMany({ where: { blockerId: me }, select: { blockedId: true } }),
    prisma.blocks.findMany({ where: { blockedId: me }, select: { blockerId: true } }),
  ]);
  const blocked = new Set<string>([
    ...iBlocked.map(b => b.blockedId),
    ...blockedMe.map(b => b.blockerId),
  ]);

  // Optional group visibility gating
  let groupWhere: any = undefined;
  if (groupId) {
    const g = await prisma.groups.findUnique({ where: { id: groupId } });
    if (!g) return res.status(404).send("group not found");

    if (g.groupType === "PERSONAL") {
      if (g.adminId !== me) return res.sendStatus(404);
    } else if (g.groupType === "PRIVATE") {
      const member = await prisma.groupRoster.findUnique({
        where: { userId_groupId: { userId: me, groupId } },
      });
      if (!member) return res.sendStatus(403);
    }
    groupWhere = { groupId };
  }

  const posts = await prisma.posts.findMany({
    where: {
      ...groupWhere,
      userId: { notIn: Array.from(blocked) },
    },
    include: { user: true, group: true },
    orderBy: { createdAt: "desc" },
    take: 50,
  });

  res.json(posts);
});

// --- Public Square feed (derived; no auth required) ---
app.get("/feed/public-square", async (req, res) => {
  try {
    const take = Math.min(Number(req.query.take) || 30, 100);
    const cursor = req.query.cursor ? String(req.query.cursor) : undefined;

    const items = await prisma.posts.findMany({
      where: publicFeedWhere(),
      include: { user: true, group: true },
      orderBy: { createdAt: "desc" },
      take,
      ...(cursor ? { skip: 1, cursor: { id: cursor } } : {}),
    });

    res.json({
      items,
      nextCursor: items.length === take ? items[items.length - 1].id : null,
    });
  } catch (e) {
    res.status(500).json({ error: "public-square-failed" });
  }
});

// --- Groups (create/list) ---
app.post("/groups", auth, async (req, res) => {
  const { name, description, groupType } = req.body ?? {};
  if (!name) return res.status(400).send("Missing name");

  const me = (req as any).user as jwt.JwtPayload;

  // Only allow PUBLIC or PRIVATE for assembly rooms
  const allowed = ["PUBLIC", "PRIVATE"];
  if (!allowed.includes(String(groupType)?.toUpperCase()))
    return res.status(400).send("groupType must be PUBLIC or PRIVATE");

  try {
    const group = await prisma.groups.create({
      data: {
        name: String(name),
        description: description ?? null,
        groupType: String(groupType).toUpperCase() as GroupType,
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
  res.json(
    groups.map(g => {
      if (g.groupType === "PUBLIC")
        return { ...g, displayLabel: `${g.name} public assembly room` };
      if (g.groupType === "PRIVATE")
      return { ...g, displayLabel: `${g.name} private assembly room` };
      // PERSONAL unchanged
      return { ...g, displayLabel: "Social Circle" };
    })
  );
});

// --- Access a room (no room for PERSONAL) ---
app.get("/groups/:id/room", auth, async (req, res) => {
  const me = (req as any).user.id as string;
  const g = await prisma.groups.findUnique({ where: { id: req.params.id } });
  if (!g) return res.sendStatus(404);

  if (g.groupType === "PERSONAL") return res.status(404).send("no room for social circle");
  if (g.groupType === "PRIVATE") {
    const member = await prisma.groupRoster.findUnique({
      where: { userId_groupId: { userId: me, groupId: g.id } },
    });
    if (!member) return res.sendStatus(403);
  }
  res.json({
    id: g.id,
    forumName:
      g.groupType === "PUBLIC"
        ? `${g.name} public assembly room`
        : `${g.name} private assembly room`,
  });
});

// --- Delete user (protect and clean) ---
app.delete("/user", auth, async (req, res) => {
  const me = (req as any).user.id as string;
  const force = String(req.query.force || "").toLowerCase() === "true";

  const adminGroups = await prisma.groups.findMany({
    where: { adminId: me },
    select: { id: true, groupType: true },
  });

  if (adminGroups.length && !force) {
    return res.status(409).json({
      error: "user_is_group_admin",
      message: "User administers groups. Reassign or call with ?force=true to delete them.",
    });
  }

  try {
    await prisma.$transaction(async tx => {
      await tx.connectionRequest.deleteMany({ where: { requesterId: me } });
      await tx.connectionRequest.deleteMany({ where: { requestedId: me } });
      await tx.connections.deleteMany({ where: { requesterId: me } });
      await tx.connections.deleteMany({ where: { requestedId: me } });
      await tx.blocks.deleteMany({ where: { OR: [{ blockerId: me }, { blockedId: me }] } });
      await tx.groupRoster.deleteMany({ where: { userId: me } });

      if (force && adminGroups.length) {
        const deletableIds = adminGroups.map(g => g.id);
        if (deletableIds.length) {
          await tx.posts.deleteMany({ where: { groupId: { in: deletableIds } } });
          await tx.groupRoster.deleteMany({ where: { groupId: { in: deletableIds } } });
          await tx.groups.deleteMany({ where: { id: { in: deletableIds } } });
        }
      }

      await tx.posts.deleteMany({ where: { userId: me } });
      await tx.users.delete({ where: { id: me } });
    });

    res.status(204).end();
  } catch (e: any) {
    res.status(400).json({ error: e.message });
  }
});

// --- Start server ---
app.listen(PORT, () => console.log(`Server on http://127.0.0.1:${PORT}`));
