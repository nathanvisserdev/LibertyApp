
import { Router } from "express";
import jwt from "jsonwebtoken";

const router = Router();
const JWT_SECRET = process.env.JWT_SECRET ?? "";
if (!JWT_SECRET) throw new Error("Missing JWT_SECRET in .env");

// --- Ping ---
router.get("/ping", (_req, res) => res.status(200).send("ok"));

// --- Auth middleware ---
import type { Request, Response, NextFunction } from "express";

export function auth(req: Request, res: Response, next: NextFunction) {
  const header = req.headers.authorization;
  if (!header?.startsWith("Bearer ")) return res.status(401).send("Missing token");
  const token = header.slice(7);
  try {
    const payload = jwt.verify(token, JWT_SECRET);
    if (typeof payload === "object" && payload !== null) {
      req.user = payload;
    } else {
      req.user = undefined;
    }
    next();
  } catch {
    return res.status(401).send("Invalid token");
  }
}

export default router;
