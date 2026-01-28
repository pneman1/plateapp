---
sidebar_position: 5
---

# Use-Case Descriptions

## Use Case 1 - User Login

Actor: User

Triggering Event: User submits login credentials

#### Normal Flow:

1. User enters email and password.
2. System validates credentials by matching the credentials from the cloud storage.
3. System creates a secure session.
4. User is redirected to their profile or feed page.

#### Alternate Flow:

A. User enters wrong credentials
1. User forgets their login credentials
2. User enters invalid credentials
3. System recognizes the Invalid credential
4. System displays error message 
5. User tries to login several times with Invalid credentials
6. System notifies the user that the account is locked

B. User recovers credentials
1. User forgets their login credentials
2. User gets error message after entering in invalid credentials
3. System prompts user forgot password
4. User follows the prompt to submit their registered email address
5. System sends a password recovery link to the user's email
6. User follows the link and creates a new password.
7. System updates the user's credentials and confirms the reset.

==============================================================================================================---	

## Use Case 2 - Edit Profile

Actor: User

Triggering Event: 
User selects profile page

#### Normal Flow:

1. System displays editable profile fields.
2. User updates profile information.
3. User saves the profile changes.
4. System validates and stores updated data to the cloud storage.

#### Alternate Flow:

User Enters invalid data
1. User forgets their name
2. User enters some sequence of numbers on the input field
3. System outputs error for irrelevant data input
4. System prompts user to retry

==============================================================================================================---

## Use Case 3 - Plate Daily Upload

Actor: User

Triggering Event: 
A user receives a "Lunch" notification and taps it.

#### Normal Flow:

1. The User opens the app and activates the camera.
2. The System validates the camera feed to ensure a live capture.
3. The User snaps the photo and selects a suggested restaurant name.
4. The System uploads the photo to Cloud Storage and updates the database.


#### Alternate Flow: 

Late Post After Notification Window
1. The user receives a plate-related notification prompting them to post.
2. The notification window expires before the user submits a post.
3. The user submits a post after the notification window has closed.
4. The system identifies the submission as occurring outside the allowed time window.
5. The system marks the post as "Late."
6. The system applies a visual badge to the post when displayed in the feed.