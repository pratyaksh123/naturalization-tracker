
<img width="1026" height="554" alt="original" src="https://github.com/user-attachments/assets/d8587626-99b0-4044-a2e4-a2e8480ea6f0" />

## Inspiration
Navigating the complexities of U.S. citizenship requirements can be daunting for many immigrants. The idea for the US Citizenship Tracker app emerged from personal experiences and the need for a streamlined, reliable method to manage and track the essential criteria for naturalization, such as physical presence and travel history in one place.

<img width="762" height="805" alt="original (1)" src="https://github.com/user-attachments/assets/3d33af90-a30f-4364-bb3b-7c5847a6b8fb" />

## What it does
The US Citizenship Tracker is a mobile application designed to help users track their journey towards U.S. citizenship. It automates the importation of travel itineraries by allowing users to email their travel documents to a dedicated address. The app processes these emails, extracts relevant data using the GPT-3.5 API, and updates the user’s travel history in real time. It provides countdowns, eligibility tracking, and custom notifications to ensure users stay informed about their naturalization status.

<img width="1896" height="781" alt="original (2)" src="https://github.com/user-attachments/assets/d871d6be-b771-424e-85f3-cc9a86eb2543" />

## How I built it
My system is built on a robust architecture leveraging AWS, OpenAI's GPT models, Firebase, and Apple's CloudKit to ensure seamless data flow and synchronization:

- Email Reception and Processing: Utilizes Amazon SES to receive itinerary emails, which are then stored in S3. AWS Lambda functions are triggered to process these emails, extracting content using GPT-3.5 Turbo for initial data parsing.

- Data Normalization and Enhancement: In cases where the extracted data is incomplete, I employ GPT-4.0 Mini to refine and convert timestamps into standardized ISO formats, ensuring accuracy.

-Data Storage and Synchronization: Firebase Admin handles user data and authentication, storing trip data in Firestore. For users not signed in, data is stored locally using CloudKit to ensure continuity across sessions.

- User Interface and Notification System: The Firebase Cloud Messaging (FCM) system sends timely notifications to users about their citizenship process, leveraging data processed and stored across Firebase and CloudKit.

## Challenges I ran into
- Data Synchronization: Integrating CloudKit and Firestore presented a significant challenge due to my app’s design not requiring user sign-in for basic functionality. I implemented a system to sync data between the two services, ensuring data consistency whether the user is signed in (for auto-import features) or not.

- Incomplete Date Data: Handling itineraries without complete date information required sophisticated processing. I often encountered emails missing the year in the date field; my solution was to analyze the forwarded email sections using a more advanced GPT model to extract the missing data accurately.

- Data Sanitization: Initially, GPT-3.5 Turbo occasionally returned incomplete timestamps, which led me to integrate a secondary process using GPT-4.0 Mini to sanitize and convert these timestamps into a consistent ISO format, enhancing data reliability.

- App Store Approval: The process of releasing the app on the App Store for the first time was particularly challenging. Navigating the app review guidelines, allowing Apple to test the app's flow, addressing compliance issues, and ensuring the app met all the criteria for approval required substantial effort and learning.

## Accomplishments that I am proud of
- I successfully integrated multiple advanced technologies (AWS, OpenAI, Firebase, CloudKit) into a seamless service that significantly automates and simplifies the process of tracking travel for U.S. citizenship requirements.

- Overcoming the synchronization challenges between CloudKit and Firestore without requiring user sign-in for all features stands out as a significant technical achievement.

## What I learned
This project deepened my understanding of complex system integrations involving real-time data processing, cloud-based storage solutions, and advanced AI-driven text parsing. I also gained valuable insights into designing user-friendly applications that handle sensitive information with robust privacy and security measures.

