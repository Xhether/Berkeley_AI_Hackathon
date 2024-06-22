from flask_sqlalchemy import SQLAlchemy

db = SQLAlchemy()

# Note: One-to-many relationship from users to decks, classes to decks, and decks to cards
# Note: db.relationship for "one" scope, and foreign keys for "many" scope

class Deck(db.Model):
    """
    Deck Model
    """
    __tablename__ = 'decks'
    id = db.Column(db.Integer, primary_key=True)
    title = db.Column(db.String, nullable=False)
    cards = db.relationship('Card', cascade="delete") #relates deck to cards table
    user_id = db.Column(db.Integer, db.ForeignKey('users.id'), nullable=False) 
    class_id = db.Column(db.Integer, db.ForeignKey('classes.id'), nullable=False)
    is_public = db.Column(db.Boolean, nullable=False)
    
    def serialize(self):
        return {
            'id': self.id,
            'user_id' : self.user_id,
            'class_id': self.class_id,
            'title': self.title,
            'is_public': self.is_public,
            'cards': [card.serialize() for card in self.cards]
        }


class Card(db.Model):
    """
    Card Model
    """
    __tablename__ = 'cards'
    id = db.Column(db.Integer, primary_key=True)
    question = db.Column(db.String, nullable=False)
    answer = db.Column(db.String, nullable=False)
    deck_id = db.Column(db.Integer, db.ForeignKey('decks.id'), nullable=False) 
    # specific foreign key, a column for deck_id indicates id of associated deck.

    def serialize(self):
        return {
            'id': self.id,
            'deck_id': self.deck_id,
            'question': self.question,
            'answer': self.answer
        }

class User(db.Model):
    """
    User Model
    """
    __tablename__ = 'users'
    id = db.Column(db.Integer, primary_key=True)
    username = db.Column(db.String, nullable=False)
    password = db.Column(db.String, nullable=False)
    decks = db.relationship('Deck', cascade="delete")
 
    def serialize(self):
        return {
            'id': self.id,
            'username': self.username,
            'password': self.password,
            'decks': [deck.serialize() for deck in self.decks]
        }
    
class Class(db.Model):
    """
    Class Model
    """
    __tablename__ = 'classes'
    id = db.Column(db.Integer, primary_key=True)
    title = db.Column(db.String, nullable=False)
    decks = db.relationship('Deck', cascade="delete")
 
    # Method to provide 3 hardcoded classes
    def create_hardcoded_classes():
        # Check if classes already exist
        if Class.query.count() == 0:
            # Create three hardcoded classes
            class_titles = ['CS 2110', 'CS 3110', 'CS 1998']
            for title in class_titles:
                new_class = Class(title=title)
                db.session.add(new_class)
            db.session.commit()

    def serialize(self):
        return {
            'id': self.id,
            'title': self.title,
            # NOTE: We don't serialize decks here since private decks would be 
            # leaked otherwise
        }