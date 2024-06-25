import os
import json
import requests
import asyncio
import subprocess
from flask import Flask, request, jsonify
from db import db, User, Card, Deck, Class
from flask_sqlalchemy import SQLAlchemy
from random import choice
from flask_cors import CORS
from dotenv import load_dotenv
import base64
from hume_client import (
    hume_main,
    received_messages,
    send_message_to_hume,
    close_hume_socket,
)

# Load environment variables from .env file
load_dotenv()

# define db filename
db_filename = "todo.db"
app = Flask(__name__)
CORS(app)

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


# Global variable for chat session
chat_session_active = False


# Generate Client ID for Token Authentication
def generate_client_id(api_key, secret_key):
    auth_string = f"{api_key}:{secret_key}"
    client_id = base64.b64encode(auth_string.encode()).decode()
    return client_id


# Fetch Access Token
def fetch_access_token(client_id):
    url = "https://api.hume.ai/oauth2-cc/token"
    headers = {
        "Content-Type": "application/x-www-form-urlencoded",
        "Authorization": f"Basic {client_id}",
    }
    data = {"grant_type": "client_credentials"}
    response = requests.post(url, headers=headers, data=data)
    response_data = response.json()
    access_token = response_data.get("access_token")
    return access_token


api_key = os.getenv("HUME_API_KEY")
secret_key = os.getenv("HUME_SECRET_KEY")
client_id = generate_client_id(api_key, secret_key)
access_token = fetch_access_token(client_id)


# your routes here


@app.route("/")
def hello_world():
    return "Hello, World!"


# -------Hume_AI--------#
@app.route("/api/start_chat", methods=["POST"])
def start_chat():
    global chat_session_active, received_messages, hume_task
    if chat_session_active:
        return failure_response("Chat session already active", 400)

    try:
        received_messages.clear()
        chat_session_active = True
        loop = asyncio.new_event_loop()
        asyncio.set_event_loop(loop)
        hume_task = loop.create_task(hume_main())
        loop.run_until_complete(hume_task)
        return success_response("Chat session started", 200)
    except Exception as e:
        return failure_response(str(e), 500)


@app.route("/api/send_chat", methods=["POST"])
def send_chat():
    global chat_session_active
    if not chat_session_active:
        return failure_response("No active chat session", 400)

    try:
        user_message = request.json.get("message")
        if not user_message:
            return failure_response("No message provided", 400)

        loop = asyncio.new_event_loop()
        asyncio.set_event_loop(loop)
        loop.run_until_complete(send_message_to_hume(user_message))
        return success_response(received_messages, 200)
    except Exception as e:
        return failure_response(str(e), 500)


@app.route("/api/stop_chat", methods=["POST"])
def stop_chat():
    global chat_session_active, hume_task
    if not chat_session_active:
        return failure_response("No active chat session to stop", 400)

    chat_session_active = False
    if hume_task:
        hume_task.cancel()

    try:
        loop = asyncio.new_event_loop()
        asyncio.set_event_loop(loop)
        loop.run_until_complete(close_hume_socket())
        return success_response(received_messages, 200)
    except asyncio.CancelledError:
        return success_response(received_messages, 200)
    except Exception as e:
        return failure_response(str(e), 500)


# Health Check endpoint
@app.route("/health", methods=["GET"])
def health():
    return success_response("Server is running", 200)


# Chat endpoint to interact with Hume client
@app.route("/api/chat", methods=["POST"])
def get_chat():
    try:
        # Clear the received_messages list before starting
        received_messages.clear()

        asyncio.run(hume_main())

        return success_response(received_messages, 200)
    except Exception as e:
        return failure_response(str(e), 500)


@app.route("/api/fetch_educational_resources", methods=["POST"])
def fetch_educational_resources():
    data = request.json
    topic = data.get("topic")
    if not topic:
        return failure_response("No topic provided", 400)

    api_key = os.getenv("YOU_API_KEY")
    url = "https://api.ydc-index.io/search"
    headers = {"X-API-Key": api_key}
    params = {
        "query": topic,
        "num_web_results": 5,  # Adjust the number of results as needed
    }

    response = requests.get(url, headers=headers, params=params)
    if response.status_code != 200:
        return failure_response("Failed to fetch educational resources", 500)

    resources = response.json().get("hits", [])
    return success_response(resources)


@app.route("/api/chat_history", methods=["GET"])
def chat_history():
    return success_response(received_messages)


# --------USERS--------#


"""
Route to create the user. Returns error code 400 if no usernmae or password provided in 
request body, otherwise makes the new User, commits it to the database, and
returns a 201 success code along with the serialization.
"""


@app.route("/api/users/", methods=["POST"])
def create_user():
    body = json.loads(request.data)
    username = body.get("username")
    # these checks are in case front-end doesn't handle clicking without filling a field.
    if username is None:
        return failure_response("No username provided", 400)
    password = body.get("password")
    if password is None:
        return failure_response("No password provided", 400)

    # TODO (for future): check if username already exists

    new_user = User(
        username=username, password=password
    )  # create new Course object with given code and name
    db.session.add(
        new_user
    )  # add object to sqlAlchemy session and commit to database. This is effectively one row in courses table
    db.session.commit()
    return success_response(new_user.serialize(), 201)


