const { db } = require("../db/index");
const { patient, appointment } = require("../db/schema");
const { eq } = require("drizzle-orm");

async function registerPatientByClinic({ name, age, gender, mobile, address }) {
  const existing = await db
    .select()
    .from(patient)
    .where(eq(patient.mobile, String(mobile)))
    .limit(1)

  if (existing.length > 0) {
    return existing[0]  // returning patient already exists, that's fine
  }

  const [newPatient] = await db
    .insert(patient)
    .values({ name, mobile :String(mobile), age: Number(age)  || null, gender: gender || null, address })
    .returning()

  return newPatient  // already the row, not newPatient[0]
}

async function createAppointmentForPatient({ patientId, clinicId, weight, blood_pressure, addedAt, reason}) {
  const [newAppointment] = await db
    .insert(appointment)
    .values({
      patient_id:    patientId,
      clinic_id:     clinicId,
      status:        'pending',
      weight:        weight        || null,
      blood_pressure: blood_pressure || null,
      added_at : addedAt,
      reason
    })
    .returning()

  return newAppointment  // already the row
}

module.exports = {
    createAppointmentForPatient,
    registerPatientByClinic
}