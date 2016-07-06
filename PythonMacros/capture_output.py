import sys

class CaptureOutput:
    def __init__(self):
        self.value = ''
    def write(self, txt):
        self.value += txt

standardOutput = CaptureOutput()
standardError = CaptureOutput()

sys.stdout = standardOutput
sys.stderr = standardError
