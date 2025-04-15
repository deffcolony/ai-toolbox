import asyncio
import os
import re
import subprocess
from typing import List
from openai import OpenAIChatCompletionClient
import requests
from dotenv import load_dotenv
from elevenlabs.client import ElevenLabs
from autogen_agentchat.agents import AssistantAgent
from autogen_agentchat.teams import RoundRobinGroupChat
from autogen_agentchat.conditions import TextMentionTermination

async def generate_voiceovers(messages: List[str], elevenlabs_client) -> List[str]:
    """Generate voiceovers using ElevenLabs API."""
    os.makedirs("voiceovers", exist_ok=True)
    audio_file_paths = []
    
    for i, message in enumerate(messages, 1):
        file_path = f"voiceovers/voiceover_{i}.mp3"
        if os.path.exists(file_path):
            print(f"File {file_path} already exists, skipping generation.")
            audio_file_paths.append(file_path)
            continue
        
        print(f"Generating voiceover {i}/{len(messages)}...")
        try:
            response = elevenlabs_client.text_to_speech.convert(
                text=message,
                voice_id="pNInz6obpgDQGcFmaJgB",  # Adam voice
                model_id="eleven_multilingual_v2",
                output_format="mp3_22050_32",
            )
            with open(file_path, "wb") as f:
                for chunk in response:
                    if chunk:
                        f.write(chunk)
            print(f"Voiceover {i} saved to {file_path}")
            audio_file_paths.append(file_path)
        except Exception as e:
            print(f"Error generating voiceover {i}: {e}")
            continue
    
    return audio_file_paths

async def generate_images(prompts: List[str], stability_api_key: str) -> List[str]:
    """Generate images using Stability AI API."""
    os.makedirs("images", exist_ok=True)
    stability_api_url = "https://api.stability.ai/v2beta/stable-image/generate/core"
    headers = {"Authorization": f"Bearer {stability_api_key}", "Accept": "image/*"}
    seed = 42
    image_paths = []
    
    for i, prompt in enumerate(prompts, 1):
        image_path = f"images/image_{i}.webp"
        if os.path.exists(image_path):
            print(f"Image {image_path} already exists, skipping generation.")
            image_paths.append(image_path)
            continue
        
        print(f"Generating image {i}/{len(prompts)} for prompt: {prompt}")
        payload = {
            "prompt": (None, f"{prompt}, Abstract Art Style / Ultra High Quality"),
            "output_format": (None, "webp"),
            "height": (None, "1920"),
            "width": (None, "1080"),
            "seed": (None, str(seed))
        }
        
        try:
            response = requests.post(stability_api_url, headers=headers, files=payload)
            if response.status_code == 200:
                with open(image_path, "wb") as f:
                    f.write(response.content)
                print(f"Image saved to {image_path}")
                image_paths.append(image_path)
            else:
                print(f"Error generating image {i}: {response.json()}")
        except Exception as e:
            print(f"Error generating image {i}: {e}")
            continue
    
    return image_paths

async def generate_video(captions: List[str], voiceover_paths: List[str], image_paths: List[str]) -> str:
    """Generate a video using FFmpeg."""
    os.makedirs("videos", exist_ok=True)
    output_path = "videos/output.mp4"
    
    if os.path.exists(output_path):
        print(f"Video {output_path} already exists, skipping generation.")
        return output_path
    
    try:
        # Prepare FFmpeg command
        # Assume images and voiceovers align with captions
        duration_per_caption = 3  # seconds per caption
        inputs = []
        for img in image_paths:
            inputs.extend(["-loop", "1", "-t", str(duration_per_caption), "-i", img])
        
        # Concatenate voiceovers
        voiceover_list = "|".join(voiceover_paths)
        filter_complex = (
            f"[0:v]scale=1920:1080:force_original_aspect_ratio=decrease,pad=1920:1080:(ow-iw)/2:(oh-ih)/2,setsar=1[v0];"
            f"[1:v]scale=1920:1080:force_original_aspect_ratio=decrease,pad=1920:1080:(ow-iw)/2:(oh-ih)/2,setsar=1[v1];"
            f"[2:v]scale=1920:1080:force_original_aspect_ratio=decrease,pad=1920:1080:(ow-iw)/2:(oh-ih)/2,setsar=1[v2];"
            f"[3:v]scale=1920:1080:force_original_aspect_ratio=decrease,pad=1920:1080:(ow-iw)/2:(oh-ih)/2,setsar=1[v3];"
            f"[4:v]scale=1920:1080:force_original_aspect_ratio=decrease,pad=1920:1080:(ow-iw)/2:(oh-ih)/2,setsar=1[v4];"
            f"[v0][v1][v2][v3][v4]concat=n=5:v=1:a=0[v];[a0][a1][a2][a3][a4]concat=n=5:v=0:a=1[a]"
            if len(image_paths) == 5 else "[v0][v1][v2][v3]concat=n=4:v=1:a=0[v];[a0][a1][a2][a3]concat=n=4:v=0:a=1[a]"
        )
        
        cmd = [
            "ffmpeg", "-y",
            *inputs,
            "-i", f"concat:{voiceover_list}",
            "-filter_complex", filter_complex,
            "-map", "[v]", "-map", "[a]",
            "-c:v", "libx264", "-c:a", "aac",
            "-shortest", output_path
        ]
        
        print(f"Generating video: {' '.join(cmd)}")
        subprocess.run(cmd, check=True, capture_output=True, text=True)
        print(f"Video saved to {output_path}")
        return output_path
    except subprocess.CalledProcessError as e:
        print(f"Error generating video: {e.stderr}")
        return ""
    except Exception as e:
        print(f"Error generating video: {e}")
        return ""

