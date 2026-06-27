const {Router} = require("express")
const {clinicLogin, clinicRegister} = require("../controller/auth.js")
const {authenticate} = require("../middleware/auth.js")
const router = Router()

router.post("/login", clinicLogin)
router.post("/register", clinicRegister)


router.post("/me",  authenticate, (req, res) => {
    return res.status(200).json({
        status : "verified"
    }); 
})
module.exports = router
