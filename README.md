Run project: "flutter run"

NOTE:
- Clock-in data is saved to sqlite database (latitude, longitude, time, note, and image).
- User data (authentication) is NOT made with sqlite but with Firebase. The reason is because sqlite does not require authentication.
- Push notification is not functional because Firebase require user to pay to use such function.