async def main():
    # Load environment variables
    load_dotenv()
    openai_api_key = os.getenv("OPENAI_API_KEY")
    elevenlabs_api_key = os.getenv("ELEVENLABS_API_KEY")
    stability_api_key = os.getenv("STABILITY_API_KEY")
    
    if not all([openai_api_key, elevenlabs_api_key, stability_api_key]):
        raise ValueError("Missing API keys in .env file. Please set OPENAI_API_KEY, ELEVENLABS_API_KEY, and STABILITY_API_KEY.")

    # Initialize clients
    elevenlabs_client = ElevenLabs(api_key=elevenlabs_api_key)
    openai_client = OpenAIChatCompletionClient(model="gpt-4o", api_key=openai_api_key)
    ollama_client = OpenAIChatCompletionClient(
        model="llama3.2:latest",
        api_key="placeholder",
        base_url="http://localhost:11434/v1",
        model_info={"function_calling": True, "json_output": True, "vision": False, "family": "unknown"}
    )

    # Define agents
    script_writer = AssistantAgent(
        name="script_writer",
        model_client=ollama_client,
        system_message='''
            You are a creative assistant tasked with writing a script for a short video.
            The script should consist of captions designed to be displayed on-screen, with the following guidelines:
                1. Each caption must be short and impactful (no more than 8 words) to avoid overwhelming the viewer.
                2. The script should have exactly 5 captions, each representing a key moment in the story.
                3. The flow of captions must feel natural, like a compelling voiceover guiding the viewer through the narrative.
                4. Always start with a question or a statement that keeps the viewer wanting to know more.
                5. You must also include the topic and takeaway in your response.
                6. The caption values must ONLY include the captions, no additional metadata or information.
            Output your response in the following JSON format:
            {
                "topic": "topic",
                "takeaway": "takeaway",
                "captions": [
                    "caption1",
                    "caption2",
                    "caption3",
                    "caption4",
                    "caption5"
                ]
            }
        '''
    )

    voice_actor = AssistantAgent(
        name="voice_actor",
        model_client=openai_client,
        tools=[lambda x: generate_voiceovers(x, elevenlabs_client)],
        system_message='''
            You are a helpful agent tasked with generating and saving voiceovers.
            Use the provided captions to generate voiceovers.
            Only respond with 'TERMINATE' once files are successfully saved locally.
        '''
    )

    graphic_designer = AssistantAgent(
        name="graphic_designer",
        model_client=openai_client,
        tools=[lambda x: generate_images(x, stability_api_key)],
        system_message='''
            You are a helpful agent tasked with generating and saving images for a short video.
            You are given a list of captions.
            You will convert each caption into an optimized prompt for the image generation tool.
            Your prompts must be concise and descriptive and maintain the same style and tone as the captions while ensuring continuity between the images.
            Your prompts must mention that the output images MUST be in: "Abstract Art Style / Ultra High Quality."
            You will then use the prompts list to generate images for each provided caption.
            Only respond with 'TERMINATE' once the files are successfully saved locally.
        '''
    )

    director = AssistantAgent(
        name="director",
        model_client=openai_client,
        tools=[lambda captions, voiceovers, images=generate_video: generate_video(captions, voiceovers, images)],
        system_message='''
            You are a helpful agent tasked with generating a short video.
            You are given a list of captions, voiceover file paths, and image file paths.
            Remove any characters that are not alphanumeric or spaces from the captions.
            Use the captions, voiceovers, and images to generate a video.
            Only respond with 'TERMINATE' once the video is successfully generated and saved locally.
        '''
    )

    # Set up team
    termination = TextMentionTermination("TERMINATE")
    team = RoundRobinGroupChat(
        agents=[script_writer, voice_actor, graphic_designer, director],
        termination_condition=termination,
        max_turns=4
    )

    # Interactive console
    print("Enter a prompt for a short video (e.g., 'A tourism ad for a beautiful island') or 'exit' to quit.")
    while True:
        user_input = input("Prompt: ")
        if user_input.strip().lower() == "exit":
            break
        
        try:
            result = await team.run(task=user_input)
            print(f"Result: {result}")
        except Exception as e:
            print(f"Error running team: {e}")

if __name__ == "__main__":
    asyncio.run(main())