
import { Router } from "express";
import { PrismaClient, GroupType } from "./generated/prisma/index.js";
import { auth } from "./misc.js";

const prisma = new PrismaClient();
const router = Router();

// --- Create Group ---
router.post("/groups", auth, async (req, res) => {
  const { name, description, groupType } = req.body ?? {};
  if (!name) return res.status(400).send("Missing name");

  if (!req.user || typeof req.user !== "object" || !("id" in req.user)) {
    return res.status(401).send("Invalid token payload");
  }
  const me = req.user as any;

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
  } catch (e) {
    if (e instanceof Error) {
      res.status(400).json({ error: e.message });
    } else {
      res.status(400).json({ error: String(e) });
    }
  }
});

// --- List Groups ---
router.get("/groups", auth, async (_req, res) => {
  const groups = await prisma.groups.findMany({ include: { admin: true } });
  res.json(
    groups.map(g => {
      if (g.groupType === "PUBLIC")
        return { ...g, displayLabel: `${g.name} public assembly room` };
      if (g.groupType === "PRIVATE")
        return { ...g, displayLabel: `${g.name} private assembly room` };
      return { ...g, displayLabel: "Social Circle" };
    })
  );
});

// --- Access a room (no room for PERSONAL) ---
router.get("/groups/:id/room", auth, async (req, res) => {
  if (!req.user || typeof req.user !== "object" || !("id" in req.user)) {
    return res.status(401).send("Invalid token payload");
  }
  const me = (req.user as any).id;
  if (!req.params.id) return res.status(400).send("Missing group id");
  const g = await prisma.groups.findUnique({ where: { id: req.params.id as string } });
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

export default router;
