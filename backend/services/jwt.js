const JWT = require("jsonwebtoken")

const crypto = require("crypto")

const ACCESS_TOKEN_SECRET = process.env.ACCESS_TOKEN_SECRET
const REFRESH_TOKEN_SECRET = process.env.REFRESH_TOKEN_SECRET

const ACCESS_TOKEN_EXPIRY = "1d";
const REFRESH_TOKEN_EXPIRY = "7d";


function generateAccessToken(payload){
    return JWT.sign(payload, ACCESS_TOKEN_SECRET, {
        expiresIn : ACCESS_TOKEN_EXPIRY
    })
}


function generateRefreshToken(payload){
    return JWT.sign(payload, REFRESH_TOKEN_SECRET, {
        expiresIn : REFRESH_TOKEN_EXPIRY,
        jwtid : crypto.randomBytes(16).toString("hex")
    })
}

function verifyAccessToken(token) {
  return JWT.verify(token, ACCESS_TOKEN_SECRET);
}

function verifyRefreshToken(token) {
  return JWT.verify(token, REFRESH_TOKEN_SECRET);
}

module.exports = {
    generateAccessToken,
    generateRefreshToken,
    verifyAccessToken,
    verifyRefreshToken,
};