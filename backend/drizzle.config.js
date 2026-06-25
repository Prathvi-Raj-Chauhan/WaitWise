require("dotenv").config();
console.log(process.env.SUPABASE_DIRECT_CONNECTION_STRING)
module.exports = {
  schema: "./db/schema.js",
  out: "./db/migration",
  dialect: "postgresql",
  dbCredentials: {
    url: process.env.SUPABASE_DIRECT_CONNECTION_STRING,
  },
};