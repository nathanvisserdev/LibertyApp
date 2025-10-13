import { describe, it, expect } from "vitest";
import request from "supertest";
import { app } from "../src/index.js";

describe("auth endpoints", () => {
  it("signup returns 201 and user", async () => {
    const email = `user${Date.now()}@example.com`;
    const res = await request(app)
      .post("/signup")
      .send({ email, password: "testpass" });
    expect(res.status).toBe(201);
    expect(res.body).toHaveProperty("id");
    expect(res.body).toHaveProperty("email", email);
  });

  it("login returns 200 and token", async () => {
    const email = `user${Date.now()}@example.com`;
    await request(app)
      .post("/signup")
      .send({ email, password: "testpass" });
    const res = await request(app)
      .post("/login")
      .send({ email, password: "testpass" });
    expect(res.status).toBe(200);
    expect(res.body).toHaveProperty("accessToken");
  });

  it("login with wrong password returns 401", async () => {
    const email = `user${Date.now()}@example.com`;
    await request(app)
      .post("/signup")
      .send({ email, password: "testpass" });
    const res = await request(app)
      .post("/login")
      .send({ email, password: "wrongpass" });
    expect(res.status).toBe(401);
  });

  it("/user returns 401 without token", async () => {
    const res = await request(app).get("/user");
    expect(res.status).toBe(401);
  });
});
