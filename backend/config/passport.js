const passport = require('passport');
const GoogleStrategy = require('passport-google-oauth20').Strategy;
const User = require('../models/User');

/**
 * Configure Passport with Google OAuth 2.0 Strategy
 * 
 * Prerequisites:
 * 1. Create Google Cloud Project at https://console.cloud.google.com
 * 2. Enable Google+ API
 * 3. Create OAuth 2.0 credentials (Web application)
 * 4. Add authorized redirect URIs:
 *    - http://localhost:3000/api/auth/google/callback (development)
 *    - https://yourdomain.com/api/auth/google/callback (production)
 * 5. Add to .env:
 *    GOOGLE_CLIENT_ID=your_client_id
 *    GOOGLE_CLIENT_SECRET=your_client_secret
 */

// Only initialize Google OAuth if credentials are provided
if (process.env.GOOGLE_CLIENT_ID && process.env.GOOGLE_CLIENT_SECRET) {
  passport.use(
    new GoogleStrategy(
      {
        clientID: process.env.GOOGLE_CLIENT_ID,
        clientSecret: process.env.GOOGLE_CLIENT_SECRET,
        callbackURL: process.env.GOOGLE_CALLBACK_URL || 'http://localhost:3000/api/auth/google/callback',
        scope: ['profile', 'email'],
        passReqToCallback: true
      },
      async (req, accessToken, refreshToken, profile, done) => {
      try {
        // Extract user info from Google profile
        const { id: googleId, emails, displayName, photos } = profile;
        
        if (!emails || emails.length === 0) {
          return done(new Error('No email found in Google profile'), null);
        }

        const email = emails[0].value;
        const firstName = profile.name?.givenName || displayName.split(' ')[0];
        const lastName = profile.name?.familyName || displayName.split(' ').slice(1).join(' ');
        const avatar = photos && photos.length > 0 ? photos[0].value : null;

        // Check if user already exists with this Google ID
        let user = await User.findByGoogleId(googleId);

        if (user) {
          // User exists with Google ID - return user
          return done(null, user);
        }

        // Check if user exists with this email (linking account)
        user = await User.findByEmail(email);

        if (user) {
          // User exists with email - link Google account
          await User.linkGoogleAccount(user.id, googleId);
          user = await User.findById(user.id);
          return done(null, user);
        }

        // Create new user with Google account
        const newUserData = {
          email,
          firstName,
          lastName,
          googleId,
          avatar,
          emailVerified: true, // Google email is already verified
          role: 'customer'
        };

        user = await User.createFromGoogle(newUserData);
        return done(null, user);
      } catch (error) {
        console.error('Google Strategy error:', error);
        return done(error, null);
      }
    }
  )
);
} else {
  console.log('Google OAuth not configured - skipping Google Strategy initialization');
}

// Serialize user for session (optional - not needed for JWT)
passport.serializeUser((user, done) => {
  done(null, user.id);
});

// Deserialize user from session (optional - not needed for JWT)
passport.deserializeUser(async (id, done) => {
  try {
    const user = await User.findById(id);
    done(null, user);
  } catch (error) {
    done(error, null);
  }
});

module.exports = passport;
