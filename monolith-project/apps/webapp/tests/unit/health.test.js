import request from "supertest";
import { describe, expect, it } from "vitest";

import { app } from "../../src/server.js";

describe("webapp endpoints", () => {
  it("returns a healthy status", async () => {
    const response = await request(app).get("/health");

    expect(response.status).toBe(200);
    expect(response.body).toEqual({ status: "ok" });
  });

  it("returns an application version", async () => {
    const response = await request(app).get("/version");

    expect(response.status).toBe(200);
    expect(response.body.version).toBeDefined();
    expect(typeof response.body.version).toBe("string");
  });

  it("returns backend state even when DB is not configured", async () => {
    const response = await request(app).get("/api/backend");

    expect(response.status).toBe(200);
    expect(response.body.db.configured).toBe(false);
    expect(response.body.db.connected).toBe(false);
  });

  it("returns 503 for listing messages when DB is not configured", async () => {
    const response = await request(app).get("/api/messages");

    expect(response.status).toBe(503);
    expect(response.body.error).toContain("Database is not configured");
  });

  it("returns 400 for invalid message payload", async () => {
    const response = await request(app)
      .post("/api/messages")
      .send({ content: "" });

    expect(response.status).toBe(400);
    expect(response.body.error).toContain("content must be a non-empty string");
  });

  it("returns 503 for creating messages when DB is not configured", async () => {
    const response = await request(app)
      .post("/api/messages")
      .send({ content: "hello" });

    expect(response.status).toBe(503);
    expect(response.body.error).toContain("Database is not configured");
  });
});
