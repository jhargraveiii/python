import dspy
from dspy.teleprompt import BootstrapFewShot
import os

model = dspy.OllamaLocal(
    model="qwen2:0.5b",
    base_url=os.environ.get("OLLAMA_URL", "http://localhost:11434"),
    max_tokens=500,
)

# Correctly configure DSPy to use the local Ollama model
dspy.settings.configure(lm=model)

class MathProblem(dspy.Signature):
    question = dspy.InputField(desc="A math word problem")
    answer = dspy.OutputField(desc="The numerical answer to the question")

class MathSolver(dspy.Module):
    def __init__(self):
        super().__init__()
        self.solve = dspy.Predict(MathProblem)
    
    def forward(self, question):
        return self.solve(question=question)

# Define training examples
train_examples = [
    dspy.Example(
        question="What is 12 plus 18?",
        answer="30"
    ).with_inputs("question"),
    dspy.Example(
        question="If I have 7 apples and eat 3, how many do I have left?", 
        answer="4"
    ).with_inputs("question")
]

# Define a simple metric function
def metric(example, actual, trace=None):
    return 1.0 if example.answer == actual.answer else 0.0

# Optimize the prompt
teleprompter = BootstrapFewShot(
    metric=metric,
    max_bootstrapped_demos=5
)

optimized_solver = teleprompter.compile(
    MathSolver(), 
    trainset=train_examples
)

# Test the optimized solver
test_question = "Sally has 5 more marbles than John. Together they have 35 marbles. How many marbles does Sally have?"
result = optimized_solver(test_question)
print(result.answer)  # Assuming the result object has an attribute 'answer' for simplicity
