To run the script first install:

* pip3 install openai
* pip3 install env
* pip3 install python-dotenv

Have your OpenAI API key in an environment variable: OPENAI_API_KEY
export OPENAI_API_KEY=<yourkey>

Install truffle and truffle-flattener

Flattern the file you want to analyse:
truffle-flattener contracts/functioncall/gpact/GpactCrosschainControl.sol > flat.sol

Execute the review:

python3 reviewsol.py