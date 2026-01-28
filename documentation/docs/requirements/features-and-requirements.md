---
sidebar_position: 4
---

# Features and Requirements

## Functional Requirements

Notification System
Trends - (Cuisines, meals ate, restaurants visited)
Explore Page - Map, visual representation of photos your friends took. Can look at photos that were taken near you
Feed - Top down infinite scroll of photos your friends posted, scrolling past friends begins public feed
One photo a day, user can categorize it as whatever (breakfast, brunch, lunch, dinner, snack, etc.)
Profile System (User login)
User can filter through photos on the Explore Page
Users should be able to categorize their post as public vs private
Users should be able to view all their previously taken photos through their profile/memories tab

## Nonfunctional Requirements

Notified quickly/immediately after their friend posts a picture
Authentication - through Firebase Auth/AWS Amplify
User launches app -> Query our backend for feed -> All information that user needs is fetched during app launch
We want this app to be able to used on all iPhones
Photo upload should not take longer than 5 seconds
Application must be able to support at least 15 concurrent users
Our backend must be able to support at least 5 simultaneous photo uploads
The app will notify users if they haven't uploaded a photo in a while
Security: Communication must be handled via HTTPS. User data must be protected by Firestore Security Rules to prevent unauthorized access to blurred images.
Privacy: A "Ghost Mode" must be available to allow users to post to their friends without their exact coordinates appearing on the public heatmap.
If user posts a home cooked meal, they can choose to make the location not accurate (a radius)