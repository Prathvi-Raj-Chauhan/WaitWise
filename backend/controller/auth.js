const {db} = require("../db");
const { eq } = require("drizzle-orm");
const {refreshTokens, clinic, patient, appointment} = require("../db/schema");

const {
  generateAccessToken,
  generateRefreshToken,
  verifyRefreshToken,
} = require("../services/jwt");
const { 
    generateHash,
    compareHash,
    hashToken
} = require("../services/hash");


async function generateTokens(user) {

  const payload = { userId: user.id, email: user.email };
  const accessToken = generateAccessToken(payload);
  const refreshToken = generateRefreshToken(payload);
  const tokenHash = hashToken(refreshToken);

  const expiresAt = new Date();
  expiresAt.setDate(expiresAt.getDate() + 7);

  await db.insert(refreshTokens).values({
    clinic_id: user.id,
    tokenHash,
    expiresAt,
  });

  return { accessToken, refreshToken };
}

async function clinicRegister(req, res) {
  try {
    const { email, password, name } = req.body;
    if (!email || !password || !name) {
        return res.status(400).json({
            "Error" : "Email, password are required"
        })
    }
    
    if (password.length < 8) {
        return res.status(400).json({
            "Error" : "Password must be atleast 8 characters long"
        })
    }

    const existing = await db
      .select()
      .from(clinic)
      .where(eq(clinic.email, email)) // checks equality
      .limit(1);
    
    if(existing.length >0){
        return res.status(409).json({
            error : "Email already Registered"
        })
    }
    const hashedPassword = await generateHash(password)
    
    const [user] = await db.insert(clinic).values({email, passwordHash : hashedPassword, name}).returning()

    const tokens = await generateTokens(user)
    
    const {passwordHash, ...safe} = user
    const sanitisedUser = safe;

    res.cookie("token", tokens.accessToken, {
        httpOnly : true,
        sameSite: "lax",
        secure: false
    })
    return res.status(201).json({
        "message" : "Successfully Registered",
        "user" : sanitisedUser,
        ...tokens
    })
  } catch (e) {
    return res.status(500).json({
        "Error" : "Server Error",
        "e" : e.message
    })
  }
}

async function clinicLogin(req, res) {
  try {
    const { email, password } = req.body;
    if (!email || !password) {
        return res.status(400).json({
            "Error" : "Email, password are required"
        })
    }
    
    if (password.length < 8) {
        return res.status(400).json({
            "Error" : "Password must be atleast 8 characters"
        })
    }

    const [clinicData] = await db
    .select()
    .from(clinic)
    .where(eq(clinic.email, email))
    .limit(1);
    
    if(!clinicData){
        return res.status(401).json({
            error : "Invalid Email or Password"
        })
    }
    if(!clinicData.passwordHash){
        return res.status(401).json({
            error : "This account is logged in with google"
        })

    }
    const valid = await compareHash(password, clinicData.passwordHash)
    if(!valid){
        return res.status(401).json({
            error: "Invalid email or password"
        })
    }

    const tokens = await generateTokens(clinicData)
    
    const {passwordHash, ...safe} = clinicData
    const sanitisedClinic = safe;
    res.cookie("token", tokens.accessToken, {
        httpOnly : true,
        sameSite: "lax",
        secure: false
    })
    return res.status(200).json({
        "message" : "Successfully Logged in",
        "clinic" : sanitisedClinic,
        ...tokens
    })
  } catch (e) {
    return res.status(500).json({
        "Error" : "Server Error",
        "e" : e.message
    })
  }
}

async function registerPatientByClinic(req, res){
    try {
        const {name, age, gender, mobile} = req.body
        if(!name || !mobile || !gender || age == null){
            return res.status(400).json({
                "Error" : "Name, Mobile, Gender, Age and Clinic Id are required"
            })
        }
        const existing = await db.select().from(patient).where(eq(patient.mobile, mobile)).limit(1);

        if(existing.length > 0){
            return res.status(409).json({
                "error" : "Mobile number already registered for some patient",
                "patientName" : existing[0].name
            })
        }

        const [newPatient] = await db.insert(patient).values({
            name,
            mobile,
            age,
            gender,
        }).returning();
        
        return res.status(201).json({
            "message" : "Patient Registration Successful",
            "patient" : newPatient,
        })
    } catch (e) {
        return res.status(500).json({
            "Error" : "Server Error",
            "e" : e.message
        })
    }
}

async function createAppointmentAndAddPatient(req, res){
    try {
        const {mobile, clinic_id} = req.body 
        const existing = await db.select().from(patient).where(eq(patient.mobile, mobile)).limit(1);

        if(existing.length <= 0){
            return res.status(404).json({
                "error" : "Patient does not exist, register Patient first !",
            })
        }
        const [new_appointment] = await db.insert(appointment).values({patient_id : existing[0].id, clinic_id, status : "pending" }).returning()
        return res.status(201).json({
            "message" : "Appinted successfully",
            appointment : new_appointment
        })
    } catch (e) {
        
    }
}

