const { numeric } = require("drizzle-orm/pg-core");
const {
  pgTable,
  uuid,
  text,
  timestamp,
  boolean,
  integer,
  jsonb,
  pgEnum,
  real,
} = require("drizzle-orm/pg-core");

const statusEnum = pgEnum("appointment_status" ,[ "pending", "done", "cancelled"]);

const clinic = pgTable("clinic", {
  id: uuid("id").defaultRandom().primaryKey(),
  email: text("email").notNull().unique(),
  passwordHash: text("password_hash"), // null for google oAuth
  name: text("name").notNull(),
  googleId : text("google_id").unique(),
  createdAt : timestamp("created_at").defaultNow(),
  updatedAt : timestamp("updated_at").defaultNow()
});

const patient = pgTable("patient", {
    id: uuid("id").defaultRandom().primaryKey(),
    name : text("name").notNull(),
    gender : text("gender"),
    age : integer("age"),
    mobile : text("mobile_number").notNull().unique(),
    passwordHash: text("password_hash"), // null for google oAuth
    googleId : text("google_id").unique(),
    createdAt : timestamp("created_at").defaultNow(),
    updatedAt : timestamp("updated_at").defaultNow()
})

const appointment = pgTable("appointment", {
    id : uuid("id").defaultRandom().primaryKey(),
    patient_id : uuid("patient_id").notNull().references(() => patient.id, {onDelete : "cascade"}),
    clinic_id : uuid("clinic_id").notNull().references(() => clinic.id, {onDelete : "cascade"}),
    time : timestamp("time").defaultNow(),
    status : statusEnum("status").default("pending").notNull()
})

const refreshTokens = pgTable("refresh_tokens", {
  id: uuid("id").defaultRandom().primaryKey(),
  clinic_id: uuid("clinic_id").notNull().references(() => clinic.id, { onDelete: "cascade" }),
  tokenHash: text("token_hash").notNull().unique(),
  expiresAt: timestamp("expires_at").notNull(),
  createdAt: timestamp("created_at").defaultNow(),
});

module.exports = {
  appointment,patient, clinic, refreshTokens, statusEnum
}