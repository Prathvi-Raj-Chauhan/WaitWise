const express = require("express");
const router = express.Router();
const { getPatientHistory, getClinicStats } = require("../controller/history");
const {authenticate} = require("../middleware/auth")
// GET /history/:clinicId?from=2024-01-01&to=2024-12-31&name=john&status=done
router.get("/:clinicId", authenticate, getPatientHistory);

// GET /history/:clinicId/stats
router.get("/:clinicId/stats", authenticate, getClinicStats);

module.exports = router;