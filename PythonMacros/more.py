import math

def more():
    oldActiveCalories = getActiveCalories()
    newActiveCalories = oldActiveCalories + random.random()
    if newActiveCalories > 10.0:
        newActiveCalories = 10.0
    setActiveCalories(newActiveCalories)

    oldActivity = getActivity()
    newActivity = oldActivity + random.random()
    if newActivity > 10.0:
        newActivity = 10.0
    setActivity(newActivity)
    
    oldStandup = getStandup()
    newStandup = oldStandup + random.random()
    if newStandup > 10.0:
        newStandup = 10.0
    setStandup(newStandup)

    return "{:5.2f}, {:5.2f}, {:5.2f}".format(newActiveCalories, newActivity, newStandup)
