# This template creates a single text-only AutoGen agent powered by a local Ollama model (llama3.2:latest).
# It generates short stories (100-200 words) with morals based on user prompts, outputting structured JSON.
# The agent runs in an interactive console, accepting prompts or 'exit' to quit, with no external API dependencies.
# Users can rename this to app.py and customize the system message, task, or model for other text-based tasks.

import asyncio
from pydantic import BaseModel
from autogen_agentchat.agents import AssistantAgent
from autogen_agentchat.teams import RoundRobinGroupChat
from autogen_agentchat.conditions import TextMentionTermination
from autogen_ext.models.ollama import OllamaChatCompletionClient

# Define structured output format
class TextOutput(BaseModel):
    story: str
    moral: str

async def main():
    # Initialize Ollama client
    ollama_client = OllamaChatCompletionClient(
        model="llama3.2:latest",
        response_format=TextOutput
    )

    # Define text-only agent
    text_agent = AssistantAgent(
        name="text_agent",
        model_client=ollama_client,
        system_message='''
            You are a creative assistant tasked with generating a short story based on a user prompt.
            The story should be concise (100-200 words) and engaging, with a clear moral or lesson.
            Output your response in the following JSON format:
            {
                "story": "Your story text here",
                "moral": "The moral or lesson of the story"
            }
        ''',
        description="Generates short stories with morals."
    )

    # Set up team (single agent)
    termination = TextMentionTermination("TERMINATE")
    team = RoundRobinGroupChat(
        agents=[text_agent],
        termination_condition=termination,
        max_turns=1
    )

    # Interactive console
    print("Enter a prompt for a short story (e.g., 'A fox in a forest') or 'exit' to quit.")
    while True:
        user_input = input("Prompt: ")
        if user_input.strip().lower() == "exit":
            break
        
        try:
            result = await team.run(task=user_input)
            print(f"Result: {result}")
        except Exception as e:
            print(f"Error running agent: {e}")

if __name__ == "__main__":
    asyncio.run(main())