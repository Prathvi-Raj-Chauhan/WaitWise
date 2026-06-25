const express = require("express")
const cors = require("cors")
const http = require("http")
const app = express()
const {Server} = require("socket.io")
const PORT = 9000
const server = http.createServer(app)
const authRouter = require("./router/auth")
require("dotenv").config()

app.use(cors({
  origin: ['http://localhost:50978', 'http://localhost:50979'],
  credentials: true,               
}))

app.use(express.json())

const clinics = new Map()
const socket = new Server(server, {
    cors : {origin : "*"}
})
const MAX_SAMPLES = 15
function getClinic(clinicId) {
  if (!clinics.has(clinicId)) {
    clinics.set(clinicId, {
      queue: [],
      current: null,
      nextToken: 1,
      consultDurations: [],
    })
  }
  return clinics.get(clinicId)
}

function broadcast(clinicId) {
  const clinic = getClinic(clinicId)
  const avg = avgConsultMins(clinic)
  socket.in(clinicId).emit("queueUpdated", {
    current: clinic.current,
    queue: clinic.queue.map((p, i) => ({
      ...p,
      position: i + 1,
      estWaitMins: Math.round(i * avg),
    })),
    avgConsultMins: avg,
    isRealAvg: clinic.consultDurations.length > 0,
  })
}
function avgConsultMins(clinic) {
    if (clinic.consultDurations.length === 0) return 5;

    const total = clinic.consultDurations.reduce((a, b) => a + b, 0);

    return total / clinic.consultDurations.length / 60000;
}
socket.on("connection" , (sock) => {
    const clinicId = sock.handshake.query.clinicId
    if(!clinicId){
        return sock.disconnect()
    }

    console.log("Connection connected : ", sock.id)
    console.log("Clinic Id = ", clinicId)

    sock.join(clinicId)
    broadcast(clinicId)
    sock.on("addPatient" , (data, ack) => {
         const name = data?.name?.trim()
        const reason = data?.reason?.trim()
        if (!name) return ack?.({ ok: false, error: "Name not provided" })
        if (!reason) return ack?.({ ok: false, error: "Reason not provided" })

        const age    = data?.age    ? parseInt(data.age.toString().trim(), 10)    : null
        const weight = data?.weight ? parseInt(data.weight.toString().trim(), 10) : null
        const bloodPressure = data?.bloodPressure?.trim() || null
        const address       = data?.address?.trim()       || null
        const gender        = data?.gender?.trim()        || null
 
        const clinic = getClinic(clinicId)
        const patient = {
            id: `${clinicId}-${clinic.nextToken}`,  
            token: clinic.nextToken++,
            name,
            age,
            gender,
            bloodPressure,
            weight,
            reason,
            address,
            addedAt: Date.now(),
        }
        clinic.queue.push(patient)
        console.log("Patient Added : ", patient)
        broadcast(clinicId)
        ack?.({ ok: true })
    })
    sock.on("callNext", (_, ack) => {
        const clinic = getClinic(clinicId)
        console.log("CALL NEXT REVOKED")
        if(clinic.queue.length === 0){
            return ack?.({
                ok: false,
                message: "Queue empty"
            })
        }
        const current = clinic.current
        if(current!= null){
            clinic.consultDurations.push(Date.now() - current.calledAt)
            if (clinic.consultDurations.length > MAX_SAMPLES) clinic.consultDurations.shift()
        }
        const toCall = clinic.queue.shift()

        clinic.current = toCall
        
        clinic.current = {...toCall , calledAt : Date.now()}  
        broadcast(clinicId)
        ack?.({ ok: true, current: clinic.current })
    })
    sock.on("disconnect", () => console.log(`Disconnected: ${sock.id}`))
})


app.use("/auth", authRouter)

server.listen(PORT, '0.0.0.0',  ()=> {console.log(`Server Started at Port = ${PORT}`)})