import json
import os
from flask import Flask, request
from flask.cli import load_dotenv
from db import db, User, Card, Deck, Class 
from flask_sqlalchemy import SQLAlchemy
from random import choice

import asyncio
from hume import HumeVoiceClient, MicrophoneInterface, VoiceSocket

message_counter = 0

# ================================================
# Event Handlers
#
# These can be used to specify behavior when interfacing with the WebSocket.
#
# They can be synchronous (i.e. def handler: ...)
# or asynchronous (i.e. async def handler: ...) and awaitable.
# Both allow for dynamic updating of application state using global variables.
# Asynchronous handlers enable awaitable actions, such as transmitting data
# to a database.
#
# There are 4 handlers: on_open, on_message, on_error, and on_close.
#
# on_open: what happens when the WebSocket opens.
#
# on_message: what happens when a message is received.
# --> You can create conditional behavior to execute based on the type of message.
# --> Below are the types of messages you can receive, and their data:
# https://dev.hume.ai/reference/empathic-voice-interface-evi/chat/chat#receive
#
# on_error: what happens when an error occurs.
#
# on_close: what happens when the WebSocket closes.
# 
# ================================================

# Handler for when the connection is opened
def on_open():
    # Print a welcome message using ASCII art
    print("Say hello to EVI, Hume AI's Empathic Voice Interface!")

# Handler for incoming messages
def on_message(message):
    global message_counter
    # Increment the message counter for each received message
    message_counter += 1
    msg_type = message["type"]

    # Start the message box with the common header
    message_box = (
        f"\n{'='*60}\n"
        f"Message {message_counter}\n"
        f"{'-'*60}\n"
    )

    # Add role and content for user and assistant messages
    if msg_type in {"user_message", "assistant_message"}:
        role = message["message"]["role"]
        content = message["message"]["content"]
        message_box += (
            f"role: {role}\n"
            f"content: {content}\n"
            f"type: {msg_type}\n"
        )

        # Add top emotions if available
        if "models" in message and "prosody" in message["models"]:
            scores = message["models"]["prosody"]["scores"]
            num = 3
            # Get the top N emotions based on the scores
            top_emotions = get_top_n_emotions(prosody_inferences=scores, number=num)

            message_box += f"{'-'*60}\nTop {num} Emotions:\n"
            for emotion, score in top_emotions:
                message_box += f"{emotion}: {score:.4f}\n"

    # Add all key-value pairs for other message types, excluding audio_output
    elif msg_type != "audio_output":
        for key, value in message.items():
            message_box += f"{key}: {value}\n"
    else:
        message_box += (
            f"type: {msg_type}\n"
        )

    message_box += f"{'='*60}\n"
    # Print the constructed message box
    print(message_box)

# Function to get the top N emotions based on their scores
def get_top_n_emotions(prosody_inferences, number):
    # Sort the inferences by their scores in descending order
    sorted_inferences = sorted(prosody_inferences.items(), key=lambda item: item[1], reverse=True)
    # Return the top N inferences
    return sorted_inferences[:number]

# Handler for when an error occurs
def on_error(error):
    # Print the error message
    print(f"Error: {error}")

# Handler for when the connection is closed
def on_close():
    # Print a closing message using ASCII art
    print("Thank you for using EVI, Hume AI's Empathic Voice Interface!")

# ================================================
# User Input Handler
#
# Using an asynchronous input handler allows the program
# to simultaneously receive user input (such as text to send to EVI)
# and the messages with which EVI responds.
# ================================================

# Asynchronous handler for user input
async def user_input_handler(socket: VoiceSocket):
    while True:
        # Asynchronously get user input to prevent blocking other operations
        user_input = await asyncio.to_thread(input, "Type a message to send or 'Q' to quit: ")
        if user_input.strip().upper() == "Q":
            # If user wants to quit, close the connection
            print("Closing the connection...")
            await socket.close()
            break
        else:
            # Send the user input as text to the socket
            await socket.send_text_input(user_input)


async def main() -> None:
    try:
        # Retrieve any environment variables stored in the .env file
        load_dotenv()
        # Retrieve the Hume API key from the environment variables
        HUME_API_KEY = os.getenv("HUME_API_KEY")
        HUME_SECRET_KEY = os.getenv("HUME_SECRET_KEY")

        # Connect and authenticate with Hume
        client = HumeVoiceClient('v9568Gqf2fKI0hJKCBAEGNZDGW7ysf2DotlAzK67DNXArynH', 'A9mhPPHxgArA1BytVFzcSRYsgN88N3Z5vj5MagvQjpEXR8unbPGSG6ntzIsRpGKi')

        # Start streaming EVI over your device's microphone and speakers
        async with client.connect_with_handlers(
            on_open=on_open,                # Handler for when the connection is opened
            on_message=on_message,          # Handler for when a message is received
            on_error=on_error,              # Handler for when an error occurs
            on_close=on_close,              # Handler for when the connection is closed
            enable_audio=True,              # Flag to enable audio playback (True by default)
        ) as socket:
            # Start the microphone interface in the background; add "device=NUMBER" to specify device
            microphone_task = asyncio.create_task(MicrophoneInterface.start(socket))

            # Start the user input handler
            user_input_task = asyncio.create_task(user_input_handler(socket))

            # The gather function is used to run both async tasks simultaneously
            await asyncio.gather(microphone_task, user_input_task)
    except Exception as e:
        # Catch and print any exceptions that occur
        print(f"Exception occurred: {e}")

