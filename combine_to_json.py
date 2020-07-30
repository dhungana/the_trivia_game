import os
import json

def get_data():
    data = []
    for filename in os.listdir('OpenTriviaQA/categories'):
        with open('OpenTriviaQA/categories/' + filename, 'r') as f:
            current = {}
            choice = 1
            for line in f:
                line = line.strip().decode('utf-8', 'ignore')
                if line == '':
                    if 'text' in current and 'correct_answer' in current:
                        choices = [current[x] for x in list(current.keys()) if 'choice' in x]
                        if len(choices) in [2,4] and current['correct_answer'] in choices:
                            data.append(current)
                        current = {}
                        choice = 1
                elif line[0] == '#' and line[1] == 'Q':
                    current['text'] = line[3:]
                elif line[0] == '^':
                    current['correct_answer'] = line[2:]
                elif len(line) > 1 and line[1] == ' ':
                    current['choice'+str(choice)] = line[2:]
                    choice += 1
                else:
                    if 'text' in current:
                        current['text'] += '\n' + line
                    else:
                        print(filename, line)

    with open('seed_data.json', 'w') as f:
        json.dump(data, f)
    print('Seed data length:', len(data))

def test():
    with open('seed_data.json', 'r') as f:
        data = json.load(f)
        for seed in data:
            if 'text' not in seed:
                print('Error: text:', seed)
            if 'correct_answer' not in seed:
                print('Error: correct_answer:', seed)
            if 'choice1' not in seed:
                print('Error: choice1', seed)
            if 'choice2' not in seed:
                print('Error: choice2', seed)
            choices = [seed[x] for x in list(seed.keys()) if 'choice' in x]
            if seed['correct_answer'] not in choices:
                print('Error: Truth not in choices', seed)


if __name__ == '__main__':
    get_data()
    test()
