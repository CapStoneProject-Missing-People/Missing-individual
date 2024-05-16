// Middleware to restrict access to the logging API
export const logApiMiddleware = (req, res, next) => {
    const referringUrl = req.header('Referer');
    if (referringUrl && referringUrl.startsWith('http://localhost:5000/recognize')) {
      next(); // Allow access if the request is from localhost:5000/recognize
    } else {
      res.status(403).json({ error: 'Forbidden' }); // Deny access otherwise
    }
  };