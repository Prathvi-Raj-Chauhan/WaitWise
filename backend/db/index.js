const {drizzle} = require("drizzle-orm/node-postgres")
const{Pool} = require("pg")
const schema = require("./schema");
require("dotenv").config()
const pool = new Pool({
    connectionString: process.env.SUPABASE_CONNECTION_STRING,
    ssl : {rejectUnauthorized : false},
})


const db = drizzle(pool, { schema })

module.exports = {db};