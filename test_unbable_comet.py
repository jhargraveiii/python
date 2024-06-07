from comet import download_model, load_from_checkpoint

# Download the default COMET model
model_path = download_model("Unbabel/wmt22-comet-da")

# Load the model checkpoint
model = load_from_checkpoint(model_path)

# Prepare the data in the required format
data = [
    {
        "src": "Dem Feuer konnte Einhalt geboten werden",
        "mt": "The fire could be stopped", 
        "ref": "They were able to control the fire."
    },
    {
        "src": "Schulen und Kindergärten wurden eröffnet.",
        "mt": "Schools and kindergartens were open",
        "ref": "Schools and kindergartens opened"
    }
]

# Call the predict method to get the scores
model_output = model.predict(data, batch_size=8, gpus=1)

# Print the results
print(model_output)
print("Segment-level scores:", model_output.scores) 
print("System-level score:", model_output.system_score)