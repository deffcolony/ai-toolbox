import asyncio
from autogen_agentchat.agents import AssistantAgent, UserProxyAgent, GroupChat, GroupChatManager
from autogen_ext.models.openai import OpenAIChatCompletionClient

async def main():
    # Replace with your actual OpenAI API key
    api_key = "your-api-key-here"
    model_client = OpenAIChatCompletionClient(model="gpt-4o", api_key=api_key)
    # For local models, replace with the appropriate client, e.g.:
    # from autogen_ext.models import LocalModelClient  # Hypothetical example
    # model_client = LocalModelClient(model="TheBloke_MythoMax-L2-13B-GPTQ", api_base="http://127.0.0.1:5001/v1")

    # Humans
    user_proxy = UserProxyAgent(
        name="Admin",
        system_message="A human admin. Interact with the planner to discuss the plan. Plan execution needs to be approved by this admin.",
        human_input_mode="ALWAYS",  # Changed from code_execution_config=False to enable human input
    )

    executor = UserProxyAgent(
        name="Executor",
        system_message="Executor. Execute the code written by the engineer and report the result.",
        human_input_mode="NEVER",
        code_execution_config={"last_n_messages": 3, "work_dir": "paper"},
    )

    # Agents
    engineer = AssistantAgent(
        name="Engineer",
        model_client=model_client,
        system_message='''Engineer. You follow an approved plan. You write python/shell code to solve tasks. Wrap the code in a code block that specifies the script type. The user can't modify your code. So do not suggest incomplete code which requires others to modify. Don't use a code block if it's not intended to be executed by the executor.
Don't include multiple code blocks in one response. Do not ask others to copy and paste the result. Check the execution result returned by the executor.
If the result indicates there is an error, fix the error and output the code again. Suggest the full code instead of partial code or code changes. If the error can't be fixed or if the task is not solved even after the code is executed successfully, analyze the problem, revisit your assumption, collect additional info you need, and think of a different approach to try.
''',
    )

    scientist = AssistantAgent(
        name="Scientist",
        model_client=model_client,
        system_message="""Scientist. You follow an approved plan. You are able to categorize papers after seeing their abstracts printed. You don't write code.""",
    )

    planner = AssistantAgent(
        name="Planner",
        model_client=model_client,
        system_message='''Planner. Suggest a plan. Revise the plan based on feedback from admin and critic, until admin approval.
The plan may involve an engineer who can write code and a scientist who doesn't write code.
Explain the plan first. Be clear which step is performed by an engineer, and which step is performed by a scientist.
''',
    )

    critic = AssistantAgent(
        name="Critic",
        model_client=model_client,
        system_message="Critic. Double check plan, claims, code from other agents and provide feedback. Check whether the plan includes adding verifiable info such as source URL.",
    )

    # Start the group chat
    groupchat = GroupChat(agents=[user_proxy, engineer, scientist, planner, executor, critic], messages=[])
    manager = GroupChatManager(groupchat=groupchat, model_client=model_client)

    # Start the chat
    task = """
find papers on LLM applications from arxiv in the last week, create a markdown table of different domains.
"""
    await user_proxy.initiate_chat(manager, message=task)

    # Cleanup
    await model_client.close()

if __name__ == "__main__":
    asyncio.run(main())