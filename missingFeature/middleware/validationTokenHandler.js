import jwt from "jsonwebtoken";

export const validateToken = async (req, res, next) => {
    try { 
        let token;
        let authHeader = req.headers.authorization || req.headers.Authorization 
        if (authHeader && authHeader.startsWith("Bearer")) {
            token = authHeader.split(" ")[1];
            if (!token) {
                return res.status(401).json({ error: "User is not authorized or token is missing" });
            }
            jwt.verify(token, process.env.ACCESS_TOKEN_SECRET, (err, decoded) => {
                if (err) {
                    return res.status(401).json({ error: "User is not authorized" });
                }
                req.user = decoded.user;
                next();
            });
        } else {
            return res.status(401).json({ error: "Authorization header missing or invalid" });
        }
    } catch (error) {
        return res.status(500).json({ error: "Server error in validation" });
    }
};
