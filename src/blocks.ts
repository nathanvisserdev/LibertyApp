
import { Router } from "express";
import { PrismaClient } from "./generated/prisma/index.js";
import { auth } from "./misc.js";

const prisma = new PrismaClient();
const router = Router();

// --- Block ---
router.post("/block", auth, async (req, res) => {
  if (!req.user || typeof req.user !== "object" || !("id" in req.user)) {
    return res.status(401).send("Invalid token payload");
  }
  const me = (req.user as any).id;
  const { userId } = req.body ?? {};
  if (!userId || userId === me) return res.status(400).send("invalid target");
  await prisma.blocks.upsert({
    where: { blockerId_blockedId: { blockerId: me, blockedId: userId } },
    update: {},
    create: { blockerId: me, blockedId: userId },
  });
  res.sendStatus(204);
});

// --- Unblock ---
router.post("/unblock", auth, async (req, res) => {
  if (!req.user || typeof req.user !== "object" || !("id" in req.user)) {
    return res.status(401).send("Invalid token payload");
  }
  const me = (req.user as any).id;
  const { userId } = req.body ?? {};
  if (!userId || userId === me) return res.status(400).send("invalid target");
  await prisma.blocks.deleteMany({ where: { blockerId: me, blockedId: userId } });
  res.sendStatus(204);
});

export default router;