@app.route("/api/chat_history", methods=["GET"])
def get_chat_history():
    return success_response(received_messages)


"""
Returns serialization all users in User
"""


@app.route("/api/users/", methods=["GET"])
def get_users():
    # note query.all() returns every value in this query as a list.
    users = [c.serialize() for c in User.query.all()]
    return success_response(users)


"""
Returns serialization of an updated user who changed their password
"""


@app.route("/api/users/<int:user_id>/update/", methods=["POST"])
def change_password(user_id):
    body = json.loads(request.data)
    password = body.get("password")
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
    # assuming the data is being passed in through login fields
    body = json.loads(request.data)
    username = body.get("username")
    password = body.get("password")

    # these checks are in case front-end doesn't handle clicking without filling a field.
    if username is None:
        return failure_response("No username provided", 400)
    if password is None:
        return failure_response("No password provided", 400)
    user_val = User.query.filter(
        User.username == username, User.password == password
    ).first()
    if user_val is None:
        return failure_response("false", 400)
    else:
        return success_response("true", 200)


# -------CLASSES--------#


"""
Returns serialization all classes in Class. Note this will return the information of 3 classes of CS 2110, CS 3110, and CS 1998 due to hard-code function
but additionally associated deck information
"""


@app.route("/api/classes/", methods=["GET"])
def get_classes():
    # note query.all() returns every value in this query as a list.
    classes = [c.serialize() for c in Class.query.all()]
    return success_response(classes)


# --------DECKS--------#


"""
Returns serialization of all decks in a class that are either public or private and created by the logged-in user.
"""


@app.route("/api/users/<int:user_id>/classes/<int:class_id>/decks/", methods=["GET"])
def get_class_decks(user_id, class_id):
    # note 0, 1, and 2 class id numbering
    desired_class = Class.query.get(class_id)
    if desired_class is None:
        return failure_response("No such class", 400)

    # First condition -- decks must be associated with the class. Second condition --
    # deck is either public, or it is private and associated with the user_id.
    # Note use of & and | needed since SQL uses bitwise operators
    filter_decks = Deck.query.filter(
        (Deck.class_id == class_id)
        & (
            (Deck.is_public == True)
            | ((Deck.is_public == False) & (Deck.user_id == user_id))
        )
    ).all()

    serialized_rel_decks = [c.serialize() for c in filter_decks]
    return success_response(serialized_rel_decks)


"""
Returns random quiz mode of 3 cards in each decks within the class
"""


@app.route(
    "/api/users/<int:user_id>/classes/<int:class_id>/decks/quiz_mode", methods=["GET"]
)
def quiz_mode(class_id, user_id):
    # note 0, 1, and 2 class id numbering
    desired_class = Class.query.get(class_id)
    if desired_class is None:
        return failure_response("No such class", 400)

    # we get all public decks within the class or private and owned by this user.
    filter_decks = Deck.query.filter(
        (Deck.class_id == class_id)
        & (
            (Deck.is_public == True)
            | ((Deck.is_public == False) & (Deck.user_id == user_id))
        )
    ).all()

    # Helper function, the deck itself is passed in, not its id
    def pick_card_from_deck(deck_val):
        cards = deck_val.cards
        card_output = choice(cards)  # from random library
        return card_output.serialize()  # want serialized form of card

    random_card_lot = []
    for deck_val in filter_decks:
        for i in range(3):
            # we want to pick a random card each iteration -- and add to random_card_lot for each.
            random_card_lot.append(pick_card_from_deck(deck_val))
    return success_response(random_card_lot)


"""
Creates a new deck given class_id, user_id, and title. 
"""


@app.route("/api/users/<int:user_id>/classes/<int:class_id>/decks/", methods=["POST"])
def create_deck(user_id, class_id):
    body = json.loads(request.data)
    title = body.get("title")
    # May add description property for Deck in the future
    if title is None:
        return failure_response("No title provided", 400)
    if user_id is None:
        return failure_response("No user_id provided", 400)

    user = User.query.get(user_id)
    if user is None:
        return failure_response("User not found")

    # Might make deck private by default, but for now, it is public.
    new_deck = Deck(title=title, class_id=class_id,
                    user_id=user_id, is_public=True)
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
    is_public = body.get("is_public")
    if is_public is None:
        return failure_response("No is_public provided", 400)
    deck.is_public = is_public
    db.session.commit()
    return success_response(deck.serialize())


# --------CARDS--------#

"""
Creates a new card given deck_id, question, and answer. 
"""


@app.route("/api/decks/<int:deck_id>/cards/", methods=["POST"])
def create_card(deck_id):
    body = json.loads(request.data)
    question = body.get("question")
    answer = body.get("answer")
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
    question = body.get("question")
    answer = body.get("answer")
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
