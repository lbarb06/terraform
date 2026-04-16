import express from "express";

import { createMessage, getDatabaseStatus, listMessages } from "./db.js";

export const app = express();
const port = process.env.PORT || 3000;
const appVersion = process.env.APP_VERSION || "dev";

app.use(express.json());

app.get("/health", (_req, res) => {
  res.status(200).json({ status: "ok" });
});

app.get("/version", (_req, res) => {
  res.status(200).json({ version: appVersion });
});

app.get("/api/backend", async (_req, res) => {
  const db = await getDatabaseStatus();

  res.status(200).json({
    version: appVersion,
    db
  });
});

app.get("/api/messages", async (_req, res) => {
  try {
    const messages = await listMessages();
    res.status(200).json({ messages });
  } catch (error) {
    res.status(503).json({ error: error.message });
  }
});

app.post("/api/messages", async (req, res) => {
  const content = req.body?.content;

  if (!content || typeof content !== "string") {
    res.status(400).json({ error: "content must be a non-empty string" });
    return;
  }

  try {
    const message = await createMessage(content);
    res.status(201).json({ message });
  } catch (error) {
    res.status(503).json({ error: error.message });
  }
});

app.get("/", (_req, res) => {
  res.status(200).send(`<!doctype html>
<html>
  <head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <title>Project 1 Webapp</title>
    <style>
      body { font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif; margin: 2rem; max-width: 760px; }
      .row { display: flex; gap: 0.5rem; margin: 1rem 0; }
      input { flex: 1; padding: 0.6rem; }
      button { padding: 0.6rem 1rem; cursor: pointer; }
      .muted { color: #555; }
      .error { color: #b00020; }
      ul { padding-left: 1.2rem; }
      code { background: #f3f3f3; padding: 0.1rem 0.3rem; border-radius: 4px; }
    </style>
  </head>
  <body>
    <main>
      <h1 data-testid="title">Project 1 Webapp</h1>
      <p data-testid="status">Running with CI/CD, Docker, and GitOps.</p>
      <p data-testid="version">Version: ${appVersion}</p>
      <p>Backend endpoint: <code>/api/backend</code></p>

      <h2>Messages</h2>
      <form id="message-form" class="row" data-testid="message-form">
        <input id="message-input" data-testid="message-input" type="text" placeholder="Type a message" maxlength="255" required />
        <button data-testid="message-submit" type="submit">Save</button>
      </form>
      <p id="message-feedback" class="muted" data-testid="message-feedback"></p>
      <ul id="message-list" data-testid="message-list"></ul>

      <p><a href="/health">Health Endpoint</a></p>
    </main>

    <script>
      const form = document.getElementById("message-form");
      const input = document.getElementById("message-input");
      const list = document.getElementById("message-list");
      const feedback = document.getElementById("message-feedback");

      function setFeedback(text, isError = false) {
        feedback.textContent = text;
        feedback.className = isError ? "error" : "muted";
      }

      function renderMessages(messages) {
        list.innerHTML = "";
        for (const msg of messages) {
          const item = document.createElement("li");
          const created = msg.createdAt ? new Date(msg.createdAt).toLocaleString() : "";
          item.textContent = created ? msg.content + " (" + created + ")" : msg.content;
          list.appendChild(item);
        }
      }

      async function loadMessages() {
        try {
          const response = await fetch("/api/messages");
          const payload = await response.json();

          if (!response.ok) {
            setFeedback(payload.error || "Unable to load messages", true);
            renderMessages([]);
            return;
          }

          renderMessages(payload.messages || []);
          setFeedback("Messages loaded");
        } catch (_error) {
          setFeedback("Unable to load messages", true);
        }
      }

      form.addEventListener("submit", async (event) => {
        event.preventDefault();

        const content = input.value.trim();
        if (!content) {
          setFeedback("Message cannot be empty", true);
          return;
        }

        try {
          const response = await fetch("/api/messages", {
            method: "POST",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify({ content })
          });
          const payload = await response.json();

          if (!response.ok) {
            setFeedback(payload.error || "Unable to save message", true);
            return;
          }

          input.value = "";
          setFeedback("Message saved");
          await loadMessages();
        } catch (_error) {
          setFeedback("Unable to save message", true);
        }
      });

      loadMessages();
    </script>
  </body>
</html>`);
});

if (process.env.NODE_ENV !== "test") {
  app.listen(port, () => {
    console.log(`Webapp listening on port ${port}`);
  });
}

if (process.env.NODE_ENV !== "test") {
  app.listen(port, () => {
    console.log(`Webapp listening on port ${port}`);
  });
}

export default app;
