## This is Ambrose AI! 

Named after an amazing TA for an intermediate Computer Science Course at Cornell, Amrbrose AI's main purpose is to serve as a teaching assistant in your pocket, allowing 
students to ask difficult questions to Ambrose and recieve real-time responses in their preference of voice or text-communication. 

## Design/Conceptual Model 💡

<img width="634" alt="Screenshot 2024-09-05 at 10 34 19 PM" src="https://github.com/user-attachments/assets/44bddddd-2603-45ae-9802-282a0645b270">

## How do we do this? 🧐

Great question! 

Let's break this down:

Voice-Voice Communication:

This functionality is a bit of a work in-progress, however, as of now we're doing a two way data crunching process where we send in our transcribed voice data using OpenAI's Speech-to-Text
API and then instantaneously send this text through Eleven Lab's Text-to-Speech API which provides a response in real-time.

We also want to store and display this conversation between the user and Ambrose, so it's important that we keep this data from the user's audio transcription, and keep the text response that 
Eleven Labs gives us prior to processing the text to audio

Chat Communication for Problem Solving:

This one is a bit more simple and commonly done, but nonetheless we focused a bit too much on our voice-to-voice implementation 🙈

We wanted an API that utilized cutting edge AI software to give detailed answers, so Perplexity and Meta's llama model was a great choice for us. This time, we simply need to send a query to perplexity, 
and store both our query and the response in a chat log

## Frontend + Other Functionality 📲

Regarding the design, we wanted to do something that felt extremely easy to use, hence the few buttons and cool colors.

I don't believe the design is properly translated to the app because I really wanted to get some of the features working more than anything, and there's a lot of frontend code that's also unused in the current product/ demo

Nonetheless, I developed the frontend entirely in SwiftUI, and tried to stay conscious of common practices and protocols, as the amount of files I ended up working with was far worse than I expected.
I strived to utilize functions in repeatable portions of code, and conform to MVVM architecture in my project structure as much as I knew how. 

Many of the other features are pretty straightforward, but I'm pretty excited that the data for adding courses and configurations (shown in demo) persists throughout the lifetime of the app, 
and I love the clickable scroll views in the growth space page. 

## Final Thoughts + Progress + Demo💭

Honestly, this project was extremely difficult and it's no wonder that we struggled so much during our hackathon. Nonetheless, this project taught me a lot about how to utilize all of the cool open source
technology (AI or not) that can be used in my projects, and I also got exposed to AVFoundation for the first time, a Swift framework for using audio and working with voice input in your projects. Beyond this, 
I was also able to explore other features (many didn't make it) that Swift has such as animations, and I'm so excited about where I'll go next.

I plan to continue working on and understanding this project with my teammates when I get some time off, and I'm pretty proud of our persistance.

ALSO! 

Peep the updates, this is the original devpost from the hackathon (includes a demo)
https://devpost.com/software/ambrose-ai?ref_content=user-portfolio&ref_feature=in_progress

Here's the current state:
https://youtu.be/XpuuXzIDe-E