# define db filename
db_filename = "todo.db"
app = Flask(__name__)

# setup config
app.config["SQLALCHEMY_DATABASE_URI"] = f"sqlite:///{db_filename}"
app.config["SQLALCHEMY_TRACK_MODIFICATIONS"] = False
app.config["SQLALCHEMY_ECHO"] = True

# initialize app
db.init_app(app)
with app.app_context():
    db.create_all()
    Class.create_hardcoded_classes()

# generalized response formats
def success_response(data, code=200):
    return json.dumps({"success": True, "data": data}), code

def failure_response(message, code=404):
    return json.dumps({"success": False, "error": message}), code

# your routes here

@app.route("/")
def hello_world():
    return "Hello, World!"

@app.route("/api/chat", methods=["POST"])
def send_chat():
    asyncio.run(main())

#--------USERS--------
"""
Route to create the user. Returns error code 400 if no usernmae or password provided in 
request body, otherwise makes the new User, commits it to the database, and
returns a 201 success code along with the serialization.
"""
@app.route("/api/users/", methods=["POST"])
def create_user():
    body = json.loads(request.data)
    username = body.get('username')
    # these checks are in case front-end doesn't handle clicking without filling a field.
    if username is None:
        return failure_response("No username provided", 400)
    password = body.get('password')
    if password is None:
        return failure_response("No password provided", 400)
    
    # TODO (for future): check if username already exists

    new_user = User(username=username, password=password) #create new Course object with given code and name
    db.session.add(new_user) #add object to sqlAlchemy session and commit to database. This is effectively one row in courses table
    db.session.commit()
    return success_response(new_user.serialize(), 201)

"""
Returns serialization all users in User
"""
@app.route("/api/users/", methods=["GET"])
def get_users():
    #note query.all() returns every value in this query as a list. 
    users = [c.serialize() for c in User.query.all()] 
    return success_response(users)

"""
Returns serialization of an updated user who changed their password
"""
@app.route("/api/users/<int:user_id>/update/", methods=["POST"])
def change_password(user_id):
    body = json.loads(request.data)
    password = body.get('password')
    if password is None:
        return failure_response("No new password provided", 400)

    user = User.query.get(user_id)
    if user is None:
        return failure_response("User not found")
    user.password = password
    db.session.commit()
    return success_response(user.serialize())

"""
Deletes a user given user_id. If user is not found, returns 404 error code.
"""
@app.route("/api/users/<int:user_id>/", methods=["DELETE"])
def delete_user(user_id):
    user = User.query.get(user_id)
    if user is None:
        return failure_response("User not found")
    db.session.delete(user)
    db.session.commit()
    return success_response(user.serialize())

"""
Check if user with provided username and password exists. If does, then returns serialized form in success response 200, else "no such user" message with 400 code.
"""
@app.route("/api/users/login/", methods=["POST"])
def get_spec_user():
    #assuming the data is being passed in through login fields
    body = json.loads(request.data)
    username = body.get('username')
    password = body.get('password')

    #these checks are in case front-end doesn't handle clicking without filling a field.
    if username is None:
        return failure_response("No username provided", 400)
    if password is None:
        return failure_response("No password provided", 400)
    user_val = User.query.filter(User.username==username, User.password==password).first()
    if user_val is None:
        return failure_response("false", 400)
    else:
        return success_response("true", 200)


#-------CLASSES--------#



"""
Returns serialization all classes in Class. Note this will return the information of 3 classes of CS 2110, CS 3110, and CS 1998 due to hard-code function
but additionally associated deck information
"""
@app.route("/api/classes/", methods=["GET"])
def get_classes():
    #note query.all() returns every value in this query as a list. 
    classes = [c.serialize() for c in Class.query.all()] 
    return success_response(classes)


#--------DECKS--------#


"""
Returns serialization of all decks in a class that are either public or private and created by the logged-in user.
"""
@app.route("/api/users/<int:user_id>/classes/<int:class_id>/decks/", methods=["GET"])
def get_class_decks(user_id, class_id):
    desired_class = Class.query.get(class_id) #note 0, 1, and 2 class id numbering
    if desired_class is None:
        return failure_response("No such class", 400)
    
    #First condition -- decks must be associated with the class. Second condition --
    #deck is either public, or it is private and associated with the user_id.
    #Note use of & and | needed since SQL uses bitwise operators
    filter_decks = Deck.query.filter(
        (Deck.class_id == class_id) &
        ((Deck.is_public == True) | ((Deck.is_public == False) & (Deck.user_id == user_id)))
    ).all()

    serialized_rel_decks = [c.serialize() for c in filter_decks]
    return success_response(serialized_rel_decks)


