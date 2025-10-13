
import { Router } from "express";
import bcrypt from "bcrypt";
import jwt from "jsonwebtoken";
import { PrismaClient, GroupType } from "./generated/prisma/index.js";
import { auth } from "./misc.js";

const prisma = new PrismaClient();
const router = Router();

const BCRYPT_ROUNDS = Number(process.env.BCRYPT_ROUNDS || 12);
const JWT_SECRET = process.env.JWT_SECRET ?? "";
if (!JWT_SECRET) throw new Error("Missing JWT_SECRET in .env");

// --- Signup (email + password) ---
router.post("/signup", async (req, res) => {
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
  } catch (err) {
    if (err instanceof Error) {
      res.status(400).json({ error: err.message });
    } else {
      res.status(400).json({ error: String(err) });
    }
  }
});

// --- Login ---
router.post("/login", async (req, res) => {
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
router.get("/user", auth, async (req, res) => {
  const payload = req.user;
  if (!payload || typeof payload !== "object" || !("id" in payload)) {
    return res.status(401).send("Invalid token payload");
  }
  const user = await prisma.users.findUnique({ where: { id: (payload as any).id } });
  if (!user) return res.status(404).send("User not found");
  res.json(user);
});

// --- Delete user (protect and clean) ---
router.delete("/user", auth, async (req, res) => {
  if (!req.user || typeof req.user !== "object" || !("id" in req.user)) {
    return res.status(401).send("Invalid token payload");
  }
  const me = (req.user as any).id;
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
  } catch (e) {
    if (e instanceof Error) {
      res.status(400).json({ error: e.message });
    } else {
      res.status(400).json({ error: String(e) });
    }
  }
});

export default router;
