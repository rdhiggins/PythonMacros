import math

def less():
    oldActiveCalories = getActiveCalories()
    newActiveCalories = oldActiveCalories - random.random()
    if newActiveCalories < 0.0:
        newActiveCalories = 0.0
    setActiveCalories(newActiveCalories)

    oldActivity = getActivity()
    newActivity = oldActivity - random.random()
    if newActivity < 0.0:
        newActivity = 0.0
    setActivity(newActivity)
    
    oldStandup = getStandup()
    newStandup = oldStandup - random.random()
    if newStandup < 0.0:
        newStandup = 0.0
    setStandup(newStandup)

    return "{:5.2f}, {:5.2f}, {:5.2f}".format(newActiveCalories, newActivity, newStandup)
