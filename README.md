# The Trivia Game
A game where trivia questions are answered until no competitors are left.

# Local Setup

Setup database in config/database.yml Then, run following commands:
1. rails db:create
2. rails db:migrate
3. rails db:seed

To run the server locally.
1. rails server

# Data Source
OpenTriviaQA from https://github.com/uberspot/OpenTriviaQA .

To get the json seed file:
1. git clone https://github.com/uberspot/OpenTriviaQA.git
2. python combine_to_json.py

This creates a file seed_data.json which has trivia from all categories combined
into one json file.
