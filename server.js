const express = require("express")
const cors = require("cors")
const http = require("http")
const app = express()
const {Server} = require("socket.io")
const PORT = 9000
const server = http.createServer(app)
app.use(cors())
const socket = new Server(server, {
    cors : {origin : "*"}
})
const queue = [];
let token = 0
let currentPatient = {}
function broadcast(){
    socket.emit("queueUpdate", {
        current : currentPatient,
        queue : queue
    })
}
socket.on("connection" , (sock) => {
    console.log("Connection connected : ", sock.id)
    sock.on("addPatient" , (data, ack) => {
        const name = data.name
        const patient = {
            name : name,
            token : token++,
            addedAt : Date.now()
        }
        queue.push(patient)
        console.log("Patient Added : ", patient)
        console.log("Queue State = >" , queue)
        broadcast()
        ack?.({ ok: true})
    })
    sock.on("callNext", (_, ack) => {
        if(queue.length === 0){
            return ack?.({
                ok: false,
                message: "Queue empty"
            })
        }
        const current = queue.shift()
        currentPatient = current
        currentPatient = {...currentPatient , calledAt : Date.now()}  
        socket.emit("currentPatient" , {
            current : currentPatient
        })
        broadcast()
        ack?.({ ok: true, current: currentPatient })
    })
    sock.on("disconnect", () => console.log(`Disconnected: ${sock.id}`))
})


server.listen(PORT, '0.0.0.0',  ()=> {console.log(`Server Started at Port = ${PORT}`)})