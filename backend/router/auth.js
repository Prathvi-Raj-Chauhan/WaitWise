const {Router} = require("express")
const {clinicLogin, clinicRegister} = require("../controller/auth.js")
const router = Router()

router.post("/login", clinicLogin)
router.post("/register", clinicRegister)

module.exports = router
