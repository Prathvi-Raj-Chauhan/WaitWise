const {verifyAccessToken} = require("../services/jwt")


function authenticate(req, res, next){
    const authHeader = req.headers.authorization
    let tryToken = null

    if(authHeader && authHeader.startsWith("Bearer ")){
        tryToken = req.headers.authorization?.split(" ")[1]; // looking for Bearer
    }
    else{
        tryToken = req.cookies?.token;
    }
    
    if(tryToken == null){
        return res.status(401).json({
            "status" : "unauthorized"
        })
    }
    const token = tryToken
    try {
        const payload = verifyAccessToken(token)
        req.user = payload
        next()
    } catch (e) {
        console.log(e.message);
        return res.status(401).json({
            status : "Unauthorized",
            error : "Invalid Token"
        })
    }
}

module.exports = {authenticate}