# The Trivia Game
The game consists of multiple rounds. In each round players are presented a question, a choice of answers, and have to select one answer within the allotted time (30 seconds or so). Players that chose a correct answer advance to the next round. Those who chose the wrong answers are eliminated. The game continues until there’s only one winner left.

This game is deployed at https://the-trivia-game.herokuapp.com

# Local Setup

Setup database connections through environment variables in config/database.yml Then, run following commands:
```
rails db:create
rails db:migrate
rails db:seed
```

To run the server locally:
```
rails server
```

To perform unit tests:
```
rails test
```

To perform selenium test:
```
virtualenv venv  
source venv/bin/activate
pip install -r requirements.txt
python selenium_test.py
```

# Data Source
OpenTriviaQA from https://github.com/uberspot/OpenTriviaQA .

To get the json seed file:
```
git clone https://github.com/uberspot/OpenTriviaQA.git
python combine_to_json.py
```

This creates a file seed_data.json which has trivia from all categories combined
into one json file.