"""
Returns random quiz mode of 3 cards in each decks within the class
"""
@app.route("/api/users/<int:user_id>/classes/<int:class_id>/decks/quiz_mode", methods=["GET"])
def quiz_mode(class_id, user_id):
    desired_class = Class.query.get(class_id) #note 0, 1, and 2 class id numbering
    if desired_class is None:
        return failure_response("No such class", 400)
    
    #we get all public decks within the class or private and owned by this user.
    filter_decks = Deck.query.filter(
        (Deck.class_id == class_id) &
        ((Deck.is_public == True) | ((Deck.is_public == False) & (Deck.user_id == user_id)))
    ).all()

    # Helper function, the deck itself is passed in, not its id
    def pick_card_from_deck(deck_val):
        cards = deck_val.cards
        card_output = choice(cards) #from random library
        return card_output.serialize() # want serialized form of card



    random_card_lot = []
    for deck_val in filter_decks:
        for i in range(3): 
            #we want to pick a random card each iteration -- and add to random_card_lot for each.
            random_card_lot.append(pick_card_from_deck(deck_val))
    return success_response(random_card_lot)





"""
Creates a new deck given class_id, user_id, and title. 
"""
@app.route("/api/users/<int:user_id>/classes/<int:class_id>/decks/", methods=["POST"])
def create_deck(user_id, class_id):
    body = json.loads(request.data)
    title = body.get('title')
    # May add description property for Deck in the future
    if title is None:
        return failure_response("No title provided", 400)
    if user_id is None:
        return failure_response("No user_id provided", 400)

    user = User.query.get(user_id)
    if user is None:
        return failure_response("User not found")

    # Might make deck private by default, but for now, it is public.
    new_deck = Deck(title=title, class_id=class_id, user_id=user_id, is_public=True) 
    db.session.add(new_deck)
    db.session.commit()
    return success_response(new_deck.serialize(), 201)
    

"""
Deletes a deck given deck_id. If deck is not found, returns 404 error code.
"""
@app.route("/api/decks/<int:deck_id>/", methods=["DELETE"])
def delete_deck(deck_id):
    deck = Deck.query.get(deck_id)
    if deck is None:
        return failure_response("Deck not found")
    db.session.delete(deck)
    db.session.commit()
    return success_response(deck.serialize())


"""
Change the privacy of a deck given deck_id. If deck is not found, returns 404 error code.
"""
@app.route("/api/decks/<int:deck_id>/privacy/", methods=["POST"])
def change_privacy(deck_id):
    deck = Deck.query.get(deck_id)
    if deck is None:
        return failure_response("Deck not found")
    body = json.loads(request.data)
    is_public = body.get('is_public')
    if is_public is None:
        return failure_response("No is_public provided", 400)
    deck.is_public = is_public
    db.session.commit()
    return success_response(deck.serialize())


#--------CARDS--------#

"""
Creates a new card given deck_id, question, and answer. 
"""
@app.route("/api/decks/<int:deck_id>/cards/", methods=["POST"])
def create_card(deck_id):
    body = json.loads(request.data)
    question = body.get('question')
    answer = body.get('answer')
    if question is None:
        return failure_response("No question provided", 400)
    if answer is None:
        return failure_response("No answer provided", 400)

    deck = Deck.query.get(deck_id)
    if deck is None:
        return failure_response("Deck not found")
    new_card = Card(question=question, answer=answer, deck_id=deck_id)
    db.session.add(new_card)
    db.session.commit()
    return success_response(new_card.serialize(), 201)

"""
Returns serialization of all cards in a deck.
"""
@app.route("/api/decks/<int:deck_id>/cards/", methods=["GET"])
def get_cards(deck_id):
    deck = Deck.query.get(deck_id)
    if deck is None:
        return failure_response("Deck not found")
    cards = [c.serialize() for c in deck.cards]
    return success_response(cards)

"""
Get a single card given card_id. If card is not found, returns 404 error code.
"""
@app.route("/api/cards/<int:card_id>/", methods=["GET"])
def get_card(card_id):
    card = Card.query.get(card_id)
    if card is None:
        return failure_response("Card not found")
    return success_response(card.serialize())


"""
Updates a card given card_id. If card is not found, returns 404 error code.
'question' or 'answer' paramaters can be empty.
"""
@app.route("/api/cards/<int:card_id>/", methods=["POST"])
def update_card(card_id):
    card = Card.query.get(card_id)
    if card is None:
        return failure_response("Card not found")
    body = json.loads(request.data)
    question = body.get('question')
    answer = body.get('answer')
    if question is not None:
        card.question = question
    if answer is not None:
        card.answer = answer
    db.session.commit()
    return success_response(card.serialize())


"""
Deletes a card given card_id. If card is not found, returns 404 error code.
"""
@app.route("/api/cards/<int:card_id>/", methods=["DELETE"])
def delete_card(card_id):
    card = Card.query.get(card_id)
    if card is None:
        return failure_response("Card not found")
    db.session.delete(card)
    db.session.commit()
    return success_response(card.serialize())

# run the app
if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8000, debug=True)
  