const bcrypt = require("bcrypt")
const crypto = require("crypto");

async function generateHash(password){
    return bcrypt.hash(password, 12)
}
async function compareHash(password, hash){
    return bcrypt.compare(password, hash);
}
function hashToken(token) {
  return crypto.createHash("sha256").update(token).digest("hex")
}

module.exports = {
    generateHash,
    compareHash,
    hashToken
}