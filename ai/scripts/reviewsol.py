# Copyright (c) 2023 Zoraiz Mahmood, James Snewin, Felipe Tavares, and Peter Robinson
# SPDX-License-Identifier: MIT

#from dotenv import load_dotenv
import os
import openai

#load_dotenv("./py.env")

# Initialize OpenAI GPT-3 API
openai.api_key = os.getenv("OPENAI_API_KEY")

# Find Solidity files in the repository
solidity_files = []
solidity_files.append(os.path.join(".", "flat.sol"))


#for root, _, files in os.walk("./src"):
#    for file in files:
#        if file.endswith(".sol"):
#            solidity_files.append(os.path.join(root, file))#


# Review each Solidity file using ChatGPT
for file in solidity_files:
    print(f"Reviewing {file}")
    with open(file, "r") as f:
        code = f.read()

    # Prepare the prompt for ChatGPT
    prompt = f"Provide an exhaustive list off all issues and vulnerabilities inside the following smart contract. Be in the issue descriptions and describe the actors involved. Include one exploit scenario in each vulnerability. Output as a valid markdown table with a list of objects that each have 'description' 'action' 'severity' 'actors' 'scenario' and 'type' columns. 'type' can be 'usability', 'vulnerability', 'optimization', or 'suggestion'. 'actors' is a list of the involved actors. 'serverity' can be 'low + ice block emoji', 'medium' or 'high + fire emoji'. Ensure that all fields of the table are filled out.\n\n```\n{code}\n```\n\n"

    # Call the GPT-3 API
    response = openai.Completion.create(
        model="text-davinci-003",
        prompt=prompt,
        temperature=0,
        max_tokens=3000,
        top_p=1.0,
        frequency_penalty=0.0,
        presence_penalty=0.0,
        stop=["#", ";"],
    )
    # Print the response
    print(f"Review for {file}: \n{response.choices[0].text.strip()}")