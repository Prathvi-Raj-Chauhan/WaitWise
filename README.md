# WaitWise

A real-time clinic queue management system built for small to medium medical practices. Patients register at reception, get a token, and can see their position on a public display. The doctor sees full patient details before calling the next person in.
<img width="1918" height="921" alt="image" src="https://github.com/user-attachments/assets/83657a2c-236a-40c2-abc5-6bb322cda6a0" />

---

## What it does

- Reception staff register patients with name, age, gender, BP, weight, reason for visit, and address.
- Patients waiting in the room see a live display showing who is currently being seen and who is next.
- The doctor sees a full detail view of the current patient and a preview of the next one.
- Queue state syncs across all connected clients in real time via WebSockets.
- Average consultation time is tracked and used to estimate wait times.
- Time, Temperature, City are not hardcoded and are fetched from backend to make the ux feel live.
---

## Tech stack

| Layer | Technology |
|---|---|
| Frontend | Flutter (Web) |
| State management | Riverpod |
| Backend | Node.js + Express |
| Real-time sync | Socket.IO |
| Weather | Open-Meteo API + Nominatim (reverse geocoding) |

---

## Project structure

```
wait_wise/
├── lib/
│   ├── main.dart
│   ├── model/
│   │   └── QueueState.dart        # Token, Waiting, QueueState models
│   ├── provider/
│   │   └── provider.dart          # Riverpod providers + QueueNotifier
│   ├── repository/
│   │   └── repo.dart              # Socket factory
│   ├── screens/
│   │   ├── login.dart             # Login page
│   │   ├── role_select.dart       # Doctor / Reception role picker
│   │   ├── reception.dart         # Reception — register patients, manage queue
│   │   ├── wait_room.dart         # Public display — current token + queue list
│   │   └── doctor_screen.dart     # Doctor view — full patient details
│   ├── widgets/
│   |   └── LiveClock.dart         # Ticking HH:MM clock widget
|   |   └── clinicIdDialog.dart    # Input for Clinic Id
│   └── services/
|       └── Dioclient.dart         # Single Instance of Dio configured with cookies and interceptors 


backend/
├── controller/
├── db/
├── middleware/
├── node_modules/
├── public/
├── router/
├── services/
├── .env
├── dbtest.js
├── drizzle.config.js
├── loadTest.js
├── package.json
├── server.js
└── ...
```

---

## Data flow

```
Reception registers patient
        |
        v
Socket "addPatient" event --> Server pushes updated queue to all clients
        |
        v
WaitRoom shows token + name (lightweight Waiting model)
DoctorScreen shows full Token details (name, age, gender, BP, weight, reason, address)
        |
        v
Doctor taps CALL_NEXT
        |
        v
Optimistic update on client (instant UI response)
Socket "callNext" event --> Server shifts queue, records consult duration
Server broadcasts new state --> All clients sync
```

---

## Queue state model

The server currently keeps a single in-memory `Map` keyed by clinic ID. Each clinic has:

- `queue` — ordered array of patients waiting
- `current` — the patient currently being seen
- `nextToken` — auto-incrementing token counter
- `consultDurations` — rolling window of last 15 consultation durations (used to compute average wait time)

The Flutter client maintains two parallel lists from the same queue data:

- `waiting` — lightweight `Waiting` objects (token, name, position, estimated wait) shown on the public display
- `detailedPatients` — full `Token` objects with all medical fields shown on the doctor screen

---

## Screens

### Login
Staff authenticate before accessing the system. After login, they are taken to the role selection screen.
<img width="1913" height="927" alt="image" src="https://github.com/user-attachments/assets/eb9443be-9e4d-4b9c-ba2e-e4f74ba65419" />


### Role selection
Presents two options — Doctor and Reception. Selection is required before proceeding. The chosen role determines which screen loads.

### Reception
- Displays current token and two stats (waiting count, total today)
- NEW PATIENT button opens a registration dialog
- Registration collects: name (required), reason (required), age, gender, blood pressure, weight, address
- Queue list shows all waiting patients with estimated wait time
- <img width="1918" height="922" alt="image" src="https://github.com/user-attachments/assets/4359bfd7-3bf4-4b9d-9bcc-854b985038fb" />


### Wait room (public display)
- Intended to be shown on a TV or monitor in the waiting area
- Shows the current token number and name in large type
- Lists upcoming patients by token number
- Live clock and local weather in the top bar
- Designed to run full-screen in a browser
- <img width="1918" height="1078" alt="image" src="https://github.com/user-attachments/assets/43bd614e-93c8-454f-8bdc-3f7edcc8d92b" />


### Doctor screen
- Shows full details of the current patient: name, token, age, gender, BP, weight, address, reason for visit
- Right panel shows the next patient preview and full queue log
- CALL_NEXT button advances the queue
- Same live clock and weather as the wait room
- <img width="1918" height="912" alt="image" src="https://github.com/user-attachments/assets/81d97b46-d8ff-434d-8c51-2bd078927000" />


---


## Known limitations

- Queue state is not persisted — a server restart loses all data
- No authentication on the socket connection — any client that knows the clinic ID can join
- Single server instance — no horizontal scaling without adding a Socket.IO adapter (e.g. Redis adapter)
- Weather and geolocation only work on HTTPS or localhost due to browser restrictions

---
## Future Additions

- [.] All added patients will be Added into the supabase backed Postrgres Database
- [.] Additions of patients will be done lazily.
- [.] Screen Where Doctors or Receptionist can see old Records of patient.
- [ ] Receptionist can pick the already registered patient and book their appointment.
- [ ] Doctor can update in a small brief what the appointment was or what they advised, something like that so that they can remember.

## License

MIT
