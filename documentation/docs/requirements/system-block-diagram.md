---
sidebar_position: 2
---

# System Block Diagram

![System Block Diagram](/img/Plate_SBD.png)

**Figure 1.**
High Level design of the Plate! application

## Description
Our application will contain the following tech stack:

Backend:
* Firebase
    * Firebase Firestore for our Database (users, post info, friends, comments, notifs, etc)
    * Firebase Auth for our Authentication system (Google/Apple sign in, makes authentication plug n play)
    * Firebase Storage for our Photo Storage (Firebase replacement of S3Bucket)
    * Firebase Notification SDK (Allows for users to be notified when outside of app)


Frontend:
* SwiftUI
    * AVFoundation/AVCam to access device camera
    * MapKit to implement a native map into the app, + allow for photos to be shown on map

(More to be hashed out)