import os
from mutagen.mp3 import MP3
from datetime import timedelta

# Function to format the duration as [hh:mm:ss]
def format_duration(duration):
    seconds = int(duration.total_seconds())
    return str(timedelta(seconds=seconds))

# Get a list of all the music files in the current directory
music_files = [file for file in os.listdir() if file.endswith(".mp3")]

# Sort the music files by filename
music_files.sort()

# Create a playlist file
playlist_file = open("playlist.txt", "w")

# Iterate through the music files and write the playlist entries
for index, music_file in enumerate(music_files, start=1):
    audio = MP3(music_file)
    duration = format_duration(audio.info.length)
    entry = f"[{duration}] - {index:02d} {os.path.splitext(music_file)[0]}\n"
    playlist_file.write(entry)

# Close the playlist file
playlist_file.close()

print("Playlist generated and saved as 'playlist.txt'")
