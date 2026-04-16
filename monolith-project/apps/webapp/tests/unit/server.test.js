import { describe, it, expect, vi, beforeEach } from "vitest";
import request from "supertest";

vi.mock("../../src/db.js", () => ({
  listMessages: vi.fn(),
  createMessage: vi.fn(),
}));

import app from "../../src/server.js";
import { listMessages, createMessage } from "../../src/db.js";

describe("server routes", () => {
  beforeEach(() => {
    vi.clearAllMocks();
  });

  it("GET /health returns ok", async () => {
    const res = await request(app).get("/health");
    expect(res.status).toBe(200);
    expect(res.body).toEqual({ status: "ok" });
  });

  it("POST /api/messages returns 400 for invalid content", async () => {
    const res = await request(app)
      .post("/api/messages")
      .send({ message: "wrong-field" });

    expect(res.status).toBe(400);
    expect(res.body.error).toBe("content must be a non-empty string");
  });

  it("GET /api/messages returns db messages", async () => {
    listMessages.mockResolvedValue([
      { id: 1, content: "hello", createdAt: "2026-04-10T00:00:00.000Z" },
    ]);

    const res = await request(app).get("/api/messages");

    expect(res.status).toBe(200);
    expect(res.body.messages).toHaveLength(1);
    expect(res.body.messages[0].content).toBe("hello");
  });
});
