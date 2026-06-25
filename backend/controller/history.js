const { db } = require("../db/index");
const { appointment, patient, clinic } = require("../db/schema");
const { eq, and, gte, lte, ilike, sql } = require("drizzle-orm");

// GET /history/:clinicId
// query params: from, to, name, status
async function getPatientHistory(req, res) {
  try {
    const { clinicId } = req.params;
    const { from, to, name, status } = req.query;

    if (!clinicId) {
      return res.status(400).json({ error: "Clinic ID is required" });
    }

    // build conditions incrementally
    const conditions = [eq(appointment.clinic_id, clinicId)];

    if (status && status !== "all") {
      conditions.push(eq(appointment.status, status));
    }

    // addedAt is stored as text (ms string) so cast to bigint for range comparison
    if (from) {
      const fromMs = new Date(from).setHours(0, 0, 0, 0).toString();
      conditions.push(
        sql`CAST(${appointment.addedAt} AS BIGINT) >= ${fromMs}`
      );
    }

    if (to) {
      const toMs = new Date(to).setHours(23, 59, 59, 999).toString();
      conditions.push(
        sql`CAST(${appointment.addedAt} AS BIGINT) <= ${toMs}`
      );
    }

    // build query — join patient to get name, age, gender
    let query = db
      .select({
        id:            appointment.id,
        status:        appointment.status,
        weight:        appointment.weight,
        blood_pressure: appointment.blood_pressure,
        addedAt:       appointment.addedAt,
        name:          patient.name,
        age:           patient.age,
        gender:        patient.gender,
        mobile:        patient.mobile,
        // reason and address live on appointment since they're per-visit
        reason:        appointment.reason,
        address:       appointment.address,
      })
      .from(appointment)
      .innerJoin(patient, eq(appointment.patient_id, patient.id))
      .where(and(...conditions))
      .orderBy(sql`CAST(${appointment.addedAt} AS BIGINT) DESC`);

    // name filter — applied after join since name is on patient table
    if (name && name.trim() !== "") {
      conditions.push(ilike(patient.name, `%${name.trim()}%`));
      // rebuild with name condition included
      query = db
        .select({
          id:            appointment.id,
          status:        appointment.status,
          weight:        appointment.weight,
          blood_pressure: appointment.blood_pressure,
          addedAt:       appointment.addedAt,
          name:          patient.name,
          age:           patient.age,
          gender:        patient.gender,
          mobile:        patient.mobile,
          reason:        appointment.reason,
          address:       appointment.address,
        })
        .from(appointment)
        .innerJoin(patient, eq(appointment.patient_id, patient.id))
        .where(and(...conditions))
        .orderBy(sql`CAST(${appointment.addedAt} AS BIGINT) DESC`);
    }

    const records = await query;

    return res.status(200).json({
      count: records.length,
      records,
    });
  } catch (e) {
    console.error("getPatientHistory error:", e.message);
    return res.status(500).json({ error: "Server error", message: e.message });
  }
}

// GET /history/:clinicId/stats
// returns quick summary counts for the clinic
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