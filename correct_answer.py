import json

with open('seed_data.json', 'r') as f:
	data = json.load(f)
	question_dict = {d['text'].strip(): d['correct_answer'] for d in data}

while True:
    text = input().strip()
    print(question_dict[text])
