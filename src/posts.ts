
import { Router } from "express";
import { PrismaClient, GroupType, PostVisibility } from "./generated/prisma/index.js";
import { auth } from "./misc.js";

const prisma = new PrismaClient();
const router = Router();

// --- Create Post (≤500 chars) for Public Feed (auth required, no group) ---
router.post("/posts", auth, async (req, res) => {
  if (!req.user || typeof req.user !== "object" || !("id" in req.user)) {
    return res.status(401).send("Invalid token payload");
  }
  const me = req.user as any;
  const { content } = req.body ?? {};

  if (!content || String(content).trim().length === 0 || String(content).length > 500) {
    return res.status(400).send("Invalid content");
  }

  try {
    const post = await prisma.posts.create({
      data: {
        userId: me.id,
        content: String(content),
      },
    });

    res.status(201).json({
      id: post.id,
      content: post.content,
      createdAt: post.createdAt,
      userId: post.userId,
    });
  } catch (e) {
    console.error(e);
    if (e instanceof Error) {
      res.status(400).json({ error: e.message });
    } else {
      res.status(400).json({ error: String(e) });
    }
  }
});

// --- Get Posts (optionally by group) with block filtering ---
router.get("/posts", auth, async (req, res) => {
  if (!req.user || typeof req.user !== "object" || !("id" in req.user)) {
    return res.status(401).send("Invalid token payload");
  }
  const me = (req.user as any).id;
  const groupId = typeof req.query.groupId === "string" ? req.query.groupId : undefined;

  const [iBlocked, blockedMe] = await Promise.all([
    prisma.blocks.findMany({ where: { blockerId: me }, select: { blockedId: true } }),
    prisma.blocks.findMany({ where: { blockedId: me }, select: { blockerId: true } }),
  ]);
  const blocked = new Set([
    ...iBlocked.map(b => b.blockedId),
    ...blockedMe.map(b => b.blockerId),
  ]);

  let groupWhere = undefined;
  if (groupId) {
  const g = await prisma.groups.findUnique({ where: { id: groupId as string } });
    if (!g) return res.status(404).send("group not found");

    if (g.groupType === "PERSONAL") {
      if (g.adminId !== me) return res.sendStatus(404);
    } else if (g.groupType === "PRIVATE") {
      const member = await prisma.groupRoster.findUnique({
        where: { userId_groupId: { userId: me, groupId: groupId as string } },
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

// --- Public Feed (no group logic) ---
router.get("/feed/public-square", async (req, res) => {
  try {
    const take = Math.min(Number(req.query.take) || 30, 100);
    const cursor = req.query.cursor ? String(req.query.cursor) : undefined;

    const items = await prisma.posts.findMany({
      where: {
        groupId: null,
      },
      include: {
        user: true,
      },
      orderBy: { createdAt: "desc" },
      take,
      ...(cursor ? { skip: 1, cursor: { id: cursor } } : {}),
    });

    res.json({
      items,
  nextCursor: items.length === take && items.length > 0 && items[items.length - 1]?.id ? items[items.length - 1].id : null,
    });
  } catch (e) {
    console.error(e);
    res.status(500).json({ error: "public-square-failed" });
  }
});

export default router;
