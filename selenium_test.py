URL = "http://localhost:3000/"
PLAYER_NUM = 50
from selenium import webdriver
import json
import time
from selenium.webdriver.common.keys import Keys
import random
import math
from selenium.common.exceptions import NoSuchElementException

with open('seed_data.json', 'r') as f:
	data = json.load(f)
	question_dict = {' '.join(d['text'].strip().split()): d['correct_answer'] for d in data}

driver=webdriver.Chrome('./chromedriver')
driver.get(URL)

#Open Tabs
for tab in range(1, PLAYER_NUM + 1):
	driver.execute_script("window.open('about:blank', 'tab" + str(tab) +"');")
	driver.switch_to.window("tab" + str(tab))
	driver.get(URL)

#Create Game
driver.switch_to.window("tab1")
time.sleep(1)
driver.find_element_by_id("createGameButton").click()
elem = driver.find_element_by_id("gameName")
elem.clear()
elem.send_keys("Test Game")
elem = driver.find_element_by_id("minimumPlayers")
elem.clear()
elem.send_keys(str(PLAYER_NUM))
elem = driver.find_element_by_id("nickname")
elem.clear()
elem.send_keys("user1")
driver.find_element_by_id("createSubmit").click()
time.sleep(1)
assert driver.find_element_by_id("currentPlayers").text.strip() == 'Current Players: 1/'+str(PLAYER_NUM)

#Join Game and Test Joining
for tab in range(2, PLAYER_NUM + 1):
	driver.switch_to.window("tab" + str(tab))
	driver.find_element_by_xpath("//*[starts-with(@id, 'joinGameTest Game')]").click()
	elem = driver.find_element_by_id("joinNickname")
	elem.clear()
	elem.send_keys("user" + str(tab))
	driver.find_element_by_id("joinSubmit").click()
	time.sleep(0.5)
	if tab < PLAYER_NUM:
		assert driver.find_element_by_id("currentPlayers").text.strip() == 'Current Players: '+str(tab)+'/'+str(PLAYER_NUM)
	else:
		assert driver.find_element_by_id("question")

game = True
tabs = [i for i in range(1, PLAYER_NUM + 1)]
while game:
	#Answer
	now = time.time()
	time.sleep(1)
	choices_count = {i:0 for i in range(1, 5)}
	correct = []
	eliminated = []
	for tab in tabs[:]:
		driver.switch_to.window("tab" + str(tab))
		question = driver.find_element_by_id("question").text.strip()
		correct_answer = question_dict[question]
		rand = int(math.floor(random.random() * 5))
		if rand > 0:
			try:
				time.sleep(0.2)
				elem = driver.find_element_by_id("choice" + str(rand))
				answer = elem.text.strip() #might be 2 option so, trying
				elem.click()
				choices_count[rand] += 1
				if correct_answer == answer:
					correct.append(tab)
				else:
					eliminated.append(tab)
			except NoSuchElementException:
				eliminated.append(tab)
		else:
			eliminated.append(tab)

	#Review result
	time.sleep(max(0, now + 30 -  time.time()))
	now = time.time()
	time.sleep(1)
	for tab in tabs[:]:
		driver.switch_to.window("tab" + str(tab))
		time.sleep(0.001)
		result = driver.find_element_by_id("result").text
		if tab in eliminated:
			assert 'Sorry! You were eliminated!' in result
			tabs.remove(tab)
		elif len(correct) == 1:
			assert 'Congratulations user' + str(tab) +'! You won!'   in result
		else:
			assert 'You progressed to the next round!' in result
		for option in range(1, 5):
			try:
				option_stat = driver.find_element_by_id("result" + str(option)).text.strip().split(':')[-1].strip()
				assert option_stat == str(choices_count[option])
			except NoSuchElementException:
				pass
	if len(correct) < 2:
		game = False
	else:
		time.sleep(max(0, now + 20 -  time.time()))
