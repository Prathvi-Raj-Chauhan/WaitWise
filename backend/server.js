const express = require("express");
const cors = require("cors");
const http = require("http");
const app = express();
var cookieParser = require('cookie-parser')
const { Server } = require("socket.io");
const PORT = 9000;
const server = http.createServer(app);
const authRouter = require("./router/auth");
const historyRouter = require("./router/history")
const {
  registerPatientByClinic,
  createAppointmentForPatient,
} = require("./controller/hooks");
const { appointment } = require("./db/schema");
const { db } = require("./db/index")      // or wherever your db instance lives
const { eq, and } = require("drizzle-orm")
require("dotenv").config();
app.use(cookieParser())
app.use(
  cors({
    origin: [
      "http://localhost:50978",
      "http://localhost:50979",
      "http://localhost:50980",
    ],
    credentials: true,
  }),
);

app.use(express.json());

const clinics = new Map();
const socket = new Server(server, {
  cors: { origin: "*" },
});
const MAX_SAMPLES = 15;
function getClinic(clinicId) {
  if (!clinics.has(clinicId)) {
    clinics.set(clinicId, {
      queue: [],
      current: null,
      nextToken: 1,
      consultDurations: [],
    });
  }
  return clinics.get(clinicId);
}

function broadcast(clinicId) {
  const clinic = getClinic(clinicId);
  const avg = avgConsultMins(clinic);
  socket.in(clinicId).emit("queueUpdated", {
    current: clinic.current,
    queue: clinic.queue.map((p, i) => ({
      ...p,
      position: i + 1,
      estWaitMins: Math.round(i * avg),
    })),
    avgConsultMins: avg,
    isRealAvg: clinic.consultDurations.length > 0,
  });
}
function avgConsultMins(clinic) {
  if (clinic.consultDurations.length === 0) return 5;

  const total = clinic.consultDurations.reduce((a, b) => a + b, 0);

  return total / clinic.consultDurations.length / 60000;
}
socket.on("connection", (sock) => {
  const clinicId = sock.handshake.query.clinicId;
  if (!clinicId) {
    return sock.disconnect();
  }

  console.log("Connection connected : ", sock.id);
  console.log("Clinic Id = ", clinicId);

  sock.join(clinicId);
  broadcast(clinicId);
  sock.on("addPatient", (data, ack) => {
    try {
      const name = data?.name?.trim();
      const reason = data?.reason?.trim();
      const mobile = data?.mobile?.trim();
      const clinicDbId = data?.clinicDbId?.trim();
      if (!name) return ack?.({ ok: false, error: "Name not provided" });
      if (!mobile) return ack?.({ ok: false, error: "mobile not provided" });
      if (!reason) return ack?.({ ok: false, error: "Reason not provided" });
      const age = data?.age?.trim() || null;
      const weight = data?.weight?.trim() || null;
      const blood_pressure = data?.blood_pressure?.trim() || null;
      const address = data?.address?.trim() || null;
      const gender = data?.gender?.trim() || null;

      const clinic = getClinic(clinicId);
      const addedAt = Date.now();
      const newpatient = {
        token: clinic.nextToken++,
        name,
        age,
        gender,
        blood_pressure,
        weight,
        reason,
        address,
        addedAt,
      };
      clinic.queue.push(newpatient);
      console.log("Patient Added : ", newpatient);
      broadcast(clinicId);
      ack?.({ ok: true });

      // below tasks will keep happening lazily and finish whenever they want
      registerPatientByClinic({ name, age, gender, mobile, address })
        .then((patientRow) =>
          createAppointmentForPatient({
            patientId: patientRow.id,
            clinicId: clinicDbId,
            weight,
            blood_pressure,
            addedAt : String(addedAt),
            reason
          }),
        )
        .catch((e) =>
          console.error("DB write failed for patient:", name, e.message, e.cause ?? ""),
        );
    } catch (e) {
      console.error("addPatient failed:", e.message);
      ack?.({ ok: false, error: "Server error" });
    }
  });
  sock.on("callNext", (data, ack) => {
    const clinic = getClinic(clinicId);
    const clinicDbId = data?.clinicDbId?.trim();
    console.log("CALL NEXT REVOKED");
    if (clinic.queue.length === 0) {
      return ack?.({
        ok: true,
        message: "Queue empty",
      });
    }
    const current = clinic.current;
    if (current != null) {
      clinic.consultDurations.push(Date.now() - current.calledAt);
      if (clinic.consultDurations.length > MAX_SAMPLES)
        clinic.consultDurations.shift();
    }
    const toCall = clinic.queue.shift();

    clinic.current = toCall;
    clinic.current = { ...toCall, calledAt: Date.now() };
    broadcast(clinicId);
    ack?.({ ok: true, current: clinic.current });

    if (current?.addedAt) {
      db.update(appointment)
        .set({ status: "done" })
        .where(
          and(
            eq(appointment.clinic_id, clinicDbId),
            eq(appointment.addedAt, String(current.addedAt)),
          ),
        )
        .catch((e) => console.error("done_at update failed:", e.message));
    }
  });
  sock.on("disconnect", () => console.log(`Disconnected: ${sock.id}`));
});

app.use("/auth", authRouter);
app.use("/history", historyRouter)
server.listen(PORT, "0.0.0.0", () => {
  console.log(`Server Started at Port = ${PORT}`);
});
