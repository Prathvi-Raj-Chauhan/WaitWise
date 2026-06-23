// dbtest.js - add this
require("dotenv").config();
const { drizzle } = require("drizzle-orm/node-postgres");
const { Pool } = require("pg");
const { clinic } = require("./db/schema");
const { eq } = require("drizzle-orm");

const pool = new Pool({
  connectionString: process.env.SUPABASE_CONNECTION_STRING,
  ssl: { rejectUnauthorized: false },
});

const db = drizzle(pool, { schema: { clinic } });

(async () => {
  try {
    const result = await db.select().from(clinic).limit(1);
    console.log("✅ Drizzle query works:", result);
  } catch (e) {
    console.error("❌ Drizzle error:", e.message);
    console.error("Full error:", e);
  } finally {
    await pool.end();
  }
})();