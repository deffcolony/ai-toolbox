import asyncio
from autogen_agentchat.agents import AssistantAgent, UserProxyAgent
from autogen_ext.models.openai import OpenAIChatCompletionClient

async def main():
    # Replace with your actual OpenAI API key
    api_key = "your-api-key-here"
    model_client = OpenAIChatCompletionClient(model="gpt-4o", api_key=api_key)
    # For local models, replace with the appropriate client, e.g.:
    # from autogen_ext.models import LocalModelClient  # Hypothetical example
    # model_client = LocalModelClient(model="TheBloke_MythoMax-L2-13B-GPTQ", api_base="http://127.0.0.1:5001/v1")
    
    assistant = AssistantAgent(
        name="assistant",
        model_client=model_client,
        system_message="An AI assistant that can help with tasks."
    )
    
    user_proxy = UserProxyAgent(
        name="user_proxy",
        human_input_mode="NEVER",
        max_consecutive_auto_reply=10,
        is_termination_msg=lambda x: x.get("content", "").rstrip().endswith("TERMINATE"),
        code_execution_config={"work_dir": "web"},
    )
    
    task1 = """
Write python code to output numbers 1 to 100, and then store the code in a file
"""
    await user_proxy.initiate_chat(assistant, message=task1)
    
    task2 = """
Change the code in the file you just created to instead output numbers 1 to 200
"""
    await user_proxy.initiate_chat(assistant, message=task2)
    
    await model_client.close()

if __name__ == "__main__":
    asyncio.run(main())