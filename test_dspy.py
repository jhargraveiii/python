import dspy

# Define a simple DSPy module
class SimpleModule(dspy.Module):
    def __init__(self):
        super().__init__()
        self.signature = 'input -> output'

    def forward(self, input):
        return f"Processed: {input}"

# Instantiate the module
simple_module = SimpleModule()

# Test the module with a sample input
input_data = "Hello, DSPy!"
output_data = simple_module(input_data)

# Print the output
print(output_data)

