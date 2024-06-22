import json
from flask import Flask, request
from db import db, User, Card, Deck, Class 
from flask_sqlalchemy import SQLAlchemy
from random import choice

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


#--------USERS--------#


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
  