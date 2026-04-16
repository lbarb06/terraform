import mysql from "mysql2/promise";

const requiredEnv = ["DB_HOST", "DB_USER", "DB_PASSWORD", "DB_NAME"];

function getDbConfig() {
  return {
    host: process.env.DB_HOST,
    port: Number(process.env.DB_PORT || 3306),
    user: process.env.DB_USER,
    password: process.env.DB_PASSWORD,
    database: process.env.DB_NAME
  };
}

function isDbConfigured() {
  return requiredEnv.every((key) => Boolean(process.env[key]));
}

let pool;

function getPool() {
  if (!pool) {
    pool = mysql.createPool({
      ...getDbConfig(),
      waitForConnections: true,
      connectionLimit: 5
    });
  }

  return pool;
}

async function ensureSchema() {
  await getPool().query(`
    CREATE TABLE IF NOT EXISTS messages (
      id INT AUTO_INCREMENT PRIMARY KEY,
      content VARCHAR(255) NOT NULL,
      created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    )
  `);
}

export async function getDatabaseStatus() {
  if (!isDbConfigured()) {
    return {
      configured: false,
      connected: false,
      error: null
    };
  }

  try {
    await getPool().query("SELECT 1");

    return {
      configured: true,
      connected: true,
      error: null
    };
  } catch (error) {
    return {
      configured: true,
      connected: false,
      error: error.message
    };
  }
}

export async function listMessages() {
  if (!isDbConfigured()) {
    throw new Error("Database is not configured");
  }

  await ensureSchema();

  const [rows] = await getPool().query(
    "SELECT id, content, created_at AS createdAt FROM messages ORDER BY id DESC LIMIT 20"
  );

  return rows;
}

export async function createMessage(content) {
  if (!isDbConfigured()) {
    throw new Error("Database is not configured");
  }

  await ensureSchema();

  const [result] = await getPool().query(
    "INSERT INTO messages (content) VALUES (?)",
    [content]
  );

  return {
    id: result.insertId,
    content
  };
}
