const { db } = require("../db/index");
const { appointment, patient, clinic } = require("../db/schema");
const { eq, and, ilike, sql } = require("drizzle-orm");

// GET /history/:clinicId
// query params: from, to, name, status
async function getPatientHistory(req, res) {
  try {
    const { clinicId } = req.params;
    const { from, to, name, status } = req.query;

    if (!clinicId) {
      return res.status(400).json({ error: "Clinic ID is required" });
    }

    const conditions = [eq(appointment.clinic_id, clinicId)];

    if (status && status !== "all") {
      conditions.push(eq(appointment.status, status));
    }

    if (from) {
      const fromMs = new Date(from).setHours(0, 0, 0, 0); // ✅ number, not string
      conditions.push(sql`CAST(${appointment.added_at} AS BIGINT) >= ${fromMs}`);
    }

    if (to) {
      const toMs = new Date(to).setHours(23, 59, 59, 999); // ✅ number, not string
      conditions.push(sql`CAST(${appointment.added_at} AS BIGINT) <= ${toMs}`);
    }

    if (name && name.trim() !== "") {
      conditions.push(ilike(patient.name, `%${name.trim()}%`));
    }

    const whereClause = conditions.length === 1
      ? conditions[0]
      : and(...conditions.filter(Boolean));

    const records = await db
      .select({
        id:            appointment.id,
        status:        appointment.status,
        weight:        appointment.weight,
        bloodPressure: appointment.blood_pressure,
        added_at:      appointment.added_at,
        name:          patient.name,
        age:           patient.age,
        gender:        patient.gender,
        mobile:        patient.mobile,
        reason:        appointment.reason,
        address:       patient.address, // ✅ address is on patient, not appointment
      })
      .from(appointment)
      .innerJoin(patient, eq(appointment.patient_id, patient.id))
      .where(whereClause)
      .orderBy(sql`CAST(${appointment.added_at} AS BIGINT) DESC`);

    return res.status(200).json({ count: records.length, records });

  } catch (e) {
    console.error("getPatientHistory error:", e.message, e.cause);
    return res.status(500).json({ error: "Server error", message: e.message });
  }
}

// GET /history/:clinicId/stats
async function getClinicStats(req, res) {
  try {
    const { clinicId } = req.params;

    if (!clinicId) {
      return res.status(400).json({ error: "Clinic ID is required" });
    }

    const [stats] = await db
      .select({
        total:   sql`COUNT(*)`.mapWith(Number),
        done:    sql`COUNT(*) FILTER (WHERE ${appointment.status} = 'done')`.mapWith(Number),
        pending: sql`COUNT(*) FILTER (WHERE ${appointment.status} = 'pending')`.mapWith(Number),
      })
      .from(appointment)
      .where(eq(appointment.clinic_id, clinicId));

    return res.status(200).json({ stats });
  } catch (e) {
    console.error("getClinicStats error:", e.message);
    return res.status(500).json({ error: "Server error", message: e.message });
  }
}

module.exports = { getPatientHistory, getClinicStats };