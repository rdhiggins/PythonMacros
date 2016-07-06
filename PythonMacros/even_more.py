import random

def evenMore():
    oldActiveCalories = getActiveCalories()
    newActiveCalories = oldActiveCalories + random.random() * 10.0
    if newActiveCalories > 10.0:
        newActiveCalories = 10.0
    setActiveCalories(newActiveCalories)

    oldActivity = getActivity()
    newActivity = oldActivity + random.random() * 10.0
    if newActivity > 10.0:
        newActivity = 10.0
    setActivity(newActivity)

    oldStandup = getStandup()
    newStandup = oldStandup + random.random() * 10.0
    if newStandup > 10.0:
        newStandup = 10.0
    setStandup(newStandup)

    return "{:5.2f}, {:5.2f}, {:5.2f}".format(newActiveCalories, newActivity, newStandup)